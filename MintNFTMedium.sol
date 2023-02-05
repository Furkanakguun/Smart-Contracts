// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts@4.8.1/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.8.1/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts@4.8.1/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts@4.8.1/access/Ownable.sol";
import "@openzeppelin/contracts@4.8.1/utils/Counters.sol";

contract MyMediumToken is
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
    uint256 public constant MAX_MINT_PER_ADDRESS = 3;
    uint256 public constant MINT_PRICE = 0.002 ether;

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
        uint256 indexed _saleDuration,
        uint256 indexed _saleStartTime
    );

    event NFTPublicSaleStop(
        uint256 indexed _currentPrice,
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
        emit NFTPublicSaleStart(MINT_PRICE, publicSaleStartTime);
        publicSaleActive = true;
    }

    function stopPublicSale() external onlyOperator whenPublicSaleActive {
        emit NFTPublicSaleStop(MINT_PRICE, getElapsedSaleTime());
        publicSaleActive = false;
    }

    // events
    event LandPublicSaleStart(
        uint256 indexed _saleDuration,
        uint256 indexed _saleStartTime
    );
    event LandPublicSaleStop(
        uint256 indexed _currentPrice,
        uint256 indexed _timeElapsed
    );

    constructor() ERC721("MyMediumToken", "MTDK") {}

    function safeMint(address to, string memory uri)
        public
        payable
        whenPublicSaleActive
        nonReentrant
    {
        uint256 tokenId = _tokenIdCounter.current();
        uint256 mintIndex = totalSupply();
        require(mintIndex < MAX_NFT, " All NFTs are already sold");
        require(MINT_PRICE <= msg.value, " Ether value sent is not correct");
        //Check for minted addres has more than max mint per address
        require(
            mintedPerAddress[msg.sender] > MAX_MINT_PER_ADDRESS,
            "sender address cannot mint more than maxMintPerAddress"
        );
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
