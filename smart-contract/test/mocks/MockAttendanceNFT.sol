// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title MockAttendanceNFT
 * @dev Mock implementation of AttendanceNFT for testing
 */
contract MockAttendanceNFT is ERC721, AccessControl {
    // Roles
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    
    // Counter for token IDs
    uint256 private _nextTokenId;
    
    // Mapping from token ID to token URI
    mapping(uint256 => string) private _tokenURIs;
    
    // Mapping from token ID to session title
    mapping(uint256 => string) private _sessionTitles;

    // Organization name
    string public organizationName;
    
    // Mock functionality - we'll use this to simulate transfers without actually moving tokens
    // This helps avoid ERC721InvalidReceiver errors in tests
    mapping(uint256 => address) private _mockOwners;
    
    constructor(
        string memory name_,
        string memory symbol_,
        address admin
    ) ERC721(name_, symbol_) {
        organizationName = name_;
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(MINTER_ROLE, admin);
    }
    
    function mint(
        address to,
        string memory sessionTitle,
        string memory badgeURI
    ) external onlyRole(MINTER_ROLE) returns (uint256) {
        uint256 tokenId = _nextTokenId;
        _nextTokenId++;
        
        // For testing, we'll just record the owner without actually minting
        _mockOwners[tokenId] = to;
        _tokenURIs[tokenId] = badgeURI;
        _sessionTitles[tokenId] = sessionTitle;
        
        return tokenId;
    }
    
    function getSessionTitle(uint256 tokenId) external view returns (string memory) {
        require(_exists(tokenId), "AttendanceNFT: Token does not exist");
        return _sessionTitles[tokenId];
    }
    
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _mockOwners[tokenId] != address(0);
    }
    
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721: URI query for nonexistent token");
        return _tokenURIs[tokenId];
    }
    
    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        // For testing, we'll just update the mock owner without actual transfer logic
        _mockOwners[tokenId] = to;
    }
    
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _mockOwners[tokenId];
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }
    
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
