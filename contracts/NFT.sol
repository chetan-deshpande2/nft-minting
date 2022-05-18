// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

contract NFT is EIP712, ERC721URIStorage, AccessControl {
    using Counters for Counters.Counter;
    Counters.Counter private _nftIds;
    Counters.Counter private _nftMinted;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    string private constant SIGNING_DOMAIN = "NFT";
    string private constant SIGNATURE_VERSION = "1";

    mapping(address => uint256) public minters;

    // struct NFT {
    //     address minter;
    //     string memory tokenURI;

    // }

    constructor()
        ERC721("NFT Token", "NFT")
        EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION)
    {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
    }

    function setMinter(address _minter) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _setupRole(MINTER_ROLE, _minter);
    }

    function isMinter(address account) external view returns (bool) {
        return hasRole(MINTER_ROLE, account);
    }

    function mintNFT(
        address minter,
        uint256 tokenId,
        uint256 minPrice,
        string memory tokenURI,
        bytes memory signature
    ) external payable {
        require(_nftIds.current() == 3000, "can not mint more nfts");
        require(
            hasRole(MINTER_ROLE, minter),
            "Signature invalid or unauthorized"
        );
        require(msg.value >= minPrice, "amount should be greater than price ");
        address signer = _verify(tokenId, minPrice, tokenURI, signature);
        _nftIds.increment();
        uint256 nftId = _nftIds.current();
        _mint(signer, tokenId);
        _setTokenURI(tokenId, tokenURI);

        _transfer(signer, minter, tokenId);
        payable(signer).transfer(minPrice);
    }

    function check(
        uint256 tokenId,
        uint256 minPrice,
        string memory tokenURI,
        bytes memory signature
    ) external view returns (address) {
        return _verify(tokenId, minPrice, tokenURI, signature);
    }

    function _verify(
        uint256 tokenId,
        uint256 minPrice,
        string memory tokenURI,
        bytes memory _signature
    ) internal view returns (address) {
        bytes32 digest = _hash(tokenId, minPrice, tokenURI);
        return ECDSA.recover(digest, _signature);
    }

    function _hash(
        uint256 tokenId,
        uint256 minPrice,
        string memory tokenURI
    ) internal view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        keccak256(
                            "NFTVoucher(uint256 tokenId,uint256 minPrice,string uri)"
                        ),
                        tokenId,
                        minPrice,
                        keccak256(bytes(tokenURI))
                    )
                )
            );
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControl, ERC721)
        returns (bool)
    {
        return
            ERC721.supportsInterface(interfaceId) ||
            AccessControl.supportsInterface(interfaceId);
    }
}
