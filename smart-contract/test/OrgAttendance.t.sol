// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/OrgAttendance.sol";
import "./mocks/MockAttendanceNFT.sol";

contract OrgAttendanceTest is Test {
    OrgAttendance public orgAttendance;
    MockAttendanceNFT public attendanceNFT;
    
    address public admin = address(1);
    address public teacher = address(2);
    address public student1;
    address public student2;
    
    string public orgName = "Tech4Africa";
    string public orgDescription = "Empowering Africa's tech talent";
    string public badgeURI = "ipfs://QmTechAfricaBadge";
    string public sessionTitle = "JavaScript Fundamentals";
    string public attendanceId = "JS101-2025";
    
    function setUp() public {
        // Use regular addresses for students since we're using a mock NFT
        student1 = address(3);
        student2 = address(4);
        
        vm.startPrank(admin);
        
        // Deploy mock NFT contract for testing
        attendanceNFT = new MockAttendanceNFT(orgName, "T4A", admin);
        
        // Deploy Organization Attendance contract
        orgAttendance = new OrgAttendance(
            orgName,
            orgDescription,
            badgeURI,
            address(attendanceNFT),
            admin
        );
        
        // Give minter role to OrgAttendance
        attendanceNFT.grantRole(attendanceNFT.MINTER_ROLE(), address(orgAttendance));
        
        // Assign roles
        orgAttendance.assignRole(teacher, orgAttendance.TEACHER_ROLE());
        orgAttendance.assignRole(student1, orgAttendance.STUDENT_ROLE());
        orgAttendance.assignRole(student2, orgAttendance.STUDENT_ROLE());
        
        vm.stopPrank();
    }
    
    function testInitialState() public {
        assertEq(orgAttendance.name(), orgName, "Organization name mismatch");
        assertEq(orgAttendance.description(), orgDescription, "Organization description mismatch");
        assertEq(orgAttendance.badgeURI(), badgeURI, "Badge URI mismatch");
        assertTrue(orgAttendance.hasRole(orgAttendance.DEFAULT_ADMIN_ROLE(), admin), "Admin role not assigned");
        assertTrue(orgAttendance.hasRole(orgAttendance.TEACHER_ROLE(), teacher), "Teacher role not assigned");
        assertTrue(orgAttendance.hasRole(orgAttendance.STUDENT_ROLE(), student1), "Student1 role not assigned");
        assertTrue(orgAttendance.hasRole(orgAttendance.STUDENT_ROLE(), student2), "Student2 role not assigned");
    }
    
    function testAssignRole() public {
        address newStudent = address(5);
        
        vm.startPrank(admin);
        orgAttendance.assignRole(newStudent, orgAttendance.STUDENT_ROLE());
        vm.stopPrank();
        
        assertTrue(orgAttendance.hasRole(orgAttendance.STUDENT_ROLE(), newStudent), "New student role not assigned");
        
        // Check student tracking for leaderboard
        address[] memory addresses;
        uint256[] memory counts;
        (addresses, counts) = orgAttendance.getLeaderboard();
        
        bool foundNewStudent = false;
        for (uint i = 0; i < addresses.length; i++) {
            if (addresses[i] == newStudent) {
                foundNewStudent = true;
                break;
            }
        }
        
        assertTrue(foundNewStudent, "New student not found in leaderboard");
    }
    
    function testCreateAttendance() public {
        vm.startPrank(teacher);
        orgAttendance.createAttendance(attendanceId, sessionTitle);
        vm.stopPrank();
        
        // Check attendance record
        (
            string memory title,
            uint256 tokenId,
            address teacherAddr,
            bool claimed,
            address studentAddr
        ) = orgAttendance.attendanceRecords(attendanceId);
        
        assertEq(title, sessionTitle, "Session title mismatch");
        assertEq(teacherAddr, teacher, "Teacher address mismatch");
        assertFalse(claimed, "Should not be claimed initially");
        assertEq(studentAddr, address(0), "Student address should be zero");
        
        // Check attendance count
        assertEq(orgAttendance.getAttendanceCount(), 1, "Attendance count should be 1");
        
        // Check attendance ID storage
        assertEq(orgAttendance.attendanceIds(0), attendanceId, "Attendance ID mismatch");
    }
    
    function testClaimNFT() public {
        // Create attendance record
        vm.prank(teacher);
        orgAttendance.createAttendance(attendanceId, sessionTitle);
        
        // Get token ID from attendance record
        (,uint256 tokenId,,,) = orgAttendance.attendanceRecords(attendanceId);
        
        // Check NFT is owned by contract initially
        assertEq(attendanceNFT.ownerOf(tokenId), address(orgAttendance), "NFT should be owned by contract initially");
        
        // Student claims the NFT
        vm.startPrank(student1);
        orgAttendance.claimNFT(attendanceId);
        vm.stopPrank();
        
        // Check attendance record is updated
        (,, address teacherAddr, bool claimed, address studentAddr) = orgAttendance.attendanceRecords(attendanceId);
        assertTrue(claimed, "Should be marked as claimed");
        assertEq(studentAddr, student1, "Student address mismatch");
        
        // Check NFT ownership is transferred
        assertEq(attendanceNFT.ownerOf(tokenId), student1, "NFT should be transferred to student");
        
        // Check student NFT count
        assertEq(orgAttendance.studentNFTCount(student1), 1, "Student NFT count should be 1");
    }
    
    function testGetLeaderboard() public {
        // Create two attendance records
        vm.startPrank(teacher);
        orgAttendance.createAttendance(attendanceId, sessionTitle);
        orgAttendance.createAttendance("JS102-2025", "JavaScript Advanced");
        vm.stopPrank();
        
        // Students claim NFTs
        vm.startPrank(student1);
        orgAttendance.claimNFT(attendanceId);
        vm.stopPrank();
        
        vm.startPrank(student2);
        orgAttendance.claimNFT("JS102-2025");
        vm.stopPrank();
        
        // Get leaderboard
        address[] memory addresses;
        uint256[] memory counts;
        (addresses, counts) = orgAttendance.getLeaderboard();
        
        // Verify leaderboard
        assertEq(addresses.length, 2, "Should have 2 students on leaderboard");
        assertEq(counts.length, 2, "Should have 2 counts on leaderboard");
        
        // Find student1 and student2 in leaderboard
        bool foundStudent1 = false;
        bool foundStudent2 = false;
        
        for (uint i = 0; i < addresses.length; i++) {
            if (addresses[i] == student1) {
                assertEq(counts[i], 1, "Student1 should have 1 NFT");
                foundStudent1 = true;
            } else if (addresses[i] == student2) {
                assertEq(counts[i], 1, "Student2 should have 1 NFT");
                foundStudent2 = true;
            }
        }
        
        assertTrue(foundStudent1, "Student1 not found in leaderboard");
        assertTrue(foundStudent2, "Student2 not found in leaderboard");
    }
    
    function testGetStudentCount() public {
        uint256 studentCount = orgAttendance.getStudentCount();
        assertEq(studentCount, 2, "Should have 2 students");
    }
    
    function test_RevertWhen_CreateAttendanceDuplicate() public {
        vm.startPrank(teacher);
        orgAttendance.createAttendance(attendanceId, sessionTitle);
        
        // Try to create attendance with same ID (should fail)
        vm.expectRevert("OrgAttendance: Attendance ID already exists");
        orgAttendance.createAttendance(attendanceId, "Another Session");
        vm.stopPrank();
    }
    
    function test_RevertWhen_CreateAttendanceUnauthorized() public {
        // Try to create attendance as student (should fail)
        vm.prank(student1);
        vm.expectRevert();
        orgAttendance.createAttendance(attendanceId, sessionTitle);
    }
    
    function test_RevertWhen_ClaimNonexistentAttendance() public {
        // Try to claim nonexistent attendance
        vm.prank(student1);
        vm.expectRevert("OrgAttendance: Attendance ID does not exist");
        orgAttendance.claimNFT("NONEXISTENT");
    }
    
    function test_RevertWhen_ClaimTwice() public {
        // Create attendance
        vm.prank(teacher);
        orgAttendance.createAttendance(attendanceId, sessionTitle);
        
        // First claim (should succeed)
        vm.startPrank(student1);
        orgAttendance.claimNFT(attendanceId);
        vm.stopPrank();
        
        // Second claim (should fail)
        vm.prank(student2);
        vm.expectRevert("OrgAttendance: Attendance already claimed");
        orgAttendance.claimNFT(attendanceId);
    }
    
    function test_RevertWhen_ClaimUnauthorized() public {
        // Create attendance
        vm.prank(teacher);
        orgAttendance.createAttendance(attendanceId, sessionTitle);
        
        // Try to claim as non-student
        address nonStudent = address(10);
        vm.prank(nonStudent);
        vm.expectRevert();
        orgAttendance.claimNFT(attendanceId);
    }
}
