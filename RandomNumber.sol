// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@api3/airnode-protocol/contracts/rrp/requesters/RrpRequesterV0.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RandomNumber is RrpRequesterV0, Ownable{
    
    struct Number{
      uint256 rand;
    }

    RandomNumber[] public numbers;

    address public airnode;
    bytes32 public endpointIdUint256;
    address public sponsorwallet;
    uint256 public deneme;

    mapping (bytes32 => bool) public expectingRequestWithIdToBeFullfilled;


    mapping (bytes32 => address) requestToSender;
    mapping (bytes32 => uint256) requestToTokenId;

    constructor(address _airnodeRrp) RrpRequesterV0(_airnodeRrp) {}


    function setRequestParameters(
        address _airnode,
        bytes32 _endpointIdUint256,
        address _sponsorWallet
    ) external onlyOwner(){
        airnode = _airnode;
        endpointIdUint256 = _endpointIdUint256;
        sponsorwallet = _sponsorWallet;
    }



    function RequestNewRandomNumber() public returns (bytes32) {
        bytes32 requestId = airnodeRrp.makeFullRequest(
            airnode,
            endpointIdUint256,
            address(this),
            sponsorwallet,
            address(this),
            this.fulfillUint256.selector,
            ""
        );
        expectingRequestWithIdToBeFullfilled[requestId] = true;
        requestToSender[requestId] = msg.sender;
        return requestId;
    }


    function fulfillUint256(bytes32 requestId, bytes calldata data)
        external
        onlyAirnodeRrp
    {
        require(
            expectingRequestWithIdToBeFullfilled[requestId],
            "Request ID not known"
        );
        expectingRequestWithIdToBeFullfilled[requestId] = false;
        uint256 qrngUint256 = abi.decode(data, (uint256));
        uint256 _deneme = (qrngUint256 % 100);

        deneme = _deneme;

    }


}
