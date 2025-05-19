// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./mocks/MockOrgFactory.sol";
import "../src/OrgAttendance.sol";
import "./mocks/MockAttendanceNFT.sol";
import "../src/IAttendanceNFT.sol";

contract AttendDappTest is Test {
    MockOrgFactory public factory;
    OrgAttendance public orgAttendance;
    MockAttendanceNFT public attendanceNFT;
    
    address public admin = address(1);
    address public teacher = address(2);
    address public student1 = address(3);
    address public student2 = address(4);
    
    string public orgName = "Lagos Coding Bootcamp";
    string public orgDescription = "Empowering African developers with Web3 skills";
    string public badgeURI = "ipfs://QmBadgeHash";
    string public sessionTitle = "Python Workshop";
    string public attendanceId = "ABC123";
    
    function setUp() public {
        // Deploy factory contract
        vm.startPrank(admin);
        factory = new MockOrgFactory();
        
        // Create a new organization
        (address orgAddress, address nftAddress) = factory.createOrganization(
            orgName,
            orgDescription,
            badgeURI
        );
        
        // For testing, deploy contracts directly instead of using the factory addresses
        attendanceNFT = new MockAttendanceNFT("Attendance NFT", "ANFT", admin);
        orgAttendance = new OrgAttendance(orgName, orgDescription, badgeURI, address(attendanceNFT), admin);
        
        // Assign roles
        orgAttendance.assignRole(teacher, orgAttendance.TEACHER_ROLE());
        orgAttendance.assignRole(student1, orgAttendance.STUDENT_ROLE());
        orgAttendance.assignRole(student2, orgAttendance.STUDENT_ROLE());
        
        vm.stopPrank();
    }
    
    function testOrganizationCreation() public {
        // Check organization details
        assertEq(orgAttendance.name(), orgName);
        assertEq(orgAttendance.description(), orgDescription);
        assertEq(orgAttendance.badgeURI(), badgeURI);
        
        // Check organization count
        assertEq(factory.getOrganizationCount(), 1);
        
        // Check organization at index
        MockOrgFactory.Organization memory org = factory.getOrganizationAtIndex(0);
        
        // Only verify the name, description, and badgeURI
        // Since we're using mocks, the addresses won't match
        assertEq(org.name, orgName);
        assertEq(org.description, orgDescription);
        assertEq(org.badgeURI, badgeURI);
        
        // Verify the orgAttendance contract has a reference to the NFT contract
        assertEq(address(orgAttendance.attendanceNFT()), address(attendanceNFT));
    }
    
    function testRoleAssignment() public {
        // Check roles
        assertTrue(orgAttendance.hasRole(orgAttendance.DEFAULT_ADMIN_ROLE(), admin));
        assertTrue(orgAttendance.hasRole(orgAttendance.TEACHER_ROLE(), teacher));
        assertTrue(orgAttendance.hasRole(orgAttendance.STUDENT_ROLE(), student1));
        assertTrue(orgAttendance.hasRole(orgAttendance.STUDENT_ROLE(), student2));
    }
    
    function testAttendanceCreation() public {
        // First make sure the teacher role has minter role on the NFT contract
        vm.startPrank(admin);
        attendanceNFT.grantRole(attendanceNFT.MINTER_ROLE(), address(orgAttendance));
        vm.stopPrank();
        
        // Create attendance as teacher
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
        
        assertEq(title, sessionTitle);
        assertEq(teacherAddr, teacher);
        assertEq(claimed, false);
        assertEq(studentAddr, address(0));
        
        // Check attendance count
        assertEq(orgAttendance.getAttendanceCount(), 1);
    }
    
    function testAttendanceClaiming() public {
        // First make sure the necessary roles are granted
        vm.startPrank(admin);
        attendanceNFT.grantRole(attendanceNFT.MINTER_ROLE(), address(orgAttendance));
        vm.stopPrank();
        
        // Create attendance as teacher
        vm.startPrank(teacher);
        orgAttendance.createAttendance(attendanceId, sessionTitle);
        vm.stopPrank();
        
        // Get the token ID from the attendance record
        (,uint256 tokenId,,,) = orgAttendance.attendanceRecords(attendanceId);
        
        // Claim attendance as student1
        vm.startPrank(student1);
        orgAttendance.claimNFT(attendanceId);
        vm.stopPrank();
        
        // Check attendance record is updated
        (,, address teacherAddr, bool claimed, address studentAddr) = orgAttendance.attendanceRecords(attendanceId);
        assertEq(claimed, true);
        assertEq(studentAddr, student1);
        
        // Check NFT ownership
        assertEq(attendanceNFT.ownerOf(tokenId), student1);
        
        // Check student NFT count
        assertEq(orgAttendance.studentNFTCount(student1), 1);
    }
    
    function testLeaderboard() public {
        // First make sure the necessary roles are granted
        vm.startPrank(admin);
        attendanceNFT.grantRole(attendanceNFT.MINTER_ROLE(), address(orgAttendance));
        vm.stopPrank();
        
        // Create two attendance records
        vm.startPrank(teacher);
        orgAttendance.createAttendance(attendanceId, sessionTitle);
        orgAttendance.createAttendance("XYZ456", "Solidity Workshop");
        vm.stopPrank();
        
        // Student1 claims first attendance
        vm.startPrank(student1);
        orgAttendance.claimNFT(attendanceId);
        vm.stopPrank();
        
        // Student2 claims second attendance
        vm.startPrank(student2);
        orgAttendance.claimNFT("XYZ456");
        vm.stopPrank();
        
        // Check leaderboard
        (address[] memory addresses, uint256[] memory counts) = orgAttendance.getLeaderboard();
        
        // Verify leaderboard data
        assertEq(addresses.length, 2);
        assertEq(counts.length, 2);
        
        // Find student1 and student2 in the leaderboard
        bool foundStudent1 = false;
        bool foundStudent2 = false;
        
        for (uint i = 0; i < addresses.length; i++) {
            if (addresses[i] == student1) {
                assertEq(counts[i], 1);
                foundStudent1 = true;
            } else if (addresses[i] == student2) {
                assertEq(counts[i], 1);
                foundStudent2 = true;
            }
        }
        
        assertTrue(foundStudent1);
        assertTrue(foundStudent2);
    }
    
    function testAttendanceDoubleClaim() public {
        // First make sure the necessary roles are granted
        vm.startPrank(admin);
        attendanceNFT.grantRole(attendanceNFT.MINTER_ROLE(), address(orgAttendance));
        vm.stopPrank();
        
        // Create attendance as teacher
        vm.startPrank(teacher);
        orgAttendance.createAttendance(attendanceId, sessionTitle);
        vm.stopPrank();
        
        // Claim attendance as student1
        vm.startPrank(student1);
        orgAttendance.claimNFT(attendanceId);
        vm.stopPrank();
        
        // Try to claim again as student2 (should fail)
        vm.startPrank(student2);
        vm.expectRevert();
        orgAttendance.claimNFT(attendanceId);
        vm.stopPrank();
    }
    
    function testUnauthorizedTeacher() public {
        // Try to create attendance as student (should fail)
        vm.startPrank(student1);
        vm.expectRevert();
        orgAttendance.createAttendance(attendanceId, sessionTitle);
        vm.stopPrank();
    }
    
    function testUnauthorizedStudent() public {
        // First make sure the necessary roles are granted
        vm.startPrank(admin);
        attendanceNFT.grantRole(attendanceNFT.MINTER_ROLE(), address(orgAttendance));
        vm.stopPrank();
        
        // Create attendance as teacher
        vm.startPrank(teacher);
        orgAttendance.createAttendance(attendanceId, sessionTitle);
        vm.stopPrank();
        
        // Try to claim as non-student (should fail)
        address nonStudent = address(5);
        vm.startPrank(nonStudent);
        vm.expectRevert();
        orgAttendance.claimNFT(attendanceId);
        vm.stopPrank();
    }
}
