// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/OrgFactory.sol";
import "../src/OrgAttendance.sol";

/**
 * @title RoleManagementScript
 * @dev Script to demonstrate role management functionality
 */
contract RoleManagementScript is Script {
    // Role constants from contracts
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
    bytes32 public constant TEACHER_ROLE = keccak256("TEACHER_ROLE");
    bytes32 public constant STUDENT_ROLE = keccak256("STUDENT_ROLE");

    function run() external {
        // Get private key from environment variable
        uint256 deployerPrivateKey = vm.envOr("PRIVATE_KEY", uint256(1));
        address deployer = vm.addr(deployerPrivateKey);
        
        // Account addresses (for testnet we'll use the first few accounts)
        address teacher1 = vm.addr(deployerPrivateKey + 1);
        address teacher2 = vm.addr(deployerPrivateKey + 2);
        address student1 = vm.addr(deployerPrivateKey + 3);
        address student2 = vm.addr(deployerPrivateKey + 4);
        address student3 = vm.addr(deployerPrivateKey + 5);
        
        console.log("Deployer address:", deployer);
        console.log("Teacher 1 address:", teacher1);
        console.log("Teacher 2 address:", teacher2);
        console.log("Student 1 address:", student1);
        console.log("Student 2 address:", student2);
        console.log("Student 3 address:", student3);
        
        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);
        
        // Step 1: Deploy OrgFactory if not already deployed
        OrgFactory factory = new OrgFactory();
        console.log("\nOrgFactory deployed at:", address(factory));
        
        // Step 2: Create a new organization
        console.log("\nCreating organization...");
        (address orgAddress, address nftAddress) = factory.createOrganization(
            "Nairobi Tech Academy",
            "Kenya's premier coding bootcamp",
            "ipfs://QmBadgeHashExample"
        );
        console.log("Organization created at:", orgAddress);
        console.log("AttendanceNFT created at:", nftAddress);
        
        // Get OrgAttendance contract reference
        OrgAttendance orgAttendance = OrgAttendance(orgAddress);
        
        // Step 3: Assign teacher roles
        console.log("\nAssigning teacher roles...");
        orgAttendance.assignRole(teacher1, TEACHER_ROLE);
        console.log("Teacher role assigned to:", teacher1);
        
        orgAttendance.assignRole(teacher2, TEACHER_ROLE);
        console.log("Teacher role assigned to:", teacher2);
        
        // Step 4: Assign student roles
        console.log("\nAssigning student roles...");
        orgAttendance.assignRole(student1, STUDENT_ROLE);
        console.log("Student role assigned to:", student1);
        
        orgAttendance.assignRole(student2, STUDENT_ROLE);
        console.log("Student role assigned to:", student2);
        
        orgAttendance.assignRole(student3, STUDENT_ROLE);
        console.log("Student role assigned to:", student3);
        
        // Step 5: Verify roles
        console.log("\nVerifying roles...");
        
        // Check teacher roles
        bool isTeacher1 = orgAttendance.hasRole(TEACHER_ROLE, teacher1);
        bool isTeacher2 = orgAttendance.hasRole(TEACHER_ROLE, teacher2);
        console.log("Is teacher1 a teacher?", isTeacher1);
        console.log("Is teacher2 a teacher?", isTeacher2);
        
        // Check student roles
        bool isStudent1 = orgAttendance.hasRole(STUDENT_ROLE, student1);
        bool isStudent2 = orgAttendance.hasRole(STUDENT_ROLE, student2);
        bool isStudent3 = orgAttendance.hasRole(STUDENT_ROLE, student3);
        console.log("Is student1 a student?", isStudent1);
        console.log("Is student2 a student?", isStudent2);
        console.log("Is student3 a student?", isStudent3);
        
        // Check deployer is admin
        bool isAdmin = orgAttendance.hasRole(DEFAULT_ADMIN_ROLE, deployer);
        console.log("Is deployer an admin?", isAdmin);
        
        // Step 6: Try to revoke a role (optional)
        console.log("\nRevoking a role...");
        orgAttendance.revokeRole(STUDENT_ROLE, student3);
        bool isStillStudent = orgAttendance.hasRole(STUDENT_ROLE, student3);
        console.log("Is student3 still a student after revocation?", isStillStudent);
        
        vm.stopBroadcast();
    }
}
