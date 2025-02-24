// Sources flattened with hardhat v2.22.17 https://hardhat.org

// SPDX-License-Identifier: MIT AND UNLICENSED

// File @openzeppelin/contracts/utils/Context.sol@v5.2.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}


// File @openzeppelin/contracts/access/Ownable.sol@v5.2.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// File contracts/interfaces/IEIP712.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;

interface IEIP712 {
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}


// File contracts/interfaces/ISignatureTransfer.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;

/// @title SignatureTransfer
/// @notice Handles ERC20 token transfers through signature based actions
/// @dev Requires user's token approval on the Permit2 contract
interface ISignatureTransfer is IEIP712 {
    
    struct TokenPermissions {
        address token;
        uint256 amount;
    }

    struct PermitTransferFrom {
        TokenPermissions permitted;
        uint256 nonce;
        uint256 deadline;
    }

    struct SignatureTransferDetails {
        address to;
        uint256 requestedAmount;
    }
    
    function permitTransferFrom(
        PermitTransferFrom memory permit,
        SignatureTransferDetails calldata transferDetails,
        address owner,
        bytes calldata signature
    ) external;
}


// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v5.2.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}


// File contracts/Manager.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity ^0.8.28;
contract Manager is Ownable {
    bool public gameIsLive;
    uint public minMultiplier = 100;
    uint public maxMultiplier = 10000;

    struct Token {
        uint128 minBetAmount;
        uint128 maxBetAmount;
        uint houseEdgeBP;
    }
    struct Bet {
        uint40 choice;
        uint40 outcome;
        uint176 placeBlockNumber;
        uint128 amount;
        uint128 winAmount;
        address player;
        address token;
        bool isSettled;
    }


    Bet[] public bets;
    mapping(address => Token) public supportedTokenInfo;
    mapping(bytes32 => uint[]) public betMap;

    //events
    event BetPlaced(uint indexed betId, address indexed player, uint amount, uint choice, address token);
    event BetSettled(uint indexed betId, address indexed player, uint amount, uint choice, uint outcome, uint winAmount, address token);
    event BetRefunded(uint indexed betId, address indexed player, uint amount, address token);

    constructor(address initialOwner) Ownable(msg.sender){
    }

    function betsLength() external view returns (uint) {
        return bets.length;
    }

    function setMinMultiplier(uint _minMultiplier) external onlyOwner {
        minMultiplier = _minMultiplier;
    }
    
    function setMaxMultiplier(uint _maxMultiplier) external onlyOwner {
        maxMultiplier = _maxMultiplier;
    }

    function setMinBetAmount(address token, uint128 _minBetAmount) external onlyOwner {
        require(_minBetAmount < supportedTokenInfo[token].maxBetAmount, "Min amount must be less than max amount");
        supportedTokenInfo[token].minBetAmount = _minBetAmount;
    }

    function setMaxBetAmount(address token, uint128 _maxBetAmount) external onlyOwner {
        require(_maxBetAmount > supportedTokenInfo[token].minBetAmount, "Max amount must be greater than min amount");
        supportedTokenInfo[token].maxBetAmount = _maxBetAmount;
    }

    function setHouseEdgeBP(address token, uint _houseEdgeBP) external onlyOwner {
        require(gameIsLive == false, "Bets in pending");
        supportedTokenInfo[token].houseEdgeBP = _houseEdgeBP;
    }

    function toggleGameIsLive() external onlyOwner {
        gameIsLive = !gameIsLive;
    }

    function amountToBettableAmountConverter(uint amount, address token) internal view returns(uint) {
        return amount * (10000 - supportedTokenInfo[token].houseEdgeBP) / 10000;
    }

    function amountToWinnableAmount(uint _amount, uint multiplier, address token) internal view returns (uint) {
        uint bettableAmount = amountToBettableAmountConverter(_amount, token);
        return bettableAmount * multiplier / 100;
    }


    // withdraw any token from contract
    function withdrawCustomTokenFunds(address beneficiary, uint withdrawAmount, address token) external onlyOwner {
        require(withdrawAmount <= IERC20(token).balanceOf(address(this)), "Withdrawal exceeds limit");
        IERC20(token).transfer(beneficiary, withdrawAmount);
    }
}


