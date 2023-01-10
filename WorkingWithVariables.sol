// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract WorkingWithVariables{
    uint256 public myUnit;
    

    function setMyUint(uint _myUint) public {
        myUnit = _myUint;
    }

    bool public myBool;

    function setMyBool(bool _myBool) public {
        myBool = _myBool; 
    }

     uint8 public myUint8;

     function incrementUint() public {
         myUint8++;
     }
     function decrementUint() public {
         myUint8--;
     }

    address public myAddress;

    // address payable x = payable(0xc7586fE5fF786584Ddd8877F651D061D41a8B7A5);
    // address myAddress = address(this);

    // if(x.balance < 10 && myAddress.balance >= 10){
    //         x.transfer(10)
    // } 

    function setAddress(address _address) public {
         myAddress = _address;
    }

    function getBalanceOfAddress() public view returns(uint){
         return myAddress.balance;
    }

    string public myString = 'hello World';
    function setMyString(string memory _myString) public {
        myString = _myString; 
    }


}
