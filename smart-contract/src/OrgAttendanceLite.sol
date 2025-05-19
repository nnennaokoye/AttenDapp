// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./IAttendanceNFT.sol";

/**
 * @title OrgAttendanceLite
 * @dev Lightweight implementation for managing attendance tracking, role assignment, and NFT claims
 * Removes dependency on AccessControl to reduce contract size
 */
contract OrgAttendanceLite {
    // Roles as constants
    bytes32 public constant TEACHER_ROLE = keccak256("TEACHER_ROLE");
    bytes32 public constant STUDENT_ROLE = keccak256("STUDENT_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    
    // Simple role management
    mapping(address => mapping(bytes32 => bool)) private _roles;
    
    // Organization info
    string public name;
    string public description;
    string public badgeURI;
    
    // NFT contract
    IAttendanceNFT public attendanceNFT;
    
    // Attendance record struct
    struct AttendanceRecord {
        string sessionTitle;
        uint256 tokenId;
        address teacher;
        bool claimed;
        address student;
    }
    
    // Mapping from attendance ID to attendance record
    mapping(string => AttendanceRecord) public attendanceRecords;
    
    // Array of all attendance IDs
    string[] public attendanceIds;
    
    // Mapping from student address to number of NFTs claimed
    mapping(address => uint256) public studentNFTCount;
    
    // Array of all student addresses
    address[] public studentAddresses;
    
    // Events
    event RoleAssigned(address indexed account, bytes32 indexed role);
    event AttendanceCreated(string indexed attendanceId, string sessionTitle, address teacher);
    event AttendanceClaimed(string indexed attendanceId, address indexed student, uint256 tokenId);
    
    /**
     * @dev Constructor sets up the organization details and roles
     */
    constructor(
        string memory _name,
        string memory _description,
        string memory _badgeURI,
        address _attendanceNFT,
        address admin
    ) {
        name = _name;
        description = _description;
        badgeURI = _badgeURI;
        attendanceNFT = IAttendanceNFT(_attendanceNFT);
        
        // Grant admin role
        _roles[admin][ADMIN_ROLE] = true;
    }
    
    /**
     * @dev Modifier to restrict function to role holders
     */
    modifier onlyRole(bytes32 role) {
        require(_roles[msg.sender][role], "Not authorized");
        _;
    }
    
    /**
     * @dev Assigns a role to an account
     * @param account The address to assign the role to
     * @param role The role to assign
     */
    function assignRole(address account, bytes32 role) external onlyRole(ADMIN_ROLE) {
        require(role == TEACHER_ROLE || role == STUDENT_ROLE, "OrgAttendance: Invalid role");
        
        _roles[account][role] = true;
        
        // Track student addresses for leaderboard
        if (role == STUDENT_ROLE && studentNFTCount[account] == 0) {
            studentAddresses.push(account);
        }
        
        emit RoleAssigned(account, role);
    }
    
    /**
     * @dev Creates an attendance record for a session
     * @param attendanceId Unique ID for the attendance
     * @param sessionTitle Title of the session
     */
    function createAttendance(string calldata attendanceId, string calldata sessionTitle) 
        external 
        onlyRole(TEACHER_ROLE) 
    {
        require(bytes(attendanceRecords[attendanceId].sessionTitle).length == 0, "OrgAttendance: Attendance ID already exists");
        
        // Mint the NFT (held by the contract initially)
        uint256 tokenId = attendanceNFT.mint(address(this), sessionTitle, badgeURI);
        
        // Create the attendance record
        attendanceRecords[attendanceId] = AttendanceRecord({
            sessionTitle: sessionTitle,
            tokenId: tokenId,
            teacher: msg.sender,
            claimed: false,
            student: address(0)
        });
        
        attendanceIds.push(attendanceId);
        
        emit AttendanceCreated(attendanceId, sessionTitle, msg.sender);
    }
    
    /**
     * @dev Claims an attendance NFT
     * @param attendanceId The attendance ID to claim
     */
    function claimNFT(string calldata attendanceId) external onlyRole(STUDENT_ROLE) {
        AttendanceRecord storage record = attendanceRecords[attendanceId];
        
        require(bytes(record.sessionTitle).length > 0, "OrgAttendance: Attendance ID does not exist");
        require(!record.claimed, "OrgAttendance: Attendance already claimed");
        
        // Mark as claimed
        record.claimed = true;
        record.student = msg.sender;
        
        // Transfer the NFT to the student
        attendanceNFT.transferFrom(address(this), msg.sender, record.tokenId);
        
        // Update student NFT count
        studentNFTCount[msg.sender]++;
        
        emit AttendanceClaimed(attendanceId, msg.sender, record.tokenId);
    }
    
    /**
     * @dev Gets the total number of attendance records
     * @return The count of attendance records
     */
    function getAttendanceCount() external view returns (uint256) {
        return attendanceIds.length;
    }
    
    /**
     * @dev Gets the total number of students
     * @return The count of students
     */
    function getStudentCount() external view returns (uint256) {
        return studentAddresses.length;
    }
    
    /**
     * @dev Gets the leaderboard data for all students
     * @return addresses Array of student addresses
     * @return counts Array of NFT counts corresponding to each student
     */
    function getLeaderboard() external view returns (address[] memory addresses, uint256[] memory counts) {
        uint256 studentCount = studentAddresses.length;
        
        addresses = new address[](studentCount);
        counts = new uint256[](studentCount);
        
        for (uint256 i = 0; i < studentCount; i++) {
            address studentAddress = studentAddresses[i];
            addresses[i] = studentAddress;
            counts[i] = studentNFTCount[studentAddress];
        }
        
        return (addresses, counts);
    }
}
