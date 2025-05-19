// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./OrgAttendanceLite.sol";
import "./AttendanceNFTLite.sol";
import "./OrgRegistry.sol";

/**
 * @title OrgFactoryProxy
 * @dev Minimal factory contract that only handles contract creation and delegates storage to OrgRegistry
 */
contract OrgFactoryProxy {
    // Registry contract that stores organization data
    OrgRegistry public registry;
    
    // Events
    event OrganizationCreated(
        address indexed orgAttendanceAddress, 
        address indexed nftAddress,
        address indexed creator,
        string name, 
        string description
    );
    
    constructor(address _registry) {
        registry = OrgRegistry(_registry);
    }
    
    /**
     * @dev Creates a new organization with its own attendance contract and NFT contract
     * @param name Organization name
     * @param description Organization description
     * @param badgeURI URI for the organization's badge
     * @return orgAttendanceAddress Address of the deployed OrgAttendanceLite contract
     * @return nftAddress Address of the deployed AttendanceNFTLite contract
     */
    function createOrganization(
        string memory name,
        string memory description,
        string memory badgeURI
    ) external returns (address orgAttendanceAddress, address nftAddress) {
        // Create NFT contract with the organization name
        string memory nftSymbol = _generateSymbol(name);
        AttendanceNFTLite nftContract = new AttendanceNFTLite(name, nftSymbol, msg.sender);
        
        // Create organization attendance contract
        OrgAttendanceLite orgAttendance = new OrgAttendanceLite(
            name,
            description,
            badgeURI,
            address(nftContract),
            msg.sender
        );
        
        // Grant minter role to the org attendance contract
        nftContract.grantRole(nftContract.MINTER_ROLE(), address(orgAttendance));
        
        // Register the organization in the registry
        registry.registerOrganization(
            name,
            description,
            badgeURI,
            address(orgAttendance),
            address(nftContract),
            msg.sender
        );
        
        emit OrganizationCreated(
            address(orgAttendance), 
            address(nftContract), 
            msg.sender, 
            name, 
            description
        );
        
        return (address(orgAttendance), address(nftContract));
    }
    
    /**
     * @dev Generates a symbol from the organization name
     * @param name The organization name
     * @return A short symbol based on the name
     */
    function _generateSymbol(string memory name) internal pure returns (string memory) {
        // Simple implementation: take the first 3 characters and convert to uppercase
        bytes memory nameBytes = bytes(name);
        bytes memory symbolBytes = new bytes(3);
        
        for (uint i = 0; i < 3 && i < nameBytes.length; i++) {
            // Convert to uppercase if it's a lowercase letter
            if (nameBytes[i] >= 0x61 && nameBytes[i] <= 0x7A) {
                symbolBytes[i] = bytes1(uint8(nameBytes[i]) - 32);
            } else {
                symbolBytes[i] = nameBytes[i];
            }
        }
        
        return string(symbolBytes);
    }
}
