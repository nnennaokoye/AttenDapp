// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./OrgAttendance.sol";
import "./AttendanceNFT.sol";

/**
 * @title OrgFactory
 * @dev Factory contract to deploy new organization attendance contracts
 */
contract OrgFactory {
    // Organization struct
    struct Organization {
        string name;
        string description;
        string badgeURI;
        address orgAttendanceAddress;
        address nftAddress;
        uint256 creationTime;
        address creator;
    }
    
    // Array of all organizations
    Organization[] public organizations;
    
    // Mapping from organization address to index in organizations array
    mapping(address => uint256) public orgAddressToIndex;
    
    // Mapping from creator address to their organization addresses
    mapping(address => address[]) public creatorToOrganizations;
    
    // Events
    event OrganizationCreated(
        address indexed orgAttendanceAddress, 
        address indexed nftAddress,
        address indexed creator,
        string name, 
        string description
    );
    
    /**
     * @dev Creates a new organization with its own attendance contract and NFT contract
     * @param name Organization name
     * @param description Organization description
     * @param badgeURI URI for the organization's badge
     * @return orgAttendanceAddress Address of the deployed OrgAttendance contract
     * @return nftAddress Address of the deployed AttendanceNFT contract
     */
    function createOrganization(
        string memory name,
        string memory description,
        string memory badgeURI
    ) external returns (address orgAttendanceAddress, address nftAddress) {
        // Create NFT contract with the organization name
        string memory nftSymbol = _generateSymbol(name);
        AttendanceNFT nftContract = new AttendanceNFT(name, nftSymbol, msg.sender);
        
        // Create organization attendance contract
        OrgAttendance orgAttendance = new OrgAttendance(
            name,
            description,
            badgeURI,
            address(nftContract),
            msg.sender
        );
        
        // Grant minter role to the org attendance contract
        nftContract.grantRole(nftContract.MINTER_ROLE(), address(orgAttendance));
        
        // Store the organization
        organizations.push(Organization({
            name: name,
            description: description,
            badgeURI: badgeURI,
            orgAttendanceAddress: address(orgAttendance),
            nftAddress: address(nftContract),
            creationTime: block.timestamp,
            creator: msg.sender
        }));
        
        // Store the mapping from address to index
        uint256 newOrgIndex = organizations.length - 1;
        orgAddressToIndex[address(orgAttendance)] = newOrgIndex;
        
        // Track organizations created by this creator
        creatorToOrganizations[msg.sender].push(address(orgAttendance));
        
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
     * @dev Gets the total number of organizations
     * @return The count of organizations
     */
    function getOrganizationCount() external view returns (uint256) {
        return organizations.length;
    }
    
    /**
     * @dev Gets the organization data at a specific index
     * @param index The index of the organization
     * @return The organization data
     */
    function getOrganizationAtIndex(uint256 index) external view returns (Organization memory) {
        require(index < organizations.length, "OrgFactory: Index out of bounds");
        return organizations[index];
    }
    
    /**
     * @dev Gets all organizations created by a specific address
     * @param creator The creator's address
     * @return orgAddresses Array of organization addresses created by the creator
     */
    function getOrganizationsByCreator(address creator) external view returns (address[] memory) {
        return creatorToOrganizations[creator];
    }
    
    /**
     * @dev Gets organization details by its address
     * @param orgAddress The organization's contract address
     * @return The organization data
     */
    function getOrganizationByAddress(address orgAddress) external view returns (Organization memory) {
        uint256 index = orgAddressToIndex[orgAddress];
        require(index < organizations.length, "OrgFactory: Organization not found");
        return organizations[index];
    }
    
    /**
     * @dev Checks if an address is a valid organization
     * @param orgAddress The address to check
     * @return isValid True if the address is a valid organization
     */
    function isValidOrganization(address orgAddress) external view returns (bool) {
        uint256 index = orgAddressToIndex[orgAddress];
        return index < organizations.length && organizations[index].orgAttendanceAddress == orgAddress;
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
