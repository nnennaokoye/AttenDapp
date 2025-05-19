// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./IAttendanceNFT.sol";

/**
 * @title AttendanceNFTLite
 * @dev Lightweight implementation of the ERC721 token for attendance tracking
 * This version removes unnecessary features to reduce contract size
 */
contract AttendanceNFTLite is IAttendanceNFT {
    // Events (minimal necessary events from ERC721)
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    
    // Roles - simplified role system
    bytes32 public constant override MINTER_ROLE = keccak256("MINTER_ROLE");
    
    // Admin address
    address public admin;
    
    // Token data
    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(uint256 => string) private _tokenURIs;
    mapping(uint256 => string) private _sessionTitles;
    
    // Counter for token IDs
    uint256 private _nextTokenId;
    
    // Access control - simple role-based permissions
    mapping(address => mapping(bytes32 => bool)) private _roles;
    
    // Organization name
    string public organizationName;
    string private _symbol;
    
    /**
     * @dev Constructor sets up the token name, symbol, and roles
     * @param name_ The name of the organization
     * @param symbol_ The symbol for the NFT
     * @param adminAddress The address of the admin who can grant roles
     */
    constructor(
        string memory name_,
        string memory symbol_,
        address adminAddress
    ) {
        organizationName = name_;
        _symbol = symbol_;
        admin = adminAddress;
        
        // Grant roles to admin
        _roles[adminAddress][MINTER_ROLE] = true;
    }
    
    /**
     * @dev Modifier to restrict function to role holders
     */
    modifier onlyRole(bytes32 role) {
        require(_roles[msg.sender][role] || msg.sender == admin, "Unauthorized");
        _;
    }
    
    /**
     * @dev Mints a new attendance NFT for a session
     * @param to The address to mint the NFT to
     * @param sessionTitle The title of the session
     * @param badgeURI The URI of the badge image
     * @return tokenId The ID of the minted NFT
     */
    function mint(
        address to,
        string memory sessionTitle,
        string memory badgeURI
    ) external override onlyRole(MINTER_ROLE) returns (uint256) {
        require(to != address(0), "Cannot mint to zero address");
        
        uint256 tokenId = _nextTokenId;
        _nextTokenId++;
        
        _owners[tokenId] = to;
        _balances[to] += 1;
        _tokenURIs[tokenId] = badgeURI;
        _sessionTitles[tokenId] = sessionTitle;
        
        emit Transfer(address(0), to, tokenId);
        
        return tokenId;
    }
    
    /**
     * @dev Gets the session title for a token
     * @param tokenId The token ID
     * @return The session title
     */
    function getSessionTitle(uint256 tokenId) external view returns (string memory) {
        require(_owners[tokenId] != address(0), "Token does not exist");
        return _sessionTitles[tokenId];
    }
    
    /**
     * @dev See {IERC721-ownerOf}
     */
    function ownerOf(uint256 tokenId) external view override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "Token does not exist");
        return owner;
    }
    
    /**
     * @dev Simplified transferFrom that doesn't check approvals for contract calls
     */
    function transferFrom(address from, address to, uint256 tokenId) external override {
        address owner = _owners[tokenId];
        require(owner != address(0), "Token does not exist");
        
        // Allow transfers by: 1) token owner, 2) approved address, 3) admin, 4) contract with permission
        require(
            owner == from && 
            (msg.sender == from || 
             _tokenApprovals[tokenId] == msg.sender || 
             msg.sender == admin ||
             _roles[msg.sender][MINTER_ROLE]), 
            "Transfer not authorized"
        );
        
        // Clear approvals
        if (_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0);
        }
        
        // Update balances and ownership
        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;
        
        emit Transfer(from, to, tokenId);
    }
    
    /**
     * @dev Returns the token URI
     */
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_owners[tokenId] != address(0), "Token does not exist");
        return _tokenURIs[tokenId];
    }
    
    /**
     * @dev Grants a role to an account
     */
    function grantRole(bytes32 role, address account) external override {
        require(msg.sender == admin || _roles[msg.sender][role], "Only admin can grant roles");
        _roles[account][role] = true;
    }
}
