// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

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