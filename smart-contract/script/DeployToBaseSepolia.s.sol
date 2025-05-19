// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/OrgFactory.sol";

/**
 * @title DeployToBaseSepoliaScript
 * @dev Deploys the AttendDapp contracts to Base Sepolia
 */
contract DeployToBaseSepoliaScript is Script {
    function run() external {
        // Retrieve the private key from environment variable
        // Make sure to set this before running: 
        // $env:PRIVATE_KEY="your_private_key_without_0x_prefix"
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        address deployer = vm.addr(deployerPrivateKey);
        console.log("Deploying from address:", deployer);
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy the factory contract
        OrgFactory factory = new OrgFactory();
        
        console.log("OrgFactory deployed to Base Sepolia at:", address(factory));
        console.log("Transaction hash will be provided in the console output");
        
        // Stop broadcasting transactions
        vm.stopBroadcast();
        
        console.log("\n--- Next Steps ---");
        console.log("1. Create an organization using the OrgFactory at:", address(factory));
        console.log("2. Use the OrgFactory to create a new organization with your desired name and badge");
        console.log("3. Call factory.createOrganization(name, description, badgeURI)");
        console.log("4. Get the OrgAttendance contract address from the return value or events");
        console.log("5. Use the OrgAttendance contract to manage roles, create attendance, etc.");
    }
}
