// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/OrgRegistry.sol";
import "../src/OrgFactoryProxy.sol";

/**
 * @title DeployToBaseSepoliaScript
 * @dev Deploys the AttendDapp contracts to Base Sepolia using lightweight contracts
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
        
        // First deploy the registry contract
        OrgRegistry registry = new OrgRegistry();
        console.log("OrgRegistry deployed to Base Sepolia at:", address(registry));
        
        // Then deploy the factory proxy with the registry address
        OrgFactoryProxy factory = new OrgFactoryProxy(address(registry));
        console.log("OrgFactoryProxy deployed to Base Sepolia at:", address(factory));
        
        // Set the factory address in the registry for permission control
        registry.setFactoryAddress(address(factory));
        console.log("Factory address set in registry");
        
        // Stop broadcasting transactions
        vm.stopBroadcast();
        
        console.log("\n--- Next Steps ---");
        console.log("1. Create an organization using the OrgFactoryProxy at:", address(factory));
        console.log("2. Use the OrgFactoryProxy to create a new organization with your desired name and badge");
        console.log("3. Call factory.createOrganization(name, description, badgeURI)");
        console.log("4. Get the OrgAttendance contract address from the return value or events");
        console.log("5. Use the OrgAttendance contract to manage roles, create attendance, etc.");
        console.log("\n--- Architecture Details ---");
        console.log("This deployment uses lightweight contract implementations to reduce contract size:");
        console.log("- AttendanceNFTLite provides minimal ERC721 functionality");
        console.log("- OrgAttendanceLite implements simplified role-based access control");
        console.log("- All contracts should now be below the 24576 byte EVM size limit");
    }
}
