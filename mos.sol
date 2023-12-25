// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NFTMinter is ERC721, ReentrancyGuard {
    mapping(address => bool) public hasMinted;
    mapping(uint256 => bytes) public tokenURIs;
    mapping(uint256 => RoyaltyInfo) private _royalties;
    address private owner;
    uint256 private nextMintableId = 1;

    event ArtworkMinted(uint256 mintedId);

    struct RoyaltyInfo {
        address recipient;
        uint96 royaltyFraction;
    }

    constructor() ERC721("Moseiki", "MOS") {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        owner = newOwner;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        return string(tokenURIs[tokenId]); 
    }

    function getNextMintableId() public view returns (uint256) {
        return nextMintableId;
    }

    function mint(string memory _tokenURI, uint96 _royaltyFraction)
        external
        nonReentrant
        returns (uint256)
    {
        require(_royaltyFraction <= 10000, "Royalty fee will exceed salePrice");

        uint256 mintedId = nextMintableId;
        _safeMint(msg.sender, mintedId);
        tokenURIs[mintedId] = stringToBytes(_tokenURI);

        _setTokenRoyalty(mintedId, msg.sender, _royaltyFraction);

        hasMinted[msg.sender] = true;
        nextMintableId += 1;
        emit ArtworkMinted(mintedId);

        return mintedId;
    }

    function mintWithBytes(bytes memory _tokenURIBytes, uint96 _royaltyFraction)
        external
        nonReentrant
        returns (uint256)
    {
        require(_royaltyFraction <= 10000, "Royalty fee will exceed salePrice");

        uint256 mintedId = nextMintableId;
        _safeMint(msg.sender, mintedId);
        tokenURIs[mintedId] = _tokenURIBytes;

        _setTokenRoyalty(mintedId, msg.sender, _royaltyFraction);

        hasMinted[msg.sender] = true;
        nextMintableId += 1;
        emit ArtworkMinted(mintedId);

        return mintedId;
    }

    

    function _setTokenRoyalty(
        uint256 tokenId,
        address recipient,
        uint96 royaltyFraction
    ) internal {
        _royalties[tokenId] = RoyaltyInfo(recipient, royaltyFraction);
    }

    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        public
        view
        returns (address, uint256)
    {
        RoyaltyInfo memory royalty = _royalties[tokenId];
        uint256 royaltyAmount = (salePrice * royalty.royaltyFraction) / 10000;
        return (royalty.recipient, royaltyAmount);
    }

    function stringToBytes(string memory source)
        internal
        pure
        returns (bytes memory)
    {
        return bytes(source);
    }

}
