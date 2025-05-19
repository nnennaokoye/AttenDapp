// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/OrgFactory.sol";

contract DeployScript is Script {
    function run() external {
        // Retrieve the private key from environment variable
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy the factory contract
        OrgFactory factory = new OrgFactory();
        
        console.log("OrgFactory deployed at:", address(factory));
        
        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}
