# DEFI - StableCoin

## DeFi Introduction

Decentralized Finance (DeFi) is an enormous ecosystem, we couldn't hope to offer an exhaustive coverage of everything available, but we are going to provide a thorough rundown of what DeFi is, why it's popular and some of the most popular dApps out there.

A good starting place is **[DeFi Llama](https://defillama.com/)**. This website aggregates data from major DeFi protocols and provides a snapshot of what's happening in the space.

<img src='./images/defi-introduction/defi-introduction1.png' alt='defi-introduction1' />

DeFi Llama demonstrates the size of various DeFi protocols by ranking them by Total Value Locked (TVL). Some of the biggest include:

**Lido:** Liquid Staking platform. Liquid staking provides the benefits of traditional staking while unlocking the value of staked assets for use as collateral.

**MakerDAO:** Collateralized Debt Position (CDP) protocol for making stablecoins. (This is what we'll be doing in this section!)

**AAVE:** Borrowing/Lending protocol, similar to a decentralized bank.

**Curve Finance:** Decentralized Exchange (DEX), specialized for working with stablecoins.

**Uniswap:** General purposes Decentralized Exchange for swapping tokens and various digital assets.

The beauty of DeFi is that it provides access to sophisticated financial instruments within a decentralized context.

Some additional places that are great to learn about DeFi include:

-   **[Bankless](https://www.bankless.com/)**
-   **[Metamask Learn](https://learn.metamask.io/)**

### AAVE

I often encourage people to go checkout AAVE and Uniswap to get a feel for what these protocols can offer.

**[AAVE](https://aave.com/)**, as mentioned, is a decentralized borrowing and lending platform. By logging into the dApp by connecting a wallet, users can see assets they hold which can be offered as collateral and assets available to borrow.

<img src='./images/defi-introduction/defi-introduction2.png' alt='defi-introduction2' />

Each asset has it's own calculated Annual Percentage Yield (APY) which effectively represents the interest a lender to the protocol would make on deposits of a given asset.

### Uniswap

Another massively popular protocol that I like to bring to people's attention is **[Uniswap](https://uniswap.org/)**.

<img src='./images/defi-introduction/defi-introduction3.png' alt='defi-introduction3' />

Uniswap is a decentralized exchange which allows users to swap tokens for any other token.

Unfortunately, not all of these DeFi protocols work on testnets, but I do have a few videos for you to watch to gain a deeper understanding and context of how things work:

-   **[Leveraged Trading in DeFi](https://www.youtube.com/watch?v=TmNGAvI-RUA)**
-   **[Become a DeFi QUANT](https://www.youtube.com/watch?v=x0YDcZly_PU)**
-   **[Aave Flash Loan Tutorial](https://www.youtube.com/watch?v=Aw7yvGFtOvI)**

> ❗ **IMPORTANT** <br />
> If you do decide to experiment with these protocols, I highly recommend doing so on testnets when possible and Layer 2s (like Polygon, Optimism, or Arbitrum) as the fees on Ethereum Mainnet can be _very_ high.

### MEV

Before we get too deep into DeFi, I do want to bring the concept of Miner/Maximal Extractable Value (MEV) to your attention as a caution.

At a very high-level, MEV is the process by which a node validator or miner orders the transactions of a block they're validating in such as way as to benefit themselves or conspirators.

There are many teams and protocols working hard to mitigate the effects of MEV advantages, but for now, I recommend that anyone looking to get deep into DeFi read through and understand the content on **[flashbots.net's New to MEV guide](https://docs.flashbots.net/new-to-mev)**. This content is both an entertaining way to learn about a complex concept and extremely eye-opening to the dangers MEV represents in the DeFi space.

## DeFi Code Walkthrough

The Decentralized Stablecoin protocol has 2 contracts at it's heart.

-   **DecentralizedStableCoin.sol**
-   **DSCEngine.sol**

`DecentralizedStableCoin.sol` is effectively a fairly simple `ERC20` with a few more advanced features imported such as [`ERC20Burnable`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/ERC20Burnable.sol) and OpenZeppelin's [`Ownable`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol) libraries.

Otherwise, `DecentralizedStableCoin.sol` is fairly expected in what's included, a constructor with `ERC20` parameters, the ability to `mint` and `burn` etc.

The real meat of this protocol can be found in `DSCEngine.sol`. `DecentralizeStableCoin.sol` is ultimately going to be controlled by this `DSCEngine` and most of the protocol's complex functionality is included within including functions such as:

-   **depositCollateralAndMintDsc**
-   **redeemCollateral**
-   **burn**
-   **liquidate**

... and much more.

We'll also be recreating all the scripts that you can see in the scripts folder, primarily a deploy script, spiced up to include `Chainlink Pricefeeds`, used to determine the prices of collateral.

## Introduction to stablecoins

Stablecoins have become one of the most talked about topics in the cryptocurrency and blockchain space. However, there is a lot of misleading information out there about what stablecoins really are and how they work. In this lesson, we'll provide a comprehensive overview of stablecoins, clarifying common misconceptions and gleaning a deeper understanding for what makes stablecoins so important in this space.

We hope to cover 5 subjects:

1. What are Stablecoins?
2. Why do we care?
3. Categories and Properties
4. Designs of top Stablecoins
5. What Stablecoins really do

### What Are Stablecoins?

_**A stablecoin is a non-volatile crypto asset.**_

That's really it, at the end of the day. More accurately put:

<img src='./images/stablecoin-introduction/stablecoin-introduction1.png' alt='stablecoin-introduction1' />

**[Investopedia](https://www.investopedia.com/terms/s/stablecoin.asp)** describes `stablecoins` as - Cryptocurrencies the value of which is pegged, or tied, to that of another currency, commodity or financial instrument.

Aaand this is the first place I diverge from conventional media.

This may be a simple way to understand them initially, but `stablecoins` are much more than this.

A `stablecoin` is a crypto asset whose buying power stays relatively stable.

A simple example of unstable buying power is `Bitcoin (BTC)`. The number of apples one could buy with 1BTC 6 months ago is drastically different from how many one could buy today. `Stablecoins`, through a variety of mechanisms we'll discuss later, endeavor to be more similar to a crypto dollar where the number of apples you buy is relatively stable over time.

### Why do we care?

_**Money is important.**_

<img src='./images/stablecoin-introduction/stablecoin-introduction2.png' alt='stablecoin-introduction2' />

Ok, not Scrooge McDuck important.

Society requires an everyday stable currency in order to fulfill the 3 functions of money:

1. Storage of Value
2. Unit of Account
3. Medium of Exchange

**Storage of Value:** Money retains value over time, allowing individuals to save and defer consumption until a later date. This function is crucial because it means money can be saved, retrieved, and spent in the future without losing its purchasing power (assuming stable inflation).

**Unit of Account:** Money provides a standard numerical unit of measurement for the market value of goods, services, and other transactions. It enables consumers and businesses to make informed decisions because prices and costs can be compared. This function helps in record-keeping and allows for the consistent measurement of financial performance.

**Medium of Exchange:** Money serves as an intermediary in trade, making transactions more efficient than bartering. In a barter system, two parties must have exactly what the other wants, known as a double coincidence of wants. Money eliminates this issue by providing a common medium that everyone accepts in exchange for goods and services.

In Web3, we need a Web3 version of this. This is where stablecoins shine. Assets like BTC and ETH do well as stores of value and as mediums of exchange, but fail as a reasonable unit of account due to their buying power volatility.

### Categories and Properties

This is the second place I strongly disagree with most media! When someone searches for `types of stablecoins` you'll often see them grouped into common buckets:

-   Fiat-Collateralized
-   Crypto-Collateralized
-   Commodity-Collateralized
-   Algorithmic

This again is a serviceable understanding of stablecoin categories, but the reality is much more complicated. I prefer to categorize stablecoins as:

1. Relative Stability - Pegged/Anchored or Floating
2. Stability Method - Governed or Algorithmic
3. Collateral Type - Endogenous or Exogenous

**Relative Stability:** Something is only stable relative to its value in something else. The most common type of `stablecoins` are `pegged` or `anchored` `stablecoins`. Their value is determined by their `anchor` to another asset such as the US Dollar. `Tether`, `DAI` and `USDC` are examples of stablecoins which are pegged to USD.

These stablecoins general possess a mechanism which makes them nearly interchangable with the asset to which they're pegged. For example, USDC claims that for each USDC minted, there's an equivalent US Dollar (or equal asset) in a bank account somewhere.

DAI on the other hand, uses permissionless over-colleralization - but we'll get to that later!

As mentioned, stablecoins don't have to be pegged. Even when pegged to a relatively stable asset like the US Dollar, forces such as inflation can reduce buying power over time. A proposed solution (that's albeit much more complex) are floating value stablecoins, where, through clever math and algorithms the buying power of the asset is kept stable overtime without being anchors to another particular asset. We won't go into much detail of these here, but if you're interested in learning more, I encourage you to check out this **[Medium Article on RAI](https://medium.com/intotheblock/rai-a-free-floating-stablecoin-that-actually-works-d9efbbca94c0)**, a free-floating stablecoin.

**Stability Method:** Another major delineating factor of `stablecoins` is the stability method employed. This _is_ the mechanism that keeps the asset's value stable. How is the asset pegged to another?

This usually works by having the `stablecoin` mint and burn in very specific ways and is usually determined by who or what is doing the mint/burn.

This process can exist on a spectrum between `governed` and `algorithmic`.

-   **Governed:** This denotes an entity which ultimately decides if stablecoins in a protocol should be minted or burned. This could something _very_ centralized and controller, like a single person, or more democratic such as governed via DAO. Governed stablecoins are generally considered to be quite centralized. This can be tempered by DAO participations, but we'll get more into how that affects things later
    -   Examples of governed stablecoins include:
        -   USDC
        -   Tether
        -   USDT
-   **Algorithmic:** Conversely, algorithmic stablecoins maintain their stability through a permissionless algorithm with **no human intervention**. I would consider a stablecoin like DAI as being an example of an algorithmic stablecoin for this reason. All an algorithmic stablecoin is, is one which the minting and burning is dictated by autonomous code.
    -   Examples of algorithmic stablecoins include:
        -   DAI
        -   FRAX
        -   RAI
        -   UST - RIP, we'll talk more about this later.

You can see what I mean by spectrum by comparing how some of these tokens function. DAI is a bit of a hybrid where a DAO determines things like interest rates, but the minting/burning is handled autonomously. USDC is an example of something very centralized, with a single governing body, where as UST was almost purely algorithmic.

**[The Dirt Roads blog](https://dirtroads.substack.com/p/-40-pruning-memes-algo-stables-are)** has a great article and visualizations outlining these differences in detail and where popular assets fall on this spectrum.

<img src='./images/stablecoin-introduction/stablecoin-introduction3.png' alt='stablecoin-introduction3' />

> ❗ **NOTE** <br />
> Dirt Roads uses `Dumb` as the opposite of algorithmic, instead of governed.

You'll notice that most Fiat-Collateralized assets are more governed, as you'll often need a centralized entity to onramp the fiat into the blockchain ecosystem.

In summary:

-   Algorithmic Stablecoins use a transparent math equation or autonomously executed code to mint and burn tokens
-   Governed Stablecoins mint and burn tokens via human interaction/decision

**Collateral Type:** When we refer to collateral, we're referring to the asset backing the token, giving it its value. USDC is collateralized by the US Dollar, making one USDC worth one USD. DAI is collateralized by many different assets, you can deposit ETH to mint DAI, among many currencies. UST .. In a round about way was collateralized by LUNA.

These are examples of exogenous and endogenous types of collateral.

-   **Exogenous:** Collateral which originates from outside of a protocol.
-   **Endogenous:** Collateral which originates from within a protocol

The easiest way to determine in which category a stablecoin's collateral falls is the ask this question:

_**If the stablecoin fails, does the underlying collateral also fail?**_

Yes == Endogenous

No == Exogenous

If USDC Fails, the US Dollar isn't going to be affected. USDC is an example of Exogenous collateral. DAI is another example of this, the value of ETH won't be affected by the failure of the DAI protocol.

UST/LUNA on the other hand is an example of Endogenous collateral. When UST failed, LUNA also failed causing the protocol to bleed \$40 billion dollars.

Other good questions to ask include:

_**What the collateral created for the purpose of being collateral?**_

or

_**Does the protocol own the issuance of the underlying collateral?**_

What's misleading about how this is covered by traditional media is that they will point to algorithmic stablecoins as being to blame, but I think this is wrong. The risk exists with endogenously collateralized protocols because their value essentially comes from .. nothing or is self-determined at some point in development.

Endogenously collateralized stablecoins don't have a great track record - TerraLUNA and UST was a catastrophic event that wiped billions out of DeFi. So, why would anyone want to develop a stablecoin like this?

Generally the response is Scale/Capital Efficiency.

When a protocol is entirely exogenously collateralized, its marketcap is limited by the collateral it can onboard into the ecosystem. If no collateral needs to be onboarded into the protocol, scaling becomes easier much faster.

Now, many endogenous stablecoins can be traced back to a single **[paper by Robert Sams](https://blog.bitmex.com/wp-content/uploads/2018/06/A-Note-on-Cryptocurrency-Stabilisation-Seigniorage-Shares.pdf)**. In this paper he discusses how to build an endogenously collateralized stablecoin using a seigniorage shares model. We won't go deeply into the details of this, but it's an incredibly influential paper than a recommend everyone who's interested should read.

### Thought Experiment

Imagine we had a stablecoin, issued by a bank, backed by gold. Our stablecoin is worth the same as its value in gold because at any point we can swap the coin back to the bank in exchange for gold.

Now, what happens if the bank isn't open weekends? What if the bank is closed for a month? At what point does a lack of access to the underlying collateral cease to matter and the asset becomes valued with respect to itself?

In the Dirt Roads image above, this is what is represented by `reflexive`

I know there's a lot of things here conceptually, don't feel discouraged if you want to come back to these ideas to dive further later.

### Top Stablecoins

We won't go too deeply into the architecture of each of these assets, with the exception of maybe DAI, but I wanted to give you a sense of what's out there, what they propose to do and how the propose to do it.

**DAI**

DAI is:

-   Pegged
-   Algorithmic
-   Exogenously Collateralized

DAI is one of the most influential DeFi projects ever created.

Effectively how DAI works is, a user deposits some form of crypto collateral, such as ETH, and based on the current value of that collateral in US Dollars, some value of DAI is minted the user. It's only possible to mint _less_ DAI than the value of collateral a user has deposited. In this way the stablecoin is said to be over-collateralized.

> ❗ **NOTE** <br />
> DAI also has an annual stability fee on deposited collateral \~2%

When a user wants to redeem their collateral, DAI must be deposited back into the protocol, which then burns the deposited DAI and released the appropriate amount of collateral.

The combination of a stability fee and over-collateralization is often referred to as a `collateralized debt position`.

_**What happens if stability fees can't be paid, or the value of our collateral decreases?**_

If this happens, a user is at risk of liquidation. This is the mechanism through which the system avoids becoming under-collateralized.

The fundamental question I hope you're asking at this point is:

_**Why would I pay a fee to mint this stablecoin?**_

We'll get to that soon, I promise. Let's first look at...

**USDC**

USDC is:

-   Pegged
-   Governed
-   Exogenous

USDC is backed by real-world dollars. Simple as that.

**Terra USD(UST)/Terra LUNA**

This situation has become infamous now, but there's lots we can learn from this disaster to prevent it in the future.

UST was:

-   Pegged
-   Algorithmic
-   Endogenous

What we know about stablecoins now should shed some light on what happened to UST/LUNA. Because UST was backed by LUNA, when UST lost it's peg (usually through a massive influx of trading), it's underlying collateral (LUNA) became less attractive to hold .. which caused UST to lose more value. And thus the circling of the drain began until the asset was all but wiped out.

**FRAX**

FRAX is:

-   Pegged
-   Algorithmic
-   Hybrid

Endogenously collateralize stablecoins are so attractive because they _do_ scale quickly. More recent projects, like FRAX, have tried to thread this needle of hybrid collateralization to find an optimal balance.

**RAI**

RAI is:

-   Floating
-   Algorithmic
-   Exogenous

RAI is one of the few examples of a floating stablecoin. The protocol focuses on 3 things

-   minimal governance, achieved through algorithmic mechanisms of stabilization
-   Being Floating, such that it's value isn't derived by being tied to another asset
-   Only using ETH as collateral

You can read more about the mechanisms of RAI **[here](https://medium.com/intotheblock/rai-a-free-floating-stablecoin-that-actually-works-d9efbbca94c0)**.

With all this context and understanding in mind, we've got one thing left to cover.

### What do stablecoins really do?

Maybe we start with asking: **Which is the** _**best**_ **stablecoin?**

The answer to this may come down to about whom we're speaking.

Stablecoins, which are centralized, such as USDC, Tether etc, may not really fit the ethos of decentralization in Web3, it might be preferred to have a degree of decentrality.

By the same token (pun intended), algorithmic stablecoins may be intimidating to the average user and the associated fees may be non-starters.

At the end of the day every stablecoin protocol has it's trade-offs and what's right for one person or circumstance may not be right for another.

Now, here's something that may give you whiplash:

_**The stablecoin preferred by the average user, is likely much less important than those preferred by the 'rich whales' in the space**_

<img src='./images/stablecoin-introduction/stablecoin-introduction4.png' alt='stablecoin-introduction4' />

Let me explain with another thought experiment.

### Thought Experiment 2

Say you want to accumulate a tonne of ETH, you've solve everything you own and put it all into ETH, but you want more. How do you accomplish this?

By depositing ETH as collateral into a stablecoin protocol, you're able to mint the stablecoin, and sell it for more ETH. This becomes beneficial when you consider leveraged trading.

**Leveraged Trading:** Leveraged trading involves using borrowed capital to increase the potential return on investment. This strategy can magnify both gains and losses, allowing for potentially higher profits but also increased risk.

This usecase for high-value investing is so pervasive that it's often outlined by platforms as a primary reason to mint, to maximize your position on a crypto asset.

So, to summarize a bit:

_**Why are stablecoins used?**_

-   To execute the 3 functions of money.

_**Why are stablecoins minted?**_

-   Investors like to make leveraged bets.

### Wrap Up

We've learnt a lot here, and we've only just scratched the surface of DeFi. To sophisticated investors many of the concepts I've covered here may actually be old news. This is common practice in the TradFi space and Web3 employs these same financial mechanisms and incentives.

With protocols like Aave and Curve considering their own stablecoin offerings, I believe things are going to get really interesting. As the industry matures, I believe the development of stablecoins will only improve from the perspectives of functionality and security because they're an essential part of the financial ecosystem in Web3.

For those developers who want to try building their own, there are some minimalistic examples you can check out on the **[defi-minimal GitHub Repo](https://github.com/smartcontractkit/defi-minimal)**.

I'm super excited for the future of DeFi and stablecoins. Let's get started creating our very own.

## DecentralizedStableCoin.sol

Let's start by making our project directory.

```bash
mkdir foundry-defi-stablecoin
cd foundry-defi-stablecoin
code .
```

With the directory open in VSCode, we can initialize a new Foundry project.

```bash
forge init
```

Finally, remove the placeholder example contracts `src/Counter.sol`, `script/Counter.s.sol`, and `test/Counter.t.sol`.

Our stablecoin is going to be:

1. Relative Stability: Anchored or Pegged to the US Dollar
    1. Chainlink Pricefeed
    2. Function to convert ETH & BTC to USD
2. Stability Mechanism (Minting/Burning): Algorithmicly Decentralized
    1. Users may only mint the stablecoin with enough collateral
3. Collateral: Exogenous (Crypto)
    1. wETH
    2. wBTC

To add some context to the above, we hope to create our stablecoin in such a way that it is pegged to the US Dollar. We'll achieve this by leveraging chainlink pricefeeds to determine the USD value of deposited collateral when calculating the value of collateral underlying minted tokens.

The token should be kept stable through this collateralization stability mechanism.

For collateral, the protocol will accept wrapped Bitcoin and wrapped Ether, the ERC20 equivalents of these tokens.

Alright, with things scoped out a bit, let's dive into writing some code. Start by creating the file `src/DecentralizedStableCoin.sol`. I'm hoping to make this as professional as possible, so I'm actually going to paste my contract and function layouts as a reference to the top of this file.

```solidity
// SPDX-License-Identifier: MIT

// This is considered an Exogenous, Decentralized, Anchored (pegged), Crypto Collateralized low volatility coin

// Layout of Contract:
// version
// imports
// interfaces, libraries, contracts
// errors
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions
```

When I wrote this codebase, I intended to get it audited, and I did! You can actually see the audit results **[here](https://www.codehawks.com/contests/cljx3b9390009liqwuedkn0m0)**. For this reason, something different you may notice about this codebase is how _verbose_ we're going to be. When it comes to security and having auditors review our code, the clearer we are in explaining the code and added context to our goals, the easier their lives are going to be keeping us secure.

With that said, our contract boilerplate is going to be set up similarly to everything we've been doing so far. Let's add some NATSPEC to outline the contracts purpose.

```solidity
pragma solidity ^0.8.18;

/*
    * @title: DecentralizedStableCoin
    * @author: MRAlirad
    * Collateral: Exogenous (ETH & BTC)
    * Minting: Algorithmic
    * Relative Stability: Pegged to USD
    *
    * This is the contract meant to be governed by DSCEngine. This contract is just the ERC20 implementation of our stablecoin system.
    */
contract DecentralizedStableCoin {}
```

This contract is effectively just going to be a fairly standard ERC20 to function as the asset for our stablecoin protocol. All of the logic for the protocol will be handled by DSCEngine.sol. We'll need OpenZeppelin to get started.

```bash
forge install openzeppelin/openzeppelin-contracts@v4.8.3 --no-commit
```

And of course, we can add our remappings to our
`foundry.toml`.

```toml
[profile.default]
src = "src"
out = "out"
libs = ["lib"]
remappings = ["@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts"]
```

Rather than importing a standard ERC20 contract, we'll be leveraging the ERC20Burnable extension of this standard. ERC20Burnable includes `burn` functionality for our tokens which will be important when we need to take the asset out of circulation to support stability.

```solidity
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {ERC20Burnable, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

/*
 * @title: DecentralizedStableCoin
 * @author: MRAlirad
 * Collateral: Exogenous (ETH & BTC)
 * Minting: Algorithmic
 * Relative Stability: Pegged to USD
 *
 * This is the contract meant to be governed by DSCEngine. This contract is just the ERC20 implementation of our stablecoin system.
 */
contract DecentralizedStableCoin is ERC20Burnable {
    constructor() ERC20("DecentralizedStableCoin", "DSC"){}
}
```

Because we're inheriting ERC20Burnable, and it inherits ERC20, we need to satisfy the standard ERC20 constructor parameters within our contracts constructor. We've set the name `DecentralizedStableCoin` and the symbol `DSC`.

All of the properties of our protocol are going to be governed ultimately by the DSCEngine.sol contract. Functionality like the stability mechanism, including minting and burning, need to be controlled by the DSCEngine to maintain the integrity of the stablecoin.

In order to accomplish this, we're going to also inherit `Ownable` with DecentralizedStableCoin.sol. This will allow us to configure access control, assuring only our DSCEngine contract is authorized to call these functions.

> ❗ **NOTE** <br />
> For version 5 of OpenZeppelin's Ownable contract, we need to pass an address
> in the constructor. We have to modify our code to account for this when
> running `forge build` so that our project will not error. Like this:
> `constructor(address initialOwner) ERC20("DecentralizedStableCoin", "DSC")
Ownable(initialOwner) {}`

```solidity
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

...

contract DecentralizedStableCoin is ERC20Burnable, Ownable {
    constructor() ERC20("DecentralizedStableCoin", "DSC"){}
}
```

The two major functions we're going to want the DSCEngine to control are of course the mint and burn functions. We can override the standard ERC20 functions with our own to assure this access control is in place.

### Burn

We can start by writing our burn function.

```solidity
function burn(uint256 _amount) external override onlyOwner{}
```

We're going to want to check for two things when this function is called.

1. The amount burnt must not be less than zero
2. The amount burnt must not be more than the user's balance

We'll configure two custom errors for when these checks fail.

```solidity
contract DecentralizedStableCoin is ERC20Burnable, Ownable {
    error DecentralizedStableCoin__MustBeMoreThanZero();
    error DecentralizedStableCoin__BurnAmountExceedsBalance();

    constructor() ERC20("DecentralizedStableCoin", "DSC"){}

    function burn(uint256 _amount) external override onlyOwner{
        uint256 balance = balanceOf(msg.sender);
        if(_amount <= 0){
            revert DecentralizedStableCoin__MustBeMoreThanZero();
        }
        if(balance < _amount){
            revert DecentralizedStableCoin__BurnAmountExceedsBalance();
        }
    }
}
```

The last thing we're going to do, assuming these checks pass, is burn the passed amount of tokens. We're going to do this by using the `super` keyword. This tells solidity to use the burn function of the parent class.

```solidity
function burn(uint256 _amount) external override onlyOwner{
    uint256 balance = balanceOf(msg.sender);
    if(_amount <= 0){
        revert DecentralizedStableCoin__MustBeMoreThanZero();
    }
    if(balance < _amount){
        revert DecentralizedStableCoin__BurnAmountExceedsBalance();
    }
    super.burn(_amount);
}
```

### Mint

The second function we'll need to override to configure access control on is going to be our mint function.

```solidity
function mint(address _to, uint256 _amount) external overrides onlyOwner returns(bool){
}
```

So, in this function we want to configure a boolean return value which is going to represent if the mint/transfer was successful. Something we'll want to check is if the \_to argument being passed is address(0), in addition to assuring the amount minted is greater than zero.

We'll of course want to revert with custom errors if these conditional checks fail.

```solidity
contract DecentralizedStableCoin is ERC20Burnable, Ownable {
    error DecentralizedStableCoin__MustBeMoreThanZero();
    error DecentralizedStableCoin__BurnAmountExceedsBalance();
    error DecentralizedStableCoin__NotZeroAddress();

    ...

    function mint(address _to, uint256 _amount) external onlyOwner returns(bool){
        if(_to == address(0)){
            revert DecentralizedStableCoin__NotZeroAddress();
        }
        if(_amount <= 0){
            revert DecentralizedStableCoin__MustBeMoreThanZero();
        }
        _mint(_to, amount)
        return true;
    }
}
```

> ❗ **NOTE** <br />
> We don't need to override the mint function, we're just calling the \_mint function within DecentralizedStableCoin.sol.

## DSCEngine.sol Setup

Alright! It's time to build out the engine to this car. `DSCEngine` will be the heart of the protocol which manages all aspects of `minting`, `burning`, `collateralizing` and `liquidating` within our protocol.

We're going to build this a little differently than usual, as we'll likely be writing tests as we go. As a codebase becomes more and more complex, it's often important to perform sanity checks along the way to assure you're still on track.

Begin with creating a new file, `src/DSCEngine.sol`. I'll bring over my contract and function layout reference and we can se up our boilerplate.

```solidity
// SPDX-License-Identifier: MIT

// This is considered an Exogenous, Decentralized, Anchored (pegged), Crypto Collateralized low volatility coin

// Layout of Contract:
// version
// imports
// interfaces, libraries, contracts
// errors
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

pragma solidity ^0.8.18;

contract DSCEngine {}
```

Time for NATSPEC, remember, we want to be as verbose and clear in presenting what our code is meant to do.

```solidity
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
 * Our DSC system should always be "overcollateralized". At no point, should the value of
 * all collateral < the $ backed value of all the DSC.
 *
 * @notice This contract is the core of the Decentralized Stablecoin system. It handles all the logic
 * for minting and redeeming DSC, as well as depositing and withdrawing collateral.
 * @notice This contract is based on the MakerDAO DSS system
 */
contract DSCEngine {}
```

> ❗ **IMPORTANT** <br />
> Verbosity.

I know this may seem like a lot, but a common adage is: `Your code will be written once, and read thousands of times.` Clarity and cleanliness in code is important to provide context and understanding to those reading the codebase later.

### Functions

At this point in writing a contract, some will actually start by creating an interface. This can serve as a clear, itemized list of methods and functionality which you expect to be included within your contract. We'll just add our function "shells" into our contract directly for now.

Let's consider what functions will be required for DSC.

We will need:

-   Deposit collateral and mint the `DSC` token
    -   This is how users acquire the stablecoin, they deposit collateral greater than the value of the `DSC` minted
-   Redeem their collateral for `DSC`
    -   Users will need to be able to return DSC to the protocol in exchange for their underlying collateral
-   Burn `DSC`
    -   If the value of a user's collateral quickly falls, users will need a way to quickly rectify the collateralization of their `DSC`.
-   The ability to `liquidate` an account
    -   Because our protocol must always be over-collateralized (more collateral must be deposited then `DSC` is minted), if a user's collateral value falls below what's required to support their minted `DSC`, they can be `liquidated`. Liquidation allows other users to close an under-collateralized position
-   View an account's `healthFactor`
    -   `healthFactor` will be defined as a certain ratio of collateralization a user has for the DSC they've minted. As the value of a user's collateral falls, as will their `healthFactor`, if no changes to `DSC` held are made. If a user's `healthFactor` falls below a defined threshold, the user will be at risk of liquidation.
        -   eg. If the threshold to `liquidate` is 150% collateralization, an account with $75 in ETH can support $50 in `DSC`. If the value of ETH falls to \$74, the `healthFactor` is broken and the account can be `liquidated`

To summarize how we expect the protocol to function a bit:

Users will deposit collateral greater in value than the `DSC` they mint. If their collateral value falls such that their position becomes `under-collateralized`, another user can liquidate the position, by paying back/burning the `DSC` in exchange for the positions collateral. This will net the liquidator the difference in the `DSC` value and the collateral value in profit as incentive for securing the protocol.

In addition to what's outlined above, we'll need some basic functions like `mint/deposit` etc to give users more granular control over their position and account `healthFactor`.

```solidity
contract DSCEngine {

///////////////////
//   Functions   //
///////////////////

///////////////////////////
//   External Functions  //
///////////////////////////
    function depositCollateralAndMintDsc() external {}

    function depositCollateral() external {}

    function redeemCollateralForDsc() external {}

    function redeemCollateral() external {}

    function mintDsc() external {}

    function burnDsc() external {}

    function liquidate() external {}

    function getHealthFactor() external view {}
}
```

## Create the deposit collateral function

I think the easiest place to start with filling out the contract is going to be depositCollateral. This makes sense to me since it'll surely be one of the first places a user interacts with our protocol.

To deposit collateral, users are going to need the address for the type of collateral they're depositing (wETH or wBTC), and the amount they want to deposit. Easy enough.

> ❗ **NOTE** <br />
> Don't forget the NATSPEC!

```solidity
///////////////////
//   Functions   //
///////////////////

///////////////////////////
//   External Functions  //
///////////////////////////

/*
 * @param tokenCollateralAddress: The ERC20 token address of the collateral you're depositing
 * @param amountCollateral: The amount of collateral you're depositing
 */
function depositCollateral(address tokenCollateralAddress, uint256 amountCollateral) external {

}
```

Now, the first thing I consider when I see a function passing values like this is sanitization. There are always going to be considerations for the parameters being passed to public functions that we should account for. For example, it's often inappropriate for address(0) to be passed, or negative numbers etc.

It's likely that many functions in a protocol will require this kind of sanitation and rather than rewriting conditionals a dozen times, we should leverage modifiers.

Our function layout reference says modifiers should come before our functions, so let's adhere to that. We'll need a new error is well.

```solidity

contract DSCEngine {

    ///////////////////
    //     Errors    //
    ///////////////////

    error DSCEngine__NeedsMoreThanZero();

    ///////////////////
    //   Modifiers   //
    ///////////////////

    modifier moreThanZero(uint256 amount){
        if(amount <=0){
            revert DSCEngine__NeedsMoreThanZero();
        }
    }

...

}
```

This looks great! This should assure that the amount of collateral passed to our depositCollateral function is greater than zero. The other parameter of this function is the tokenCollateralAddress. Since we're only meaning to support wETH and wBTC, we should make a second modifier to assure only these allowed tokens are deposited as collateral.

```solidity
modifier isAllowedToken(address token){

}
```

Currently, we don't have any reference to use in our conditional for this modifier. We'll need to create a mapping as a state variable to track the tokens which are compatible with our protocol.

We know we're going to be using chainlink pricefeeds, so what we can do is have this mapping be a token address, to it's associated pricefeed. In our modifier, if a pricefeed isn't found for the passed token address, it'll revert!

```solidity
/////////////////////////
//   State Variables   //
/////////////////////////

mapping(address token => address priceFeed) private s_priceFeeds;
```

We'll probably want to initialize this mapping in our contract's constructor. To do this, we'll have our constructor take a list of token addresses and a list of priceFeed addresses, each index of one list will be mapped to the respective index of the other on deployment. We also know that the DSCEngine is going to need to know about the DecentralizeStablecoin contract. With all this in mind, let's set up our constructor.

```solidity
///////////////////
//   Functions   //
///////////////////
constructor(address[] memory tokenAddresses, address[] memory priceFeedAddresses, address dscAddress){}
```

Here's where we should definitely perform a sanity check, since a contract is only constructed once. If the indexes of our lists are meant to be mapped to each other, we should assure the lengths of the lists match, and if they don't we can revert with another custom error.

```solidity
///////////////////
//     Errors    //
///////////////////

error DSCEngine__NeedsMoreThanZero();
error DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength();

...

///////////////////
//   Functions   //
///////////////////
constructor(address[] memory tokenAddresses, address[] memory priceFeedAddresses, address dscAddress){
    if(tokenAddresses.length != priceFeedAddresses.length){
        revert DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength();
    }
}
```

Now we can add our for loop which will map our two lists of addresses to each other.

```solidity
///////////////////
//   Functions   //
///////////////////
constructor(address[] memory tokenAddresses, address[] memory priceFeedAddresses, address dscAddress){
    if(tokenAddresses.length != priceFeedAddresses.length){
        revert DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength();
    }

    for(uint256 i=0; i < tokenAddresses.length; i++){
        s_priceFeeds[tokenAddresses[i]] = priceFeedAddresses[i];
    }
}
```

We're going to be doing lots with our `dscEngine`. We should declare this as an immutable variable and then assign it in our constructor.

> ❗ **NOTE**
> Don't forget to import `DecentralizedStableCoin.sol`!

```solidity
import {DecentralizedStableCoin} from "DecentralizedStableCoin.sol";

...

/////////////////////////
//   State Variables   //
/////////////////////////

mapping(address token => address priceFeed) private s_priceFeeds;
DecentralizedStableCoin private immutable i_dsc;

...

///////////////////
//   Functions   //
///////////////////
constructor(address[] memory tokenAddresses, address[] memory priceFeedAddresses, address dscAddress){
    if(tokenAddresses.length != priceFeedAddresses.length){
        revert DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength();
    }

    for(uint256 i=0; i < tokenAddresses.length; i++){
        s_priceFeeds[tokenAddresses[i]] = priceFeedAddresses[i];
    }
    i_dsc = DecentralizedStableCoin(dscAddress);
}
```

Remember, we were doing all this because we need a new modifier that checks our token addresses! Now that things are established in our constructor, we can write this modifier.

```solidity

contract DSCEngine {

    ///////////////////
    //     Errors    //
    ///////////////////

    error DSCEngine__NeedsMoreThanZero();
    error DSCEngine__TokenNotAllowed(address token);

    ///////////////////
    //   Modifiers   //
    ///////////////////

    modifier moreThanZero(uint256 amount){
        if(amount <=0){
            revert DSCEngine__NeedsMoreThanZero();
        }
        _;
    }

    modifier isAllowedToken(address token) {
        if (s_priceFeeds[token] == address(0)) {
            revert DSCEngine__TokenNotAllowed(token);
        }
        _;
    }

...

}
```

Great! Now, coming all the way back to our functions (told you we'd be moving fast!), we can add these newly created modifiers to `depositCollateral`.

```solidity
///////////////////////////
//   External Functions  //
///////////////////////////

/*
 * @param tokenCollateralAddress: The ERC20 token address of the collateral you're depositing
 * @param amountCollateral: The amount of collateral you're depositing
 */
function depositCollateral(address tokenCollateralAddress, uint256 amountCollateral) external moreThanZero(amountCollateral) isAllowedToken(tokenCollateralAddress) nonReentrant{}
```

I've additionally included the nonReentrant modifier, which we'll need to import from OpenZeppelin. When interacting with external contracts it's often good to consider the implications of reentrancy. Reentrancy is one of the most common and damaging attacks in all of Web3, and sometimes I'll throw this modifier on as a _**better safe than sorry**_ methodology. It may not explicitly be required, but we'll find out when this code goes to audit! The trade off to include it is an expense of gas required to perform these extra checks.

Let's add the import to our contract.

> ❗ **NOTE**
> In version 5 of OpenZeppelin's contracts library, `ReentrancyGuard.sol` is
> in a different location. Edit the filepath from `/security/` to `/utils/` will
> work.

```solidity
pragma solidity ^0.8.18;

import {DecentralizedStableCoin} from "DecentralizedStableCoin.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

...

contract DSCEngine is ReentrancyGuard {
    ...
}
```

Whew, all this and we haven't even started the function body yet! Let's start working with the deposited collateral. We'll need a way to keep track of the collateral deposited by each user. This sounds like a mapping to me.

```solidity
/////////////////////////
//   State Variables   //
/////////////////////////

mapping(address token => address priceFeed) private s_priceFeeds;
DecentralizedStableCoin private immutable i_dsc;
mapping(address user => mapping(address token => uint256 amount)) private s_collateralDeposited;
```

Now we can finally add the deposited collateral to our user's balance within our depositCollateral function.

```solidity
///////////////////////////
//   External Functions  //
///////////////////////////

/*
 * @param tokenCollateralAddress: The ERC20 token address of the collateral you're depositing
 * @param amountCollateral: The amount of collateral you're depositing
 */
function depositCollateral(address tokenCollateralAddress, uint256 amountCollateral) external moreThanZero(amountCollateral) isAllowedToken(tokenCollateralAddress) nonReentrant{
    s_collateralDeposited[msg.sender][tokenCollateralAddress] += amountCollateral;
}
```

When we're changing the balance of our user's deposited collateral, what are we doing? We're updating our contract state! Any time state is changed, we should absolutely emit an event. Our contract layout tells us that events should be declared beneath our state variables. So, let's go ahead and declare this event and emit it in our depositCollateral function.

```solidity
////////////////
//   Events   //
////////////////

event CollateralDeposited(address indexed user, address indexed token, uint256 indexed amount);

...

///////////////////////////
//   External Functions  //
///////////////////////////

/*
 * @param tokenCollateralAddress: The ERC20 token address of the collateral you're depositing
 * @param amountCollateral: The amount of collateral you're depositing
 */
function depositCollateral(address tokenCollateralAddress, uint256 amountCollateral) external moreThanZero(amountCollateral) isAllowedToken(tokenCollateralAddress) nonReentrant{
    s_collateralDeposited[msg.sender][tokenCollateralAddress] += amountCollateral;
    emit CollateralDeposited(msg.sender, tokenCollateralAddress, amountCollateral);
}
```

Our function so far is doing a great job adhering to CEI (Checks, Effects, Interactions). The checks we're performing are being executed by our modifiers, our effects are any changes to do with internal accounting or state changes, and effects will be our external interacts (transferring the tokens). Following this design pattern is the best way to protect yourself from reentrancy.

Let's add our interactions to the function now, we'll need to call transferFrom on wBTC or wETH. These are ERC20s remember, so let's import an interface to use.

```solidity
pragma solidity ^0.8.18;

import {DecentralizedStableCoin} from "DecentralizedStableCoin.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

...

///////////////////////////
//   External Functions  //
///////////////////////////

/*
 * @param tokenCollateralAddress: The ERC20 token address of the collateral you're depositing
 * @param amountCollateral: The amount of collateral you're depositing
 */
function depositCollateral(address tokenCollateralAddress, uint256 amountCollateral) external moreThanZero(amountCollateral) isAllowedToken(tokenCollateralAddress) nonReentrant{
    s_collateralDeposited[msg.sender][tokenCollateralAddress] += amountCollateral;
    emit CollateralDeposited(msg.sender, tokenCollateralAddress, amountCollateral);

    IERC20(tokenCollateralAddress).transferFrom(msg.sender, address(this), amountCollateral);
}
```

One last thing to note in this function - our transferFrom call actually returns a boolean. We want to assure this transfer is successful, otherwise revert this function call. One last conditional to add...

```solidity
bool success = IERC20(tokenCollateralAddress).transferFrom(msg.sender, address(this), amountCollateral);

if(!success){
    revert DSCEngine__TransferFailed();
}
```

...and one last custom error:

```solidity

contract DSCEngine {

    ///////////////////
    //     Errors    //
    ///////////////////

    error DSCEngine__TokenAddressesAndPriceFeedAddressesAmountsDontMatch();
    error DSCEngine__NeedsMoreThanZero();
    error DSCEngine__TokenNotAllowed(address token);
    error DSCEngine__TransferFailed();

    ...

}
```

### Wrap Up

This function is looking pretty dang great! We've finished writing depositCollateral which allows users to .. deposit collateral .. but it does so much more! We've written modifier to sanitize our function inputs as well as employed best practice design patterns like CEI and events to keep things secure.

This may be a good place to start writing some tests to make sure everything written so far is performing as expected, but let's write a few more functions before getting into that.

I've left our DSCEngine.sol (up to this point in the lesson) below for reference. Over the next few lessons, I'll continue to include this contract in it's entirety for reference.

See you in the next lesson!

DSCEngine.sol

```solidity
// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// internal & private view & pure functions
// external & public view & pure functions

// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { DecentralizedStableCoin } from "./DecentralizedStableCoin.sol";

/*
 * @title DSCEngine
 * @author Patrick Collins
 *
 * The system is designed to be as minimal as possible, and have the tokens maintain a 1 token == $1 peg at all times.
 * This is a stablecoin with the properties:
 * - Exogenously Collateralized
 * - Dollar Pegged
 * - Algorithmically Stable
 *
 * It is similar to DAI if DAI had no governance, no fees, and was backed by only WETH and WBTC.
 *
 * Our DSC system should always be "overcollateralized". At no point, should the value of
 * all collateral < the $ backed value of all the DSC.
 *
 * @notice This contract is the core of the Decentralized Stablecoin system. It handles all the logic
 * for minting and redeeming DSC, as well as depositing and withdrawing collateral.
 * @notice This contract is based on the MakerDAO DSS system
 */
contract DSCEngine is ReentrancyGuard {

    ///////////////////
    //     Errors    //
    ///////////////////

    error DSCEngine__TokenAddressesAndPriceFeedAddressesAmountsDontMatch();
    error DSCEngine__NeedsMoreThanZero();
    error DSCEngine__TokenNotAllowed(address token);
    error DSCEngine__TransferFailed();

    /////////////////////////
    //   State Variables   //
    /////////////////////////

    mapping(address token => address priceFeed) private s_priceFeeds;
    DecentralizedStableCoin private immutable i_dsc;
    mapping(address user => mapping(address token => uint256 amount)) private s_collateralDeposited;

    ////////////////
    //   Events   //
    ////////////////

    event CollateralDeposited(address indexed user, address indexed token, uint256 indexed amount);

    ///////////////////
    //   Modifiers   //
    ///////////////////

    modifier moreThanZero(uint256 amount){
        if(amount <=0){
            revert DSCEngine__NeedsMoreThanZero();
        }
        _;
    }

    modifier isAllowedToken(address token) {
        if (s_priceFeeds[token] == address(0)) {
            revert DSCEngine__TokenNotAllowed(token);
        }
        _;
    }

    ///////////////////
    //   Functions   //
    ///////////////////
    constructor(address[] memory tokenAddresses, address[] memory priceFeedAddresses, address dscAddress){
        if(tokenAddresses.length != priceFeedAddresses.length){
            revert DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength();
        }

        for(uint256 i=0; i < tokenAddresses.length; i++){
            s_priceFeeds[tokenAddresses[i]] = priceFeedAddresses[i];
        }
        i_dsc = DecentralizedStableCoin(dscAddress);
    }


    ///////////////////////////
    //   External Functions  //
    ///////////////////////////

    /*
     * @param tokenCollateralAddress: The ERC20 token address of the collateral you're depositing
     * @param amountCollateral: The amount of collateral you're depositing
     */
    function depositCollateral(
        address tokenCollateralAddress,
        uint256 amountCollateral
    )
        external
        moreThanZero(amountCollateral)
        nonReentrant
        isAllowedToken(tokenCollateralAddress)
    {
        s_collateralDeposited[msg.sender][tokenCollateralAddress] += amountCollateral;
        emit CollateralDeposited(msg.sender, tokenCollateralAddress, amountCollateral);
        bool success = IERC20(tokenCollateralAddress).transferFrom(msg.sender, address(this), amountCollateral);
        if (!success) {
            revert DSCEngine__TransferFailed();
        }
    }

    function depositCollateralAndMintDsc() external {}

    function redeemCollateralForDsc() external {}

    function redeemCollateral() external {}

    function mintDsc() external {}

    function burnDsc() external {}

    function liquidate() external {}

    function getHealthFactor() external view {}
}
```
