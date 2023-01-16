// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract MappingStructExample{
    struct Payment{
        uint amount;
        uint timestamps;
    }
    
    struct Balance{
        uint totalBalance;
        uint numPayments;
        mapping(uint => Payment) payments;
    }

    mapping(address => Balance) public balanceReceived;
    address public interactAddress;
    address public contractOwner;

    constructor(){
        contractOwner = msg.sender;
    }

    function setInteractAddress() public {
        interactAddress = msg.sender;
    }

    function getBalance() public view returns(uint) {
        return address(this).balance;
    }

    function sendMoney() public payable {
        balanceReceived[msg.sender].totalBalance += msg.value;

        Payment memory payment = Payment(msg.value , block.timestamp);

        balanceReceived[msg.sender].payments[balanceReceived[msg.sender].numPayments] = payment;
        balanceReceived[msg.sender].numPayments++;

    }

    function withdrawMoneyToSomeone(address payable _to , uint _amount) public {
        require(balanceReceived[msg.sender].totalBalance >= _amount, "not enough funds");
        balanceReceived[msg.sender].totalBalance -= _amount;
        _to.transfer(_amount); 
    }

    function withdrawAllMoney(address payable _to) public {
        uint balanceToSend = balanceReceived[msg.sender].totalBalance;
        balanceReceived[msg.sender].totalBalance = 0;
        _to.transfer(balanceToSend);
    }

    function withdrawAll(address payable _to) public {
        //Check for contract owner
        require(contractOwner == _to);
        _to.transfer(address(this).balance);
    }

    
}
