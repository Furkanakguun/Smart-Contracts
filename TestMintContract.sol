// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts@4.8.0/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.8.0/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts@4.8.0/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts@4.8.0/access/Ownable.sol";
import "@openzeppelin/contracts@4.8.0/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract HETCOTEST3 is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable ,ReentrancyGuard {
    using SafeMath for uint256;

    //attributes
    // Standart for ERC721
    uint public constant mintPrice = 0;
    bool public publicSaleActive;
    address public operator;
    //Mapping for holding which address mint how much dimenzia ?
    mapping(address => uint256) public mintedPerAddress;

    // constants
    uint256 immutable public MAX_LANDS;
    uint256 immutable public MAX_MINT_PER_ADDRESS;
    
    

    // modifiers
    modifier whenPublicSaleActive() {
        require(publicSaleActive, "Public sale is not active");
        _;
    }

    modifier onlyOperator() {
        require(operator == msg.sender , "Only operator can call this method");
        _;
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

     function stopPublicSale() external onlyOwner whenPublicSaleActive {
        //emit LandPublicSaleStop(getMintPrice(), getElapsedSaleTime());
        publicSaleActive = false;
    }

  
    constructor() ERC721("HETCOTEST3", "HTCTST3") {

        MAX_LANDS = 18000;
        MAX_MINT_PER_ADDRESS = 10;

    }

    function mint(address to, uint256 tokenId , string memory _uri) public payable whenPublicSaleActive nonReentrant {
            //uint256 mintIndex = totalSupply();
            
            //Check for minted addres has more than max mint per address
            require(mintedPerAddress[msg.sender] > MAX_MINT_PER_ADDRESS, "sender address cannot mint more than maxMintPerAddress");
            mintedPerAddress[msg.sender] += 1;
            _safeMint(to , tokenId);
            _setTokenURI(tokenId , _uri);
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        if(balance > 0){
            Address.sendValue(payable(owner()), balance);
        }
    }


    function setOperator(address _operator) external onlyOwner {
        operator = _operator;
    }

    // The following functions are overrides required by Solidity.
    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
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
