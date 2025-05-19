// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/OrgFactory.sol";
import "../src/OrgAttendance.sol";
import "../src/IAttendanceNFT.sol";

/**
 * @title NFTClaimAndLeaderboardScript
 * @dev Script to demonstrate NFT claiming and leaderboard functionality
 */
contract NFTClaimAndLeaderboardScript is Script {
    // Role constants from contracts
    bytes32 public constant TEACHER_ROLE = keccak256("TEACHER_ROLE");
    bytes32 public constant STUDENT_ROLE = keccak256("STUDENT_ROLE");

    function run() external {
        // Get private key from environment variable
        uint256 deployerPrivateKey = vm.envOr("PRIVATE_KEY", uint256(1));
        address deployer = vm.addr(deployerPrivateKey);
        address teacher = vm.addr(deployerPrivateKey + 1);
        address student1 = vm.addr(deployerPrivateKey + 2);
        address student2 = vm.addr(deployerPrivateKey + 3);
        address student3 = vm.addr(deployerPrivateKey + 4);
        
        console.log("Deployer address:", deployer);
        console.log("Teacher address:", teacher);
        console.log("Student 1 address:", student1);
        console.log("Student 2 address:", student2);
        console.log("Student 3 address:", student3);
        
        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);
        
        // Step 1: Deploy OrgFactory
        OrgFactory factory = new OrgFactory();
        console.log("\nOrgFactory deployed at:", address(factory));
        
        // Step 2: Create a new organization
        console.log("\nCreating organization...");
        (address orgAddress, address nftAddress) = factory.createOrganization(
            "Accra Tech Hub",
            "Ghana's leading tech academy",
            "ipfs://QmBadgeHashExample"
        );
        console.log("Organization created at:", orgAddress);
        console.log("AttendanceNFT created at:", nftAddress);
        
        // Get contract references
        OrgAttendance orgAttendance = OrgAttendance(orgAddress);
        IAttendanceNFT attendanceNFT = IAttendanceNFT(nftAddress);
        
        // Step 3: Assign roles
        console.log("\nAssigning roles...");
        orgAttendance.assignRole(teacher, TEACHER_ROLE);
        orgAttendance.assignRole(student1, STUDENT_ROLE);
        orgAttendance.assignRole(student2, STUDENT_ROLE);
        orgAttendance.assignRole(student3, STUDENT_ROLE);
        console.log("Roles assigned successfully");
        
        vm.stopBroadcast();
        
        // Step 4: Create multiple attendance records as teacher
        console.log("\nCreating attendance records...");
        vm.startBroadcast(deployerPrivateKey + 1); // Switch to teacher
        
        string[3] memory attendanceIds = ["PYTHON101", "JS202", "SOLIDITY303"];
        string[3] memory sessionTitles = ["Python Basics", "JavaScript Advanced", "Solidity Development"];
        
        for (uint256 i = 0; i < attendanceIds.length; i++) {
            orgAttendance.createAttendance(attendanceIds[i], sessionTitles[i]);
            console.log("Created attendance:", sessionTitles[i], "with ID:", attendanceIds[i]);
        }
        
        vm.stopBroadcast();
        
        // Step 5: Students claim NFTs
        console.log("\nStudents claiming NFTs...");
        
        // Student 1 claims first and second NFT
        vm.startBroadcast(deployerPrivateKey + 2); // Switch to student1
        orgAttendance.claimNFT(attendanceIds[0]); // Python Basics
        orgAttendance.claimNFT(attendanceIds[1]); // JavaScript Advanced
        console.log("Student 1 claimed 2 NFTs");
        vm.stopBroadcast();
        
        // Student 2 claims second NFT
        vm.startBroadcast(deployerPrivateKey + 3); // Switch to student2
        orgAttendance.claimNFT(attendanceIds[2]); // Solidity Development
        console.log("Student 2 claimed 1 NFT");
        vm.stopBroadcast();
        
        // Step 6: Verify NFT ownership
        console.log("\nVerifying NFT ownership...");
        for (uint256 i = 0; i < 3; i++) {
            (
                string memory title,
                uint256 tokenId,
                address teacherAddr,
                bool claimed,
                address studentAddr
            ) = orgAttendance.attendanceRecords(attendanceIds[i]);
            
            console.log("NFT for", title);
            console.log("  TokenID:", tokenId);
            console.log("  Claimed:", claimed);
            console.log("  Student:", studentAddr);
            
            // We would check NFT ownership but this would be a view call
            // In a real script, you could use: address owner = attendanceNFT.ownerOf(tokenId);
        }
        
        // Step 7: Check student NFT counts
        vm.startBroadcast(deployerPrivateKey);
        console.log("\nChecking student NFT counts...");
        uint256 student1Count = orgAttendance.studentNFTCount(student1);
        uint256 student2Count = orgAttendance.studentNFTCount(student2);
        uint256 student3Count = orgAttendance.studentNFTCount(student3);
        
        console.log("Student 1 NFT count:", student1Count);
        console.log("Student 2 NFT count:", student2Count);
        console.log("Student 3 NFT count:", student3Count);
        
        // Step 8: Get leaderboard
        console.log("\nGetting leaderboard...");
        (address[] memory addresses, uint256[] memory counts) = orgAttendance.getLeaderboard();
        
        console.log("Leaderboard:");
        for (uint256 i = 0; i < addresses.length; i++) {
            console.log(addresses[i], ":", counts[i], "NFTs");
        }
        
        vm.stopBroadcast();
    }
}
