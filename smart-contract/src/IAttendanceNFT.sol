// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/**
 * @title IAttendanceNFT
 * @dev Interface for the AttendanceNFT contract
 */
interface IAttendanceNFT {
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
    ) external returns (uint256 tokenId);
    
    /**
     * @dev Get the owner of a token
     * @param tokenId The token ID
     * @return owner The address of the token owner
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);
    
    /**
     * @dev Transfers a token from one address to another
     * @param from The current owner
     * @param to The new owner
     * @param tokenId The token ID
     */
    function transferFrom(address from, address to, uint256 tokenId) external;
}
