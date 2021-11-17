// SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

contract Lottery is VRFConsumerBase, Ownable {
    address  payable[] public players;
    address payable public  recentWinner;
    uint256 public usdEntryFee;
    uint256 public randomness;
    AggregatorV3Interface internal ethUsdPriceFeed;
    enum LOTTERY_STATE {
        OPEN, CLOSED, CALCULATING_WINNER
    }
    LOTTERY_STATE public lottery_state;
    uint256 public fee;
    bytes32 public keyhash;

    //    0
    //    1
    //    2

    constructor(address _priceFeedAddress,
        address _vrfCoordinator,
        address _link,
        uint256 _fee,
        bytes32 _keyhash
    )
    public
    VRFConsumerBase(_vrfCoordinator, _link){
        usdEntryFee = 50 * (10 ** 18);
        require(lottery_state == LOTTERY_STATE.OPEN);
        ethUsdPriceFeed = AggregatorV3Interface(_priceFeedAddress);
        lottery_state = LOTTERY_STATE.CLOSED;
        fee = _fee;
        keyhash = _keyhash;
    }

    function enter() public payable {
        //$50 dollars  minimum
        require(msg.value >= getEntranceFee(), "Not enough ETH!");
        players.push(msg.sender);
    }

    function getEntranceFee() public view returns (uint256) {
        //
        (, int256 price,,,) = ethUsdPriceFeed.latestRoundData();
        uint256 adjustedPrice = uint256(price) * 10 ** 10;
        // 18 decimals
        // $50, $2,000 /ETH
        // $50/2,000
        // $50 * 100000 /2000
        uint256 constToEnter = (usdEntryFee * 10 ** 18) / adjustedPrice;
        return constToEnter;
    }

    function startLottery() public onlyOwner {
        require(lottery_state == LOTTERY_STATE.CLOSED,
            "Can't start a new lottery yet!");
        lottery_state = LOTTERY_STATE.OPEN;
    }

    function endLottery() public onlyOwner {
        //        Getting a random number in an insecure way
        //        uint256(keccak256(abi.encodePacked(
        //                nonce, // nonce is predictable( aka,transactions number)
        //                msg.sender, // msg.sender is predictable
        //                block.difficulty, // can actually be manipulated by miners
        //                block.timestamp // timestamp is predictable
        //            ))) % players.length;
        lottery_state = LOTTERY_STATE.CALCULATING_WINNER;
        bytes32 requestId = requestRandomness(keyhash, fee);
    }

    function fulfillRandomness(bytes32 _requestId, uint256 _randomness)
    internal override {
        require(lottery_state == LOTTERY_STATE.CALCULATING_WINNER,
            "You aren't there yet!");
        require(_randomness > 0, "Random not found");
        uint256 indexOfWinner = _randomness % players.length;
        recentWinner = players[indexOfWinner];
        // 7 Players
        //  22 random numbers
        //  22 % 7
        //  7 * 3 = 21
        //  7 * 4 = 28
        recentWinner.transfer(address(this).balance);
        //         reset players to brand new array
        players = new address payable[](0);
        //         close the lottery
        lottery_state = LOTTERY_STATE.CLOSED;
        randomness = _randomness;

    }


}