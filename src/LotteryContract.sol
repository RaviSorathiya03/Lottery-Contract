// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

contract LotteryContract {
    address public owner;
    address payable[] public players;
    uint public lotteryId;
    mapping(uint => address) public lotteryWinners;

    event PlayerEntered(address indexed player);
    event WinnerSelected(address indexed winner, uint indexed lotteryId, uint amountWon);

    constructor() {
        owner = msg.sender;
        lotteryId = 1;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner is allowed to perform this action");
        _;
    }

    /// @notice Enter the lottery by paying minimum 0.01 ETH
    function enter() public payable {
        require(msg.value >= 0.01 ether, "You need to pay at least 0.01 ETH to enter the lottery");
        players.push(payable(msg.sender));
        emit PlayerEntered(msg.sender);
    }

    /// @notice Generates a pseudo-random number (NOT SECURE — only for testing)
    function getRandomNumber() public view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
    }

    /// @notice Selects a winner and transfers the pot, resets the lottery
    function pickWinner() public onlyOwner {
        require(players.length > 0, "No players in the lottery");

        uint index = getRandomNumber() % players.length;
        address payable winner = players[index];
        uint prizeAmount = address(this).balance;

        winner.transfer(prizeAmount);

        lotteryWinners[lotteryId] = winner;
        emit WinnerSelected(winner, lotteryId, prizeAmount);

        lotteryId++;
        delete players;
    }

    /// @notice Returns the total pot balance
    function getPotBalance() public view onlyOwner returns (uint) {
        return address(this).balance;
    }

    /// @notice Returns current list of players (for transparency)
    function getPlayers() public view onlyOwner returns (address payable[] memory) {
        return players;
    }

    /// @notice Returns list of past winners
    function getLotteryWinners() public view onlyOwner returns (address[] memory) {
        address[] memory winners = new address[](lotteryId - 1);
        for (uint i = 1; i < lotteryId; i++) {
            winners[i - 1] = lotteryWinners[i];
        }
        return winners;
    }
}
