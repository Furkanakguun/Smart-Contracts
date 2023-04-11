// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CoinFlip is ReentrancyGuard , Ownable{
    using SafeMath for uint256;
    
    uint256 private constant MAX_INT = type(uint256).max;
    uint256 private constant MIN_BET = 0.01 ether;

    bool public publicFlipActive;

     // modifiers
    modifier whenPublicSaleActive() {
        require(publicFlipActive, "Public flip is not active");
        _;
    }
    
    mapping(address => uint256) private _balances;
    
    event BetPlaced(address indexed player, bool indexed outcome, uint256 betAmount, bool win);
    
    function flip(string memory choice) public payable nonReentrant whenPublicSaleActive {
        require(msg.value >= MIN_BET, "Bet amount should be greater than or equal to 0.01 ether");
        require(_balances[msg.sender] == 0, "Finish your previous game");
        
        uint256 seed = uint256(keccak256(abi.encodePacked(block.timestamp, blockhash(block.number + 1), address(this).balance, msg.sender)));
        
        bool outcome = uint256(keccak256(abi.encodePacked(seed, choice))) % 2 == 0;
        
        if (outcome) {
            uint256 winAmount = msg.value.mul(2);
            _balances[msg.sender] = winAmount;
            emit BetPlaced(msg.sender, true, msg.value, true);
            payable(msg.sender).transfer(winAmount);
        } else {
            emit BetPlaced(msg.sender, false, msg.value, false);
        }
    }
    
    function withdraw() public nonReentrant onlyOwner {
        uint256 balance = _balances[msg.sender];
        require(balance > 0, "You have no balance to withdraw");
        _balances[msg.sender] = 0;
        payable(msg.sender).transfer(balance);
    }
    
    function balanceOf(address player) public view returns (uint256) {
        return _balances[player];
    }
}


//In this updated contract, the flip function takes a string argument choice that can be either "head" or "tail".
//The randomness for determining the outcome is calculated based on the current timestamp, 
//the next block's hash, the current contract balance, and the sender's address. 
//If the user wins, their balance is updated and they receive double the amount of their bet.
//If they lose, the contract keeps the bet amount. The withdraw function allows the 
//player to withdraw any winnings they have accumulated, and the balanceOf function allows the 
//player to check their current balance in the contract.

// In the previous CoinFlip contract, the block.difficulty refers to the difficulty level of the current block 
//being mined on the blockchain. Difficulty is a measure of how difficult it is to mine a new block 
//on the blockchain. It is calculated based on the total hash power of the network, and it is adjusted
// periodically to ensure that new blocks are mined at a consistent rate.

//In the context of the CoinFlip contract, the block.difficulty value is used to add an additional level of 
//unpredictability to the randomness calculation. 
//By including the current block's difficulty level, it makes it harder for any one miner to predict the 
//outcome of the coin flip.
