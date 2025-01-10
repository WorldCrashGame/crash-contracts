// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Manager, IERC20} from "./Manager.sol";
import {ISignatureTransfer} from "./interfaces/ISignatureTransfer.sol";


contract Crash is Manager {
    ISignatureTransfer public permit2 =
        ISignatureTransfer(0x000000000022D473030F116dDEE9F6B43aC78BA3);


    mapping(address => bool) public callers;

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
    ) external  {
        address token =permit.permitted.token;
        uint amount = permit.permitted.amount;
        address player = msg.sender;
        require(gameIsLive, "Game is not live");
        require(minMultiplier < multiplierChoice && multiplierChoice <= maxMultiplier, "Bet mask not in range");
        require(token != address(0), "Token address cannot be 0");
        require(amount >= supportedTokenInfo[token].minBetAmount && amount <= supportedTokenInfo[token].maxBetAmount, "Bet amount not within range");
        uint winnableAmount = amountToWinnableAmount(amount, multiplierChoice, token);
        
        // permit2 signature transger
        // house.placeBet{value: msg.value}(player, amount, token, winnableAmount);
        permit2.permitTransferFrom(
            permit,
            transferDetails,
            msg.sender,
            signature
        );
        uint betId = bets.length;
        
        // es sistema para manejar varias resoluciones
        // betMap[VRFManager.sendRequestRandomness()].push(betId);

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
        address token = bet.token;
        uint multiplierChoice = bet.choice;

        uint H = randomNumber % (maxMultiplier - minMultiplier + 1);
        uint E = maxMultiplier / 100;
        uint multiplierOutcome = (E * maxMultiplier - H) / (E * 100 - H);

        uint winnableAmount = amountToWinnableAmount(amount, multiplierChoice, token);
        uint winAmount = multiplierChoice <= multiplierOutcome ? winnableAmount : 0;

        bet.isSettled = true;
        bet.winAmount = uint128(winAmount);
        bet.outcome = uint40(multiplierOutcome);

        IERC20(token).transfer(player, winnableAmount);
        emit BetSettled(betId, player, amount, multiplierChoice, multiplierOutcome, winAmount, token);
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
        
        emit BetRefunded(betId, bet.player, bettedAmount, token);
    }

}