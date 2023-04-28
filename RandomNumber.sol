// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
import "@api3/airnode-protocol/contracts/rrp/requesters/RrpRequesterV0.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RandomNumber is RrpRequesterV0, Ownable{
    address public airnode;
    bytes32 public endpointIdUint256;
    address public sponsorwallet;
    uint256 public deneme;

    mapping (bytes32 => bool) public expectingRequestWithIdToBeFullfilled;


    mapping (bytes32 => address payable ) requestToSender;
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



function RequestNewRandomNumber() public payable returns (bytes32) {
        require(msg.value >= 0.01 ether, "Not enough money!");
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
        requestToSender[requestId] = payable (msg.sender);
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
        uint256 _deneme = (qrngUint256 % 2);
        require(_deneme == 1, "You lost!");
        requestToSender[requestId].transfer(0.02 ether);
    }
}
