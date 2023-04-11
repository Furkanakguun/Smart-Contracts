pragma solidity ^0.8.0;

contract CoinFlip {

  function flip(string memory _choice) public payable {
      require(msg.value > 0, "Must send some ether to play!");
      require((keccak256(abi.encodePacked(_choice)) == keccak256(abi.encodePacked("head"))) || (keccak256(abi.encodePacked(_choice)) == keccak256(abi.encodePacked("tail"))), "Choice must be either 'head' or 'tail'");

      bytes32 blockHash = blockhash(block.number - 1);
      uint256 numTransactions = block.transactions.length;
      uint256 balance = address(this).balance;

      bytes32 random = keccak256(abi.encodePacked(blockHash, numTransactions, balance, now, msg.sender));

      bool result = (uint256(random) % 2 == 0);

      if ((keccak256(abi.encodePacked(_choice)) == keccak256(abi.encodePacked("head")) && result) || (keccak256(abi.encodePacked(_choice)) == keccak256(abi.encodePacked("tail")) && !result)) {
          msg.sender.transfer(msg.value * 2);
      }
  }
  
}

// In this version of the function, we're including the hash of a previous block, the number of transactions in the current block, 
// and the current balance of the contract as inputs to the randomness generation algorithm. We're also including the timestamp and 
// the sender address as additional inputs. This should make it much more difficult for a user to predict the outcome of the flip.

// However, it's important to note that even with these additional sources of randomness,
// it's still possible for a determined attacker to game the system. 
// It's always a good idea to carefully consider the security implications of any random number generation algorithm 
// and to design your contracts with potential attack vectors in mind.
