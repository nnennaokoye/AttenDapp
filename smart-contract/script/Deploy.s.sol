// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/OrgRegistry.sol";
import "../src/OrgFactoryProxy.sol";

contract DeployScript is Script {
    function run() external {
        // Retrieve the private key from environment variable
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);
        
        // First deploy the registry contract
        OrgRegistry registry = new OrgRegistry();
        console.log("OrgRegistry deployed at:", address(registry));
        
        // Then deploy the factory proxy with the registry address
        OrgFactoryProxy factory = new OrgFactoryProxy(address(registry));
        console.log("OrgFactoryProxy deployed at:", address(factory));
        
        // Set the factory address in the registry for permission control
        registry.setFactoryAddress(address(factory));
        console.log("Factory address set in registry");
        
        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}
