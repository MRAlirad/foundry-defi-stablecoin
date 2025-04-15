// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { DecentralizedStableCoin } from './DecentralizedStableCoin.sol';
import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {OracleLib} from './libraries/OracleLib.sol';

/*
    * @title DSCEngine
    * @author MRAlirad
    *
    * The system is designed to be as minimal as possible, and have the tokens maintain a 1 token == $1 peg at all times.
    * This is a stablecoin with the properties:
    * - Exogenously Collateralized
    * - Dollar Pegged
    * - Algorithmically Stable
    *
    * It is similar to DAI if DAI had no governance, no fees, and was backed by only WETH and WBTC.
    *
    * Our DSC system should always be "overcollateralized". At no point, should the value of all collateral < the $ backed value of all the DSC.
    *
    * @notice This contract is the core of the Decentralized Stablecoin system. It handles all the logic for minting and redeeming DSC, as well as depositing and withdrawing collateral.
    * @notice This contract is based on the MakerDAO DSS system
*/
contract DSCEngine is ReentrancyGuard {
    //!  Types  !//
    using OracleLib for AggregatorV3Interface;

    //!  Errors  !//
    error DSCEngine__NeedsMoreThanZero();
    error DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength();
    error DSCEngine__NotAllowedToken();
    error DSCEngine__TransferFailed();
    error DSCEngine__MintFailed();
    error DSCEngine__BreaksHealthFactor(uint256 healthFactor);
    error DSCEngine__HealthFactorOk();
    error DSCEngine__HealthFactorNotImproved();

    //!  State Variables  !//
    uint256 private constant ADDITIONAL_FEED_PRECISION = 1e10;
    uint256 private constant PRECISION = 1e18;
    uint256 private constant LIQUIDATION_THRESHOLD = 50;
    uint256 private constant LIQUIDATION_PRECISION = 100;
    uint256 private constant MIN_HEALTH_FACTOR = 1e18;
    uint256 private constant LIQUIDATION_BONUS = 10; // 10 percent bonus

    mapping(address token => address priceFeed) private s_priceFeeds; // tokenToPriceFeed
    mapping(address user => mapping(address token => uint256 amount)) private s_collateralDeposited;
    mapping(address user => uint256 amountDscMinted) private s_DSCMinted;

    address[] private s_collateralTokens;

    DecentralizedStableCoin private immutable i_dsc;

    //!  Modifiers  !//
    modifier moreThanZero(uint256 amount) {
        if(amount == 0) revert DSCEngine__NeedsMoreThanZero();
        _;
    }

    modifier isAllowedToken(address token) {
        if(s_priceFeeds[token] == address(0)) revert DSCEngine__NotAllowedToken();
        _;
    }

    //!  Events  !//
    event CollateralDeposited(address indexed user, address indexed token, uint256 indexed amount);
    event CollateralRedeemed(address indexed redeemedFrom,address indexed redeemedTo, address indexed token, uint256 amount);

    //!  Functions  !//
    constructor(
        address[] memory tokenAddresses,
        address[] memory priceFeedAddresses,
        address dscAddress
    ) {
        if(tokenAddresses.length != priceFeedAddresses.length)
            revert DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength();

        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            s_priceFeeds[tokenAddresses[i]] = priceFeedAddresses[i];
            s_collateralTokens.push(tokenAddresses[i]);
        }

        i_dsc = DecentralizedStableCoin(dscAddress);
    }

    //!  External Functions  !//
    
    /*
        * @param tokenCollateralAddress: the address of the token to deposit as collateral
        * @param amountCollateral: The amount of collateral to deposit
        * @param amountDscToMint: The amount of DecentralizedStableCoin to mint
        * @notice: This function will deposit your collateral and mint DSC in one transaction
    */
    function depositCollateralAndMintDsc(address tokenCollateralAddress, uint256 amountCollateral, uint256 amountDscToMint) external {
        depositCollateral(tokenCollateralAddress, amountCollateral);
        mintDsc(amountDscToMint);
    }

    /*
        * @param tokenCollateralAddress: The ERC20 token address of the collateral you're depositing
        * @param amountCollateral: The amount of collateral you're depositing
    */
    function depositCollateral(address tokenCollateralAddress, uint256 amountCollateral) public moreThanZero(amountCollateral) isAllowedToken(tokenCollateralAddress) nonReentrant {
        s_collateralDeposited[msg.sender][tokenCollateralAddress] += amountCollateral;
        emit CollateralDeposited(msg.sender, tokenCollateralAddress, amountCollateral);
        bool success = IERC20(tokenCollateralAddress).transferFrom(msg.sender, address(this), amountCollateral);
        
        if(!success) revert DSCEngine__TransferFailed();
    }

    /*
        * @param tokenCollateralAddress: the collateral address to redeem
        * @param amountCollateral: amount of collateral to redeem
        * @param amountDscToBurn: amount of DSC to burn
        * This function burns DSC and redeems underlying collateral in one transaction
    */
    function redeemCollateralForDsc(address tokenCollateralAddress, uint256 amountCollateral, uint256 amountDscToBurn) external {
        burnDsc(amountDscToBurn);
        redeemCollateral(tokenCollateralAddress, amountCollateral); // it checks health factor itselt
    }

    // in order to redeem collateral:
    // 1. Health factor must be over 1 AFTER collateral pulled
    function redeemCollateral(address tokenCollateralAddress, uint256 amountCollateral) public moreThanZero(amountCollateral) nonReentrant {
        _redeemCollateral(msg.sender, msg.sender, tokenCollateralAddress, amountCollateral);
        _revertIfHealthFactorIsBroken(msg.sender);
    }

    /*
        * @param amountDscToMint: The amount of DSC you want to mint
        * @notice You can only mint DSC if you hav enough collateral
    */
    function mintDsc(uint256 amountDscToMint) public moreThanZero(amountDscToMint) nonReentrant {
        s_DSCMinted[msg.sender] += amountDscToMint;

        //* if they minted too much DSC
        _revertIfHealthFactorIsBroken(msg.sender);
        bool minted = i_dsc.mint(msg.sender, amountDscToMint);
        if(!minted) revert DSCEngine__MintFailed();
        
        _revertIfHealthFactorIsBroken(msg.sender);
    }

    function burnDsc(uint256 amount) public moreThanZero(amount) {
        _burnDsc(amount, msg.sender, msg.sender);
        _revertIfHealthFactorIsBroken(msg.sender); // it is actually is not needed
    }

    /*
    * @param collateral: The ERC20 token address of the collateral you're using to make the protocol solvent again.
    * This is collateral that you're going to take from the user who is insolvent.
    * In return, you have to burn your DSC to pay off their debt, but you don't pay off your own.
    * @param user: The user who is insolvent. They have to have a _healthFactor below MIN_HEALTH_FACTOR
    * @param debtToCover: The amount of DSC you want to burn to cover the user's debt.

    * @notice: You can partially liquidate a user.
    * @notice: You will get a 10% LIQUIDATION_BONUS for taking the users funds.
    * @notice: This function working assumes that the protocol will be roughly 150% overcollateralized in order for this to work.
    * @notice: A known bug would be if the protocol was only 100% collateralized, we wouldn't be able to liquidate anyone.
    * For example, if the price of the collateral plummeted before anyone could be liquidated.
    */
    function liquidate(address collateral, address user, uint256 debtToCover) external moreThanZero(debtToCover) nonReentrant {
        // need to check health factor of the user
        uint256 startingUserHealthFactor = _healthFactor(user);
        if(startingUserHealthFactor >= MIN_HEALTH_FACTOR) revert DSCEngine__HealthFactorOk();
        
        // we want to burn their DSC "debt" and take their collateral
        uint256 tokenAmountFromDebtCovered = getTokenAmountFromUsd(collateral, debtToCover);

        // we are giving the liquidator $110 of WETH for 1000 DSC
        // we should implement a feature to liquidate in the event the protocol is insolvent And sweep extra amount into a treasury.
    
        uint256 bonusCollateral = (tokenAmountFromDebtCovered * LIQUIDATION_BONUS) / LIQUIDATION_PRECISION;
        uint256 collateralToRedeem = tokenAmountFromDebtCovered + bonusCollateral;
        _redeemCollateral(user, msg.sender, collateral, collateralToRedeem);
        _burnDsc(debtToCover, user, msg.sender);
        
        uint256 endingUserHealthFactor = _healthFactor(user);
        if(endingUserHealthFactor <= startingUserHealthFactor) revert DSCEngine__HealthFactorNotImproved();
        
        _revertIfHealthFactorIsBroken(msg.sender);
    }
    

    function getHealthFactor() external view {}
    
    //!  Private & Internal View Functions  !//
    function _burnDsc(uint256 amountDscToBurn, address onBehalfOf, address dscFrom) private {
        s_DSCMinted[onBehalfOf] -= amountDscToBurn;
        bool success = i_dsc.transferFrom(dscFrom, address(this), amountDscToBurn);
        if(!success) revert DSCEngine__TransferFailed();
        i_dsc.burn(amountDscToBurn);
    }

    function _redeemCollateral(address from, address to, address tokenCollateralAddress, uint256 amountCollateral) private {
        s_collateralDeposited[from][tokenCollateralAddress] -= amountCollateral;
        emit CollateralRedeemed(from, to, tokenCollateralAddress, amountCollateral);
        bool success = IERC20(tokenCollateralAddress).transfer(to, amountCollateral);
        if(!success) revert DSCEngine__TransferFailed();
    }

    function _getAccountInformation(address user) private view returns(uint256 totalDscMinted, uint256 collateralValueInUsd) {
        totalDscMinted = s_DSCMinted[user];
        collateralValueInUsd = getAccountCollateralValue(user);
    }

    /*
        * Returns how close to liquidation a user is
        * If a user goes below 1, then they can be liquidated.
    */
    function _healthFactor(address user) private view returns(uint256) {
        //* total DSC minted
        //* total collateral value
        (uint256 totalDscMinted, uint256 collateralValueInUsd) = _getAccountInformation(user);
        uint256 collateralAdjuctedForThreshold = (collateralValueInUsd * LIQUIDATION_THRESHOLD) / LIQUIDATION_PRECISION;
        return (collateralAdjuctedForThreshold * PRECISION) / totalDscMinted;
    }

    function _revertIfHealthFactorIsBroken(address user) internal view {
        //* 1. check health factor (do they have enough collateral?)
        //* 2. revert if they don't have enough collateral
        
        uint256 userHealthFactor = _healthFactor(user);
        if(userHealthFactor < MIN_HEALTH_FACTOR) revert DSCEngine__BreaksHealthFactor(userHealthFactor);
    }

    //!  Public & External View Functions  !//
    function getTokenAmountFromUsd(address token, uint256 usdAmountInWei) public view returns(uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(s_priceFeeds[token]);
        (, int256 price,,,) = priceFeed.staleCheckLatestRoundData();
        return (usdAmountInWei * PRECISION)/ (uint256(price) * ADDITIONAL_FEED_PRECISION);
    }

    function getAccountCollateralValue(address user) public view returns (uint256 totalCollateralValueInUsd) {
        //* loop throough each collateral token, get the amount they have deposited, and map it to the price, to get the USD value 
        for(uint256 i = 0; i < s_collateralTokens.length; i++) {
            address token = s_collateralTokens[i];
            uint256 amount = s_collateralDeposited[user][token];
            totalCollateralValueInUsd += getUsdValue(token, amount);
        }
        return totalCollateralValueInUsd;
    }

    function getUsdValue(address token, uint256 amount) public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(s_priceFeeds[token]);
        (, int256 price,,,) = priceFeed.staleCheckLatestRoundData();
        
        return ((uint256(price) * ADDITIONAL_FEED_PRECISION) * amount) / PRECISION;
    }

    function getAccountInformation(address user) external view returns (uint256 totalDscMinted, uint256 collateralValueInUsd) {
        (totalDscMinted, collateralValueInUsd) = _getAccountInformation(user);
    }
    
    function getCollateralTokens() external view returns (address[] memory) {
        return s_collateralTokens;
    }
    
    function getCollateralBalanceOfUser(address user, address token) external view returns(uint256) {
        return s_collateralDeposited[user][token];
    }
    
    function getCollateralTokenPriceFeed(address token) external view returns (address) {
        return s_priceFeeds[token];
    }
}

