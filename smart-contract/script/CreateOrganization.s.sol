// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/OrgFactory.sol";

/**
 * @title CreateOrganizationScript
 * @dev Script to create a new organization
 */
contract CreateOrganizationScript is Script {
    function run() external {
        // Get private key from environment variable
        uint256 deployerPrivateKey = vm.envOr("PRIVATE_KEY", uint256(1));
        address deployer = vm.addr(deployerPrivateKey);
        
        console.log("Deployer address:", deployer);
        
        // Define organization details
        string memory name = "Lagos Coding Bootcamp";
        string memory description = "Empowering African developers with Web3 skills";
        string memory badgeURI = "ipfs://QmBadgeHashExample";
        
        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);
        
        // Step 1: Deploy OrgFactory if not already deployed
        // In a real scenario, you'd use an existing factory address
        OrgFactory factory = new OrgFactory();
        console.log("OrgFactory deployed at:", address(factory));
        
        // Step 2: Create a new organization
        console.log("\nCreating organization...");
        (address orgAddress, address nftAddress) = factory.createOrganization(
            name,
            description,
            badgeURI
        );
        console.log("Organization created at:", orgAddress);
        console.log("AttendanceNFT created at:", nftAddress);
        
        // Step 3: Check organization details
        console.log("\nVerifying organization details...");
        uint256 orgCount = factory.getOrganizationCount();
        console.log("Total organizations:", orgCount);
        
        // Get organization by index
        OrgFactory.Organization memory org = factory.getOrganizationAtIndex(orgCount - 1);
        console.log("Organization name:", org.name);
        console.log("Organization description:", org.description);
        console.log("Organization badge URI:", org.badgeURI);
        
        // Get organizations by creator
        address[] memory creatorOrgs = factory.getOrganizationsByCreator(deployer);
        console.log("Number of organizations by creator:", creatorOrgs.length);
        
        // Verify organization by address
        bool isValid = factory.isValidOrganization(orgAddress);
        console.log("Is valid organization:", isValid);
        
        vm.stopBroadcast();
    }
}
