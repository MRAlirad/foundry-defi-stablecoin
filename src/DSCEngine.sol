// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { DecentralizedStableCoin } from './DecentralizedStableCoin.sol';
import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

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
    //!  Errors  !//
    error DSCEngine__NeedsMoreThanZero();
    error DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength();
    error DSCEngine__NotAllowedToken();
    error DSCEngine__TransferFailed();

    //!  State Variables  !//
    uint256 private constant ADDITIONAL_FEED_PRECISION = 1e10;
    uint256 private constant PRECISION = 1e18;

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
    function depositCollateralAndMintDsc() external {}

    /*
        * @param tokenCollateralAddress: The ERC20 token address of the collateral you're depositing
        * @param amountCollateral: The amount of collateral you're depositing
    */
    function depositCollateral(address tokenCollateralAddress, uint256 amountCollateral) external moreThanZero(amountCollateral) isAllowedToken(tokenCollateralAddress) nonReentrant {
        s_collateralDeposited[msg.sender][tokenCollateralAddress] += amountCollateral;
        emit CollateralDeposited(msg.sender, tokenCollateralAddress, amountCollateral);
        bool success = IERC20(tokenCollateralAddress).transferFrom(msg.sender, address(this), amountCollateral);
        
        if(!success) revert DSCEngine__TransferFailed();
    }

    function redeemCollateralForDsc() external {}

    function redeemCollateral() external {}

    /*
        * @param amountDscToMint: The amount of DSC you want to mint
        * @notice You can only mint DSC if you hav enough collateral
    */
    function mintDsc(uint256 amountDscToMint) external moreThanZero(amountDscToMint) nonReentrant {
        s_DSCMinted[msg.sender] += amountDscToMint;

        //* if they minted too much DSC
        _revertIfHealthFactorIsBroken(msg.sender);
    }

    function burnDsc() external {}

    function liquidate() external {}

    function getHealthFactor() external view {}
    
    //!  Private & Internal View Functions  !//
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
    }

    function _revertIfHealthFactorIsBroken(address user) internal view {
        //* 1. check health factor (do they have enough collateral?)
        //* 2. revert if they don't have enough collateral
    }

    //!  Public & External View Functions  !//
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
        (, int256 price,,,) = priceFeed.latestRoundData();
        
        return ((uint256(price) * ADDITIONAL_FEED_PRECISION) * amount) / PRECISION;
    }
}

