// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IExtendedLedger.sol";

/// @title Swap contract for Payment Ledger
/// @author 0xdellwatson
/// @notice A swap contract against ledger's currency
/// it's actually better to DIFFERENTIATE each LIQUIDITY POOL
/// but right now using this contract address as the pool
/// might need to add fn WITHDRAW erc20?
// note update the events more accurately for each IN and OUT differences
contract SwapContract is Ownable {
    using SafeERC20 for IERC20;

    event TokensSwapped(address indexed user, uint256 amountOut);
    // / Optionally, emit an event to log the addition of PoolDetails
    event PoolDetailsAdded(
        uint256 poolId,
        address tokenAddress,
        string tokenName
    );

    /*------------------- STRUCTS -------------------*/

    /// @notice List information of a available pool to swap
    /// @dev As we dont want any ERC20 token to be able swapped with ledger's currency (meme token etc)
    /// @param id id of pool
    /// @param fee fee of using this pool
    /// @param minAmount min amount for this pool
    /// @param maxAmount max amount for this pool
    /// @param tokenAddress address of the token WETH, WBTC, WABC
    /// @param aggregatorAddress aggregator data price we use
    /// @param tokenName aggregator pool name (WETH/USD BTC/USD)
    /// having string is fine since it's not that many we stored this pool, and often
    /// unless having ERC20-ERC20 without against ledger's currency, WETH/WBTC (incase we are in USD)
    struct PoolDetails {
        uint256 id;
        uint256 fee;
        uint256 minAmount;
        uint256 maxAmount;
        address tokenAddress;
        address aggregatorAddress;
        string tokenName;
    }

    /*------------------- STATE VARIABLES -------------------*/

    // track info pool
    mapping(IERC20 => PoolDetails) private s_poolDetailsByAddress;
    // the equivalent currency we use in ledger,
    // or we can set the ledger as well since it has balanceOf
    // but we need our own oracle to deploy so we know the rate of other WETH/LEDGER
    IERC20 public s_tokenCurrency; // aka ledger's currency equivalent with ?
    address internal s_protocol; // should be ledger's contract
    uint256 internal s_minAmount; //in 1e18 -> usd | tokenCurrency
    uint256 private nextPoolId;

    /*------------------- MODIFIER -------------------*/

    modifier onlyProtocol() {
        require(
            msg.sender == s_protocol,
            "Only A Protocol can call this function"
        );
        _;
    }

    // todo :add multi tokens here? and store the each mapping liquidity?
    constructor(address _currency, address _protocol) Ownable(msg.sender) {
        // set base currency
        s_tokenCurrency = IERC20(_currency);

        // Initialize the counter to a starting value (e.g., 1)
        nextPoolId = 1;

        // set ledger protocol
        s_protocol = _protocol;
    }

    /*------------------- ONLY OWNER -------------------*/

    /// @notice changing protocol or ledger
    /// @param _protocolAddress a new protocol address
    function changeProtocol(address _protocolAddress) external onlyOwner {
        s_protocol = _protocolAddress;
    }

    /// @notice detail pool token we use here
    /// @param _fee a parameter just like in doxygen (must be followed by parameter name)
    /// @param _minAmount a parameter just like in doxygen (must be followed by parameter name)
    /// @param _maxAmount a parameter just like in doxygen (must be followed by parameter name)
    /// @param _tokenAddress a parameter just like in doxygen (must be followed by parameter name)
    /// @param _aggregatorAddress a parameter just like in doxygen (must be followed by parameter name)
    /// @param _tokenName a parameter just like in doxygen (must be followed by parameter name)
    /// todo add pause system
    function addPoolDetails(
        uint256 _fee,
        uint256 _minAmount,
        uint256 _maxAmount,
        address _tokenAddress,
        address _aggregatorAddress,
        string calldata _tokenName
    ) external onlyOwner {
        // Create a new PoolDetails instance
        PoolDetails memory newPoolDetails = PoolDetails({
            id: getNextPoolId(), // refer function to generate unique pool IDs
            fee: _fee,
            minAmount: _minAmount,
            maxAmount: _maxAmount,
            tokenAddress: _tokenAddress,
            aggregatorAddress: _aggregatorAddress,
            tokenName: _tokenName
            // isPaused?
        });

        // Store the new PoolDetails in the mapping using the token address as the key
        s_poolDetailsByAddress[IERC20(_tokenAddress)] = newPoolDetails;

        //  emit the events
        emit PoolDetailsAdded(newPoolDetails.id, _tokenAddress, _tokenName);
    }

    /*------------------- PUBLIC FUNCTIONS -------------------*/

    /// @notice return the price from oracle against ledger's currency
    /// @param _tokenAddress the ERC20 available in the pool
    /// @return uint256 direct answer from aggregator
    /// @return uint256 formatted price answer
    function checkPrice(IERC20 _tokenAddress)
        public
        view
        returns (uint256, uint256)
    {
        PoolDetails memory poolDetails = s_poolDetailsByAddress[_tokenAddress];
        require(
            address(poolDetails.aggregatorAddress) != address(0),
            "Aggregator not set for token"
        );

        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            poolDetails.aggregatorAddress
        );

        // // Get the latest price from the Chainlink aggregator
        (
            uint80 roundID,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();

        uint256 decimals = priceFeed.decimals();

        return (
            uint256(answer),
            (uint256(answer) / (10**uint256(decimals))) * 1e18
        );
    }

    /// @notice another helper function to see how much user will receive
    /// @param _tokenHave is the token user have (either erc20 or ledger's currency)
    /// @param _amountHave is the value user have
    /// @param _tokenHave is the token user desired
    /// @return uint256 token input
    /// @return uint256 token ouput
    function checkSwap(
        IERC20 _tokenHave,
        uint256 _amountHave,
        IERC20 _tokenWant
    ) public view returns (uint256, uint256) {
        // Check if tokenHave user have Ledger's currency
        // means the user wants have their balance in ledger
        // and wants ERC20 WETH or any ERC20
        if (_tokenHave == s_tokenCurrency) {
            // Check if _tokenWant is included in the pool
            PoolDetails memory poolDetailsWant = s_poolDetailsByAddress[
                _tokenWant
            ];
            require(
                address(poolDetailsWant.aggregatorAddress) != address(0),
                "Token is not available"
            );

            // get price
            (, uint256 tokenPrice) = checkPrice(_tokenWant);

            // Calculate the amount of ERC20 user will received
            // amount of ledger's currency need to be managed later
            uint256 amountCurrency = (_amountHave * 1e18) / tokenPrice;

            return (_amountHave, amountCurrency);
        } else {
            // Check if _tokenHave is included in the pool
            PoolDetails memory poolDetailsHave = s_poolDetailsByAddress[
                _tokenHave
            ];
            require(
                address(poolDetailsHave.aggregatorAddress) != address(0),
                "Token is not accepted"
            );

            // get price
            (, uint256 tokenPrice) = checkPrice(_tokenHave);

            // amount of ledger's currency user will get in the ledger
            uint256 amountCurrency = (_amountHave / 1e18) * tokenPrice;

            return (_amountHave, amountCurrency);
        }
    }

    /*------------------- EXTERNAL FUNCTIONS -------------------*/

    /// @notice Swap token against ledger's currency
    /// @dev
    /// @param _tokenHave is the token user have (either erc20 or ledger's currency)
    /// @param _amountHave is the value user have
    /// @param _tokenHave is the token user desired
    /// amountHave must be in 1e18 same as with ledger's amount
    /// todo refactor and split the function swapIN swapOUT instead?
    function swap(
        IERC20 _tokenHave,
        uint256 _amountHave,
        IERC20 _tokenWant
    ) external {
        // Check if tokenHave user have Ledger's currency
        // means the user wants have their balance in ledger
        // and wants ERC20 WETH or any ERC20
        if (_tokenHave == s_tokenCurrency) {
            // Check if _tokenWant is included in the pool
            PoolDetails memory poolDetailsWant = s_poolDetailsByAddress[
                _tokenWant
            ];
            require(
                address(poolDetailsWant.aggregatorAddress) != address(0),
                "Token is not available"
            );

            // balance actually will be check inside IExtendedLedger.transfFrom()
            uint256 balance = IExtendedLedger(s_protocol).balanceOf(msg.sender);
            require(balance > _amountHave, "Insufficient Ledger's Balance");

            // reject if out of minimum
            // todo: use min amount from poolDetails instead
            require(
                _amountHave > s_minAmount,
                "Lower than minimum requirement"
            );

            // get price
            (, uint256 tokenPrice) = checkPrice(_tokenWant);

            // Calculate the amount of ERC20 user will received
            // amount of ledger's currency need to be managed later
            uint256 amountERC20 = (_amountHave * 1e18) / tokenPrice;

            // check liquidity
            uint256 liquidity = IERC20(_tokenWant).balanceOf(address(this));
            require(liquidity > amountERC20, "Insufficient Liquidity");

            //pack up the token ERC20 detail, use byte for flexibility
            bytes memory data = abi.encode(_tokenWant, amountERC20); // maybe want to include tokenPRICE too

            IExtendedLedger(s_protocol).reimbursedToken(
                msg.sender, // user's address
                _amountHave, // amount of ledger's currency that will be reduce later
                data // other detail the tx
            );

            // emit swapBack
        } else {
            // Check if _tokenHave is included in the pool
            PoolDetails memory poolDetailsHave = s_poolDetailsByAddress[
                _tokenHave
            ];
            require(
                address(poolDetailsHave.aggregatorAddress) != address(0),
                "Token is not accepted"
            );

            // get price
            (, uint256 tokenPrice) = checkPrice(_tokenHave);

            // amount of ledger's currency user will get in the ledger
            uint256 amountCurrency = (_amountHave / 1e18) * tokenPrice;

            // block if result is lower than min requirement
            // for eg: 1000000meme token = 0.001 usd
            require(
                amountCurrency > s_minAmount,
                "Lower than minimum requirement"
            );

            // call forward deposit
            IExtendedLedger(s_protocol).deposit(msg.sender, amountCurrency);

            // transfer the erc20 user's have to the pool
            // currently pool is this contract
            IERC20(_tokenHave).safeTransferFrom(
                msg.sender,
                address(this),
                _amountHave
            );

            emit TokensSwapped(msg.sender, _amountHave);
        }
    }

    /// @notice a forward payment process after bank approval
    /// @dev this will be called by protcol (ledger contract) or authorized
    /// @param _tokenAddress a parameter just like in doxygen (must be followed by parameter name)
    /// @param _recipient the user who requested the swap previously
    /// @param _amountOut amount of erc20 token
    function processPayment(
        IERC20 _tokenAddress,
        address _recipient,
        uint256 _amountOut
    ) external onlyProtocol {
        // approve for access from this contract
        IERC20(_tokenAddress).approve(address(this), _amountOut);
        IERC20(_tokenAddress).safeTransfer(_recipient, _amountOut);

        emit TokensSwapped(_recipient, _amountOut);
    }

    /*------------------- PRIVATE FUNCTIONS -------------------*/

    // Function to generate unique pool IDs
    function getNextPoolId() private returns (uint256) {
        uint256 currentPoolId = nextPoolId;
        nextPoolId++; // Increment for the next pool
        return currentPoolId;
    }
}
