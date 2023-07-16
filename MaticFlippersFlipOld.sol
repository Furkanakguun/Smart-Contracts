// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
import "@api3/airnode-protocol/contracts/rrp/requesters/RrpRequesterV0.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MaticFlippersFlip is RrpRequesterV0, Ownable{
    event Result(bool isWinner, uint256 qrngUint256);
    uint256 private constant MAX_BET = 1 ether; // maximum bet amount is 100 ether
    uint256 private constant MIN_BET = 0.0001 ether; // minimum bet amount is 0.01 ether
    address public airnode;
    bytes32 public endpointIdUint256;
    address public sponsorwallet;
    uint256 public deneme;
    bool isLastFlipWin = false;

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
            require(msg.value >= 0.005 ether, "Not enough money!");
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
        returns (bool)
    {
        require(
            expectingRequestWithIdToBeFullfilled[requestId],
            "Request ID not known"
        );
        expectingRequestWithIdToBeFullfilled[requestId] = false;
        uint256 qrngUint256 = abi.decode(data, (uint256));
        bool isWinner = (qrngUint256 % 2 == 0);
        emit Result(isWinner, qrngUint256);

        if (isWinner) {
            //
            //payable(msg.sender).transfer(address(this).balance);
        }

        return isWinner;
    }
}
