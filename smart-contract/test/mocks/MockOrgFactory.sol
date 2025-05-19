// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/**
 * @title MockOrgFactory
 * @dev A simplified version of OrgFactory for testing, without actual contract creation
 */
contract MockOrgFactory {
    // Organization struct (same as in OrgFactory)
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
    
    // Mock addresses for created contracts
    address public constant MOCK_ORG_ADDRESS = address(0x1);
    address public constant MOCK_NFT_ADDRESS = address(0x2);
    
    /**
     * @dev Mock creation of an organization, without actually deploying contracts
     */
    function createOrganization(
        string memory name,
        string memory description,
        string memory badgeURI
    ) external returns (address orgAttendanceAddress, address nftAddress) {
        // Use mock addresses instead of creating real contracts
        orgAttendanceAddress = MOCK_ORG_ADDRESS;
        nftAddress = MOCK_NFT_ADDRESS;
        
        // Store the organization
        organizations.push(Organization({
            name: name,
            description: description,
            badgeURI: badgeURI,
            orgAttendanceAddress: orgAttendanceAddress,
            nftAddress: nftAddress,
            creationTime: block.timestamp,
            creator: msg.sender
        }));
        
        // Store the mapping from address to index
        uint256 newOrgIndex = organizations.length - 1;
        orgAddressToIndex[orgAttendanceAddress] = newOrgIndex;
        
        // Track organizations created by this creator
        creatorToOrganizations[msg.sender].push(orgAttendanceAddress);
        
        return (orgAttendanceAddress, nftAddress);
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
}
