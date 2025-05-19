// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/OrgFactory.sol";
import "../src/OrgAttendance.sol";
import "../src/AttendanceNFT.sol";

/**
 * @title AttendanceCreationScript
 * @dev Script to demonstrate attendance creation functionality
 */
contract AttendanceCreationScript is Script {
    // Role constants from contracts
    bytes32 public constant TEACHER_ROLE = keccak256("TEACHER_ROLE");

    function run() external {
        // Get private key from environment variable
        uint256 deployerPrivateKey = vm.envOr("PRIVATE_KEY", uint256(1));
        address deployer = vm.addr(deployerPrivateKey);
        address teacher = vm.addr(deployerPrivateKey + 1);
        
        console.log("Deployer address:", deployer);
        console.log("Teacher address:", teacher);
        
        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);
        
        // Step 1: Deploy OrgFactory if not already deployed
        OrgFactory factory = new OrgFactory();
        console.log("\nOrgFactory deployed at:", address(factory));
        
        // Step 2: Create a new organization
        console.log("\nCreating organization...");
        (address orgAddress, address nftAddress) = factory.createOrganization(
            "Lagos Coding Bootcamp",
            "Empowering African developers with Web3 skills",
            "ipfs://QmBadgeHashExample"
        );
        console.log("Organization created at:", orgAddress);
        console.log("AttendanceNFT created at:", nftAddress);
        
        // Get OrgAttendance contract reference
        OrgAttendance orgAttendance = OrgAttendance(orgAddress);
        
        // Step 3: Assign teacher role
        console.log("\nAssigning teacher role...");
        orgAttendance.assignRole(teacher, TEACHER_ROLE);
        console.log("Teacher role assigned to:", teacher);
        
        vm.stopBroadcast();
        
        // Step 4: Create multiple attendance records as teacher
        console.log("\nCreating attendance records as teacher...");
        vm.startBroadcast(deployerPrivateKey + 1); // Switch to teacher
        
        // Create first attendance
        string memory attendanceId1 = "ABC123";
        string memory sessionTitle1 = "Python Workshop";
        orgAttendance.createAttendance(attendanceId1, sessionTitle1);
        console.log("Attendance created with ID:", attendanceId1);
        
        // Create second attendance
        string memory attendanceId2 = "DEF456";
        string memory sessionTitle2 = "JavaScript Fundamentals";
        orgAttendance.createAttendance(attendanceId2, sessionTitle2);
        console.log("Attendance created with ID:", attendanceId2);
        
        // Create third attendance
        string memory attendanceId3 = "GHI789";
        string memory sessionTitle3 = "Blockchain Basics";
        orgAttendance.createAttendance(attendanceId3, sessionTitle3);
        console.log("Attendance created with ID:", attendanceId3);
        
        // Step 5: Verify attendance count
        uint256 attendanceCount = orgAttendance.getAttendanceCount();
        console.log("\nTotal attendance records:", attendanceCount);
        
        // Step 6: Verify attendance records
        for (uint256 i = 0; i < attendanceCount; i++) {
            string memory id = orgAttendance.attendanceIds(i);
            (
                string memory title,
                uint256 tokenId,
                address teacherAddr,
                bool claimed,
                address student
            ) = orgAttendance.attendanceRecords(id);
            
            console.log("\nAttendance ID:", id);
            console.log("Session Title:", title);
            console.log("Token ID:", tokenId);
            console.log("Teacher:", teacherAddr);
            console.log("Claimed:", claimed);
            console.log("Student:", student);
        }
        
        vm.stopBroadcast();
    }
}
