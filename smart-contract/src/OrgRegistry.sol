// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/**
 * @title OrgRegistry
 * @dev Stores organization data and provides query functions
 */
contract OrgRegistry {
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
    
    // Address of the factory contract that has permission to register organizations
    address public factoryAddress;
    
    // Events
    event OrganizationRegistered(
        address indexed orgAttendanceAddress, 
        address indexed nftAddress,
        address indexed creator
    );
    
    constructor() {
        factoryAddress = msg.sender; // Initially, the deployer can register organizations
    }
    
    // Modifier to restrict calls to the factory contract
    modifier onlyFactory() {
        require(msg.sender == factoryAddress, "OrgRegistry: Caller is not the factory");
        _;
    }
    
    /**
     * @dev Updates the factory address
     * @param _newFactory The new factory address
     */
    function setFactoryAddress(address _newFactory) external onlyFactory {
        factoryAddress = _newFactory;
    }
    
    /**
     * @dev Registers a new organization in the registry
     * @param name Organization name
     * @param description Organization description
     * @param badgeURI URI for the organization's badge
     * @param orgAttendanceAddress Address of the OrgAttendance contract
     * @param nftAddress Address of the AttendanceNFT contract
     * @param creator Address of the creator
     */
    function registerOrganization(
        string memory name,
        string memory description,
        string memory badgeURI,
        address orgAttendanceAddress,
        address nftAddress,
        address creator
    ) external onlyFactory {
        // Store the organization
        organizations.push(Organization({
            name: name,
            description: description,
            badgeURI: badgeURI,
            orgAttendanceAddress: orgAttendanceAddress,
            nftAddress: nftAddress,
            creationTime: block.timestamp,
            creator: creator
        }));
        
        // Store the mapping from address to index
        uint256 newOrgIndex = organizations.length - 1;
        orgAddressToIndex[orgAttendanceAddress] = newOrgIndex;
        
        // Track organizations created by this creator
        creatorToOrganizations[creator].push(orgAttendanceAddress);
        
        emit OrganizationRegistered(orgAttendanceAddress, nftAddress, creator);
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
        require(index < organizations.length, "OrgRegistry: Index out of bounds");
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
        require(index < organizations.length, "OrgRegistry: Organization not found");
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
