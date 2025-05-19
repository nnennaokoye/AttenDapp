// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./IAttendanceNFT.sol";

/**
 * @title AttendanceNFT
 * @dev ERC721 token for attendance tracking with role-based minting
 */
contract AttendanceNFT is ERC721URIStorage, AccessControl, IAttendanceNFT {
    using Counters for Counters.Counter;
    
    // Roles
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    
    // Counter for token IDs
    Counters.Counter private _tokenIdCounter;
    
    // Mapping from token ID to session title
    mapping(uint256 => string) private _sessionTitles;

    // Organization name
    string public organizationName;
    
    /**
     * @dev Constructor sets up the token name, symbol, and roles
     * @param name_ The name of the organization
     * @param symbol_ The symbol for the NFT
     * @param admin The address of the admin who can grant roles
     */
    constructor(
        string memory name_,
        string memory symbol_,
        address admin
    ) ERC721(name_, symbol_) {
        organizationName = name_;
        _setupRole(DEFAULT_ADMIN_ROLE, admin);
        _setupRole(MINTER_ROLE, admin);
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
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, badgeURI);
        _sessionTitles[tokenId] = sessionTitle;
        
        return tokenId;
    }
    
    /**
     * @dev Gets the session title for a token
     * @param tokenId The token ID
     * @return The session title
     */
    function getSessionTitle(uint256 tokenId) external view returns (string memory) {
        require(_exists(tokenId), "AttendanceNFT: Token does not exist");
        return _sessionTitles[tokenId];
    }
    
    /**
     * @dev See {IERC165-supportsInterface}
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
