// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";

contract HetcoTestVoucher is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    Ownable,
    EIP712,
    ReentrancyGuard
{
    string private constant SIGNING_DOMAIN = "Voucher-Domain";
    string private constant SIGNATURE_VERSION = "1";
    address public minter;

    //attributes
    // Standart for ERC721
    bool public publicSaleActive;
    uint256 public publicSaleStartTime;
    //Mapping for holding which address mint how much dimenzia ?
    mapping(address => uint256) public mintedPerAddress;

    // constants
    uint256 public constant MAX_DIMENZIA = 18000;

    // modifiers
    modifier whenPublicSaleActive() {
        require(publicSaleActive, "Public sale is not active");
        _;
    }

    // events
    event DimenziaPublicSaleStart(uint256 indexed _saleStartTime);

    event DimenziaPublicSaleStop(uint256 indexed _timeElapsed);

   

    function getElapsedSaleTime() private view returns (uint256) {
        return
            publicSaleStartTime > 0 ? block.timestamp - publicSaleStartTime : 0;
    }

    function startPublicSale() external onlyOwner {
        publicSaleStartTime = block.timestamp;
        emit DimenziaPublicSaleStart(publicSaleStartTime);
        publicSaleActive = true;
    }

    function stopPublicSale() external onlyOwner whenPublicSaleActive {
        emit DimenziaPublicSaleStop(getElapsedSaleTime());
        publicSaleActive = false;
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        if (balance > 0) {
            Address.sendValue(payable(owner()), balance);
        }
    }

    constructor()
        ERC721("HetcoTestVoucher", "HTCVCT")
        EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION)
    {
        minter = msg.sender;
    }

    struct Voucher {
        uint256 tokenId;
        uint256 price;
        string uri;
        address buyer;
        bytes signature;
    }

    function recover(Voucher calldata voucher) public view returns (address) {
        bytes32 digest = _hashTypedDataV4(
            keccak256(
                abi.encode(
                    keccak256(
                        "Voucher(uint256 tokenId,uint256 price,string uri,address buyer)"
                    ),
                    voucher.tokenId,
                    voucher.price,
                    keccak256(bytes(voucher.uri)),
                    voucher.buyer
                )
            )
        );
        address signer = ECDSA.recover(digest, voucher.signature);
        return signer;
    }

    function safeMint(Voucher calldata voucher)
        public
        payable
        whenPublicSaleActive
        nonReentrant
    {
        uint256 mintIndex = totalSupply();
        require(mintIndex < MAX_DIMENZIA, " All Dimenzia are already sold");
        require(minter == recover(voucher), "Wrong signature.");
        require(
            msg.sender == voucher.buyer,
            "This NFT is not assigned for you"
        );
        require(msg.value >= voucher.price, "Not enough ether sent.");
        mintedPerAddress[msg.sender] += 1;
        _safeMint(voucher.buyer, voucher.tokenId);
        _setTokenURI(voucher.tokenId, voucher.uri);
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
