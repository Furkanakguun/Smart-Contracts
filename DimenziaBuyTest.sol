// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts@4.8.1/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.8.1/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts@4.8.1/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts@4.8.1/access/Ownable.sol";
import "@openzeppelin/contracts@4.8.1/utils/Counters.sol";

contract DimenziaBuy is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    Ownable,
    ReentrancyGuard
{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    //attributes
    // Standart for ERC721
    bool public publicSaleActive;
    address public operator;
    uint256 public publicSaleStartTime;
    //Mapping for holding which address mint how much dimenzia ?
    mapping(address => uint256) public mintedPerAddress;

    // constants
    uint256 public constant MAX_NFT = 10000;

    // modifiers
    modifier whenPublicSaleActive() {
        require(publicSaleActive, "Public sale is not active");
        _;
    }

    modifier onlyOperator() {
        require(operator == msg.sender, "Only operator can call this method");
        _;
    }

    // events
    event NFTPublicSaleStart(
        uint256 indexed _saleStartTime
    );

    event NFTPublicSaleStop(
        uint256 indexed _timeElapsed
    );

    function setOperator(address _operator) external onlyOwner {
        operator = _operator;
    }

    function getElapsedSaleTime() private view returns (uint256) {
        return
            publicSaleStartTime > 0 ? block.timestamp - publicSaleStartTime : 0;
    }

    function startPublicSale() external onlyOperator {
        publicSaleStartTime = block.timestamp;
        emit NFTPublicSaleStart(publicSaleStartTime);
        publicSaleActive = true;
    }

    function stopPublicSale() external onlyOperator whenPublicSaleActive {
        emit NFTPublicSaleStop(getElapsedSaleTime());
        publicSaleActive = false;
    }


    constructor() ERC721("DimenziaBuy", "DMNZ") {}


   function stringToUint(string memory s) public pure returns (uint) {
        bytes memory b = bytes(s);
        uint result = 0;
        for (uint256 i = 0; i < b.length; i++) {
            uint256 c = uint256(uint8(b[i]));
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }
        return result;
    }

    function safeMint(address to, string memory uri , uint256 tokenId)
        public
        payable
        
        whenPublicSaleActive
        nonReentrant
    {
        uint256 mintPrice;
       if (tokenId > 0 && tokenId < 10) {
            mintPrice = 0.00002 ether;
        } else if (tokenId >= 10 && tokenId <= 100) {
            mintPrice = 0.00003 ether;
        } else {
            mintPrice = 0.00004 ether;
        }
         
        uint256 mintIndex = totalSupply();
        require(mintIndex < MAX_NFT, " All Dimenzias are already sold");
        require(mintPrice <= msg.value, " Ether value sent is not correct");
        //Check for minted addres has more than max mint per address
        mintedPerAddress[msg.sender] += 1;
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
