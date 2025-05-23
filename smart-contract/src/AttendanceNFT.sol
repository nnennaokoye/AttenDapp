// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./IAttendanceNFT.sol";

/**
 * @title AttendanceNFT
 * @dev ERC721 token for attendance tracking with role-based minting
 */
contract AttendanceNFT is ERC721, AccessControl {
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
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(MINTER_ROLE, admin);
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
    ) external onlyRole(MINTER_ROLE) returns (uint256) {
        uint256 tokenId = _nextTokenId;
        _nextTokenId++;
        
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
     * @dev Returns whether the specified token exists
     * @param tokenId The token ID to check
     * @return Whether the token exists
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }
    
    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721: URI query for nonexistent token");
        return _tokenURIs[tokenId];
    }
    
    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        _tokenURIs[tokenId] = _tokenURI;
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
