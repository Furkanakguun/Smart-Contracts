// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


contract ExceptionExample {

    mapping(address => uint) public balanceReceived;

    function receiveMoney() public payable{
        assert(balanceReceived[msg.sender] + uint64(msg.value) >= balanceReceived[msg.sender]);
        balanceReceived[msg.sender] = msg.value;
    }

    function withdrawMoney(address payable _to , uint _amount) public {
        require(_amount <= balanceReceived[msg.sender] , "You don't have enough ether!");        // Instead of if(_amount <= balanceReceived[msg.sender]) for Expcetion 
        assert(balanceReceived[msg.sender] >= balanceReceived[msg.sender] - _amount);
        balanceReceived[msg.sender] -= _amount;
        _to.transfer(_amount);
    }

}
