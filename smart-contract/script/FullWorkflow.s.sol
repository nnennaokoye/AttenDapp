// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/OrgFactory.sol";
import "../src/OrgAttendance.sol";
import "../src/AttendanceNFT.sol";
import "../src/IAttendanceNFT.sol";

/**
 * @title FullWorkflowScript
 * @dev Demonstrates a complete workflow of the AttendDapp system
 */
contract FullWorkflowScript is Script {
    // Constants for organization details
    string constant ORG_NAME = "Lagos Coding Bootcamp";
    string constant ORG_DESCRIPTION = "Empowering African developers with Web3 skills";
    string constant BADGE_URI = "ipfs://QmBadgeHashExample";
    
    // Constants for attendance details
    string constant SESSION_TITLE = "Python Workshop";
    string constant ATTENDANCE_ID = "ABC123";
    
    // Contract instances
    OrgFactory public factory;
    OrgAttendance public orgAttendance;
    IAttendanceNFT public attendanceNFT;
    
    // Role constants from contracts
    bytes32 public constant TEACHER_ROLE = keccak256("TEACHER_ROLE");
    bytes32 public constant STUDENT_ROLE = keccak256("STUDENT_ROLE");

    function run() external {
        // Get private key from environment variable or provide a default for testnet
        uint256 deployerPrivateKey = vm.envOr("PRIVATE_KEY", uint256(1));
        
        // Account addresses (for testnet we'll use the first few accounts)
        address deployer = vm.addr(deployerPrivateKey);
        address teacher = vm.addr(deployerPrivateKey + 1);
        address student1 = vm.addr(deployerPrivateKey + 2);
        address student2 = vm.addr(deployerPrivateKey + 3);
        
        console.log("Deployer address:", deployer);
        console.log("Teacher address:", teacher);
        console.log("Student 1 address:", student1);
        console.log("Student 2 address:", student2);
        
        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);
        
        // Step 1: Deploy OrgFactory
        console.log("\n--- Step 1: Deploying OrgFactory ---");
        factory = new OrgFactory();
        console.log("OrgFactory deployed at:", address(factory));
        
        // Step 2: Create a new organization
        console.log("\n--- Step 2: Creating Organization ---");
        (address orgAddress, address nftAddress) = factory.createOrganization(
            ORG_NAME,
            ORG_DESCRIPTION,
            BADGE_URI
        );
        console.log("Organization created at:", orgAddress);
        console.log("AttendanceNFT created at:", nftAddress);
        
        // Get contract references
        orgAttendance = OrgAttendance(orgAddress);
        attendanceNFT = IAttendanceNFT(nftAddress);
        
        // Step 3: Assign roles
        console.log("\n--- Step 3: Assigning Roles ---");
        orgAttendance.assignRole(teacher, TEACHER_ROLE);
        console.log("Teacher role assigned to:", teacher);
        
        orgAttendance.assignRole(student1, STUDENT_ROLE);
        console.log("Student role assigned to student1:", student1);
        
        orgAttendance.assignRole(student2, STUDENT_ROLE);
        console.log("Student role assigned to student2:", student2);
        
        vm.stopBroadcast();
        
        // Step 4: Teacher creates attendance
        console.log("\n--- Step 4: Creating Attendance ---");
        vm.startBroadcast(deployerPrivateKey + 1); // Switch to teacher
        orgAttendance.createAttendance(ATTENDANCE_ID, SESSION_TITLE);
        console.log("Attendance created with ID:", ATTENDANCE_ID);
        vm.stopBroadcast();
        
        // Step 5: Students claim attendance NFTs
        console.log("\n--- Step 5: Student 1 Claims NFT ---");
        vm.startBroadcast(deployerPrivateKey + 2); // Switch to student1
        orgAttendance.claimNFT(ATTENDANCE_ID);
        console.log("Student 1 claimed NFT for attendance ID:", ATTENDANCE_ID);
        vm.stopBroadcast();
        
        // Step 6: Create another attendance for testing leaderboard
        console.log("\n--- Step 6: Creating Second Attendance ---");
        vm.startBroadcast(deployerPrivateKey + 1); // Switch back to teacher
        string memory secondAttendanceId = "XYZ456";
        string memory secondSessionTitle = "Solidity Workshop";
        orgAttendance.createAttendance(secondAttendanceId, secondSessionTitle);
        console.log("Second attendance created with ID:", secondAttendanceId);
        vm.stopBroadcast();
        
        // Step 7: Student 2 claims attendance for second session
        console.log("\n--- Step 7: Student 2 Claims NFT ---");
        vm.startBroadcast(deployerPrivateKey + 3); // Switch to student2
        orgAttendance.claimNFT(secondAttendanceId);
        console.log("Student 2 claimed NFT for attendance ID:", secondAttendanceId);
        vm.stopBroadcast();
        
        // Step 8: Check leaderboard (view call - doesn't require broadcasting)
        console.log("\n--- Step 8: Display Leaderboard (View Call) ---");
        console.log("You can view the leaderboard by calling orgAttendance.getLeaderboard()");
    }
}
