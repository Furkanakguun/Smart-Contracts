// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RandomnessBlockhash {

    function getRandomNumber() public view returns (uint256) {
        uint256 blockNumber = block.number - 1;
        bytes32 blockHash = blockhash(blockNumber);
        uint256 randomNumber = uint256(blockHash);
        return randomNumber;
    }
}

// In this example, the getRandomNumber function uses the blockhash 
// function to obtain the hash of the previous block (block.number - 1). 
// The resulting hash is then converted to a uint256 integer using uint256(blockHash). 
// This gives us a random number between 0 and 2^256-1.

// It's important to note that blockhash can only be used for the most recent 256 blocks (or fewer, 
// depending on how many blocks have been mined since the block you're referencing). 
// Additionally, because miners have some control over which transactions get included in a block, 
// there is a small risk that they could manipulate the hash to produce a desired outcome.
// However, for most use cases, blockhash is a reasonable method for generating random numbers.

// Please note that this is just an example contract, and you would need to 
// customize it further to suit your specific use case.
// Additionally, you would need to deploy the contract to the Ethereum network 
// using a tool such as Remix or Truffle in order to use it in practice.