// File contracts/Crash.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.28;
contract Crash is Manager {
    uint public explosionRate = 1;
    ISignatureTransfer public permit2 =
        ISignatureTransfer(0x000000000022D473030F116dDEE9F6B43aC78BA3);


    mapping(address => bool) public callers;
    mapping(address => uint) public pendingIdsPerPlayer;

    constructor() Manager(msg.sender){
        callers[msg.sender] = true;
    }

    modifier onlyCaller() {
        require(callers[msg.sender], "Caller is not authorized");
        _;
    }

    function placeBet(
        uint multiplierChoice, 
        ISignatureTransfer.PermitTransferFrom memory permit,
        ISignatureTransfer.SignatureTransferDetails calldata transferDetails, 
        bytes calldata signature
    ) external {
        address token =permit.permitted.token;
        uint amount = permit.permitted.amount;
        address player = msg.sender;
        require(gameIsLive, "Game is not live");
        require(minMultiplier < multiplierChoice && multiplierChoice <= maxMultiplier, "Bet mask not in range");
        require(token != address(0), "Token address cannot be 0");
        require(amount >= supportedTokenInfo[token].minBetAmount && amount <= supportedTokenInfo[token].maxBetAmount, "Bet amount not within range");
        require(pendingIdsPerPlayer[player] == 0, "You have a pending bet");
        // uint winnableAmount = amountToWinnableAmount(amount, multiplierChoice, token);
        
        // permit2 signature transger
        // house.placeBet{value: msg.value}(player, amount, token, winnableAmount);
        permit2.permitTransferFrom(
            permit,
            transferDetails,
            msg.sender,
            signature
        );
        uint betId = bets.length+1;
        
        // es sistema para manejar varias resoluciones
        // betMap[VRFManager.sendRequestRandomness()].push(betId);
        pendingIdsPerPlayer[player] = betId;
        emit BetPlaced(betId, player, amount, multiplierChoice, token);   
        bets.push(Bet({
            choice: uint40(multiplierChoice),
            outcome: 0,
            placeBlockNumber: uint176(block.number),
            amount: uint128(amount),
            winAmount: 0,
            player: player,
            token: token,
            isSettled: false
        }));
    }


    function _settleBet(uint betId, uint256 seed) external onlyCaller  {
        Bet storage bet = bets[betId];

        uint randomNumber = uint(keccak256(abi.encode(seed,block.timestamp,block.prevrandao, blockhash(bet.placeBlockNumber))));

        uint amount = bet.amount;
        if (amount == 0 || bet.isSettled == true) {
            return;
        }

        address player = bet.player;
        pendingIdsPerPlayer[player] = 0;
        address token = bet.token;
        uint multiplierChoice = bet.choice;

        uint exploted = randomNumber % 100;
        if (exploted <= explosionRate ) {
            bet.isSettled = true;
            bet.winAmount = uint128(0);
            bet.outcome = uint40(0);
            emit BetSettled(betId, player, amount, multiplierChoice, 0, 0, token);
            return;
        }

        uint H = randomNumber % (maxMultiplier - minMultiplier + 1);
        uint E = maxMultiplier / 100;
        uint multiplierOutcome = (E * maxMultiplier - H) / (E * 100 - H);

        uint winnableAmount = amountToWinnableAmount(amount, multiplierChoice, token);
        uint winAmount = multiplierChoice <= multiplierOutcome ? winnableAmount : 0;

        bet.isSettled = true;
        bet.winAmount = uint128(winAmount);
        bet.outcome = uint40(multiplierOutcome);

        if(winAmount > 0) {
            IERC20(token).transfer(player, winnableAmount);
        }
        emit BetSettled(betId, player, amount, multiplierChoice, multiplierOutcome, winAmount, token);
    }


    function setExplosionRate(uint _explosionRate) external onlyOwner {
        
        explosionRate = _explosionRate;
    }

    function playFree(uint multiplier) external  view returns(uint, bool) {
        uint randomNumber = uint(keccak256(abi.encode(block.timestamp,block.prevrandao, blockhash(block.number - 1))));

        uint H = randomNumber % (maxMultiplier - minMultiplier + 1);
        uint E = maxMultiplier / 100;
        uint multiplierOutcome = (E * maxMultiplier - H) / (E * 100 - H);

        return (multiplierOutcome, multiplier <= multiplierOutcome);
    }

    function refundBet(uint betId) external onlyOwner {
        require(gameIsLive, "Game is not live");
        Bet storage bet = bets[betId];
        uint amount = bet.amount;

        require(amount > 0, "Bet does not exist");
        require(bet.isSettled == false, "Bet is settled already");
        require(block.number > bet.placeBlockNumber + 21600, "Wait before requesting refund");

        address token = bet.token;
        uint winnableAmount = amountToWinnableAmount(amount, bet.choice, token);
        uint bettedAmount = amountToBettableAmountConverter(amount, token);
        
        bet.isSettled = true;
        bet.winAmount = uint128(bettedAmount);

        IERC20(token).transfer(bet.player, bettedAmount);
        pendingIdsPerPlayer[bet.player] = 0;
        emit BetRefunded(betId, bet.player, bettedAmount, token);
    }

}
