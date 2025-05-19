// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./mocks/MockOrgFactory.sol";

contract OrgFactoryTest is Test {
    MockOrgFactory public factory;
    address public admin = address(1);
    
    string public orgName = "Lagos Tech Academy";
    string public orgDescription = "Nigeria's premier Web3 bootcamp";
    string public badgeURI = "ipfs://QmSampleBadgeHash";
    
    function setUp() public {
        vm.startPrank(admin);
        factory = new MockOrgFactory();
        vm.stopPrank();
    }
    
    function testGetOrganizationCount() public {
        // Initially should be zero
        assertEq(factory.getOrganizationCount(), 0, "Initial count should be 0");
        
        // Create an organization
        vm.startPrank(admin);
        factory.createOrganization(orgName, orgDescription, badgeURI);
        vm.stopPrank();
        
        // Count should be incremented
        assertEq(factory.getOrganizationCount(), 1, "Count should be 1 after creation");
    }
    
    function testGetOrganizationAtIndex() public {
        vm.startPrank(admin);
        
        // Create an organization
        (address orgAddress, address nftAddress) = factory.createOrganization(
            orgName,
            orgDescription,
            badgeURI
        );
        
        // Get organization by index
        MockOrgFactory.Organization memory org = factory.getOrganizationAtIndex(0);
        
        // Verify organization data
        assertEq(org.name, orgName, "Organization name mismatch");
        assertEq(org.description, orgDescription, "Organization description mismatch");
        assertEq(org.badgeURI, badgeURI, "Badge URI mismatch");
        assertEq(org.orgAttendanceAddress, orgAddress, "Organization address mismatch");
        assertEq(org.nftAddress, nftAddress, "NFT address mismatch");
        assertEq(org.creator, admin, "Creator address mismatch");
        
        vm.stopPrank();
    }
    
    function testGetOrganizationsByCreator() public {
        vm.startPrank(admin);
        
        // Initially should be empty
        address[] memory initialOrgs = factory.getOrganizationsByCreator(admin);
        assertEq(initialOrgs.length, 0, "Should start with 0 organizations");
        
        // Create an organization
        (address orgAddress, ) = factory.createOrganization(orgName, orgDescription, badgeURI);
        
        // Get organizations by creator
        address[] memory orgs = factory.getOrganizationsByCreator(admin);
        
        // Verify
        assertEq(orgs.length, 1, "Should have 1 organization");
        assertEq(orgs[0], orgAddress, "Organization address mismatch");
        
        vm.stopPrank();
    }
    
    function testGetOrganizationByAddress() public {
        vm.startPrank(admin);
        
        // Create an organization
        (address orgAddress, address nftAddress) = factory.createOrganization(
            orgName,
            orgDescription,
            badgeURI
        );
        
        // Get organization by address
        MockOrgFactory.Organization memory org = factory.getOrganizationByAddress(orgAddress);
        
        // Verify
        assertEq(org.name, orgName, "Organization name mismatch");
        assertEq(org.description, orgDescription, "Organization description mismatch");
        assertEq(org.badgeURI, badgeURI, "Badge URI mismatch");
        assertEq(org.orgAttendanceAddress, orgAddress, "Organization address mismatch");
        assertEq(org.nftAddress, nftAddress, "NFT address mismatch");
        
        vm.stopPrank();
    }
    
    function testIsValidOrganization() public {
        vm.startPrank(admin);
        
        // Create an organization
        (address orgAddress, ) = factory.createOrganization(
            orgName,
            orgDescription,
            badgeURI
        );
        
        // Check valid organization
        assertTrue(factory.isValidOrganization(orgAddress), "Should be a valid organization");
        
        // Check invalid organization
        address invalidOrg = address(0x123);
        assertFalse(factory.isValidOrganization(invalidOrg), "Should not be a valid organization");
        
        vm.stopPrank();
    }
    
    function test_RevertWhen_GetOrganizationAtInvalidIndex() public {
        // Try to get organization at invalid index
        vm.expectRevert("OrgFactory: Index out of bounds");
        factory.getOrganizationAtIndex(999);
    }
    
    function test_RevertWhen_GetOrganizationByInvalidAddress() public {
        // Try to get organization by invalid address
        vm.expectRevert("OrgFactory: Organization not found");
        factory.getOrganizationByAddress(address(0x123));
    }
}
