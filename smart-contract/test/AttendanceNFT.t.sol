// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/AttendanceNFT.sol";

contract AttendanceNFTTest is Test {
    AttendanceNFT public attendanceNFT;
    
    address public admin = address(1);
    address public minter = address(2);
    address public recipient = address(3);
    
    string public orgName = "Blockchain Academy";
    string public nftSymbol = "BNFT";
    string public sessionTitle = "Ethereum Development";
    string public badgeURI = "ipfs://QmEthDevBadge";
    
    function setUp() public {
        vm.startPrank(admin);
        attendanceNFT = new AttendanceNFT(orgName, nftSymbol, admin);
        attendanceNFT.grantRole(attendanceNFT.MINTER_ROLE(), minter);
        vm.stopPrank();
    }
    
    function testInitialState() public {
        assertEq(attendanceNFT.name(), orgName, "NFT name mismatch");
        assertEq(attendanceNFT.symbol(), nftSymbol, "NFT symbol mismatch");
        assertEq(attendanceNFT.organizationName(), orgName, "Organization name mismatch");
        
        // Check roles
        assertTrue(attendanceNFT.hasRole(attendanceNFT.DEFAULT_ADMIN_ROLE(), admin), "Admin role not set");
        assertTrue(attendanceNFT.hasRole(attendanceNFT.MINTER_ROLE(), minter), "Minter role not set");
        assertFalse(attendanceNFT.hasRole(attendanceNFT.MINTER_ROLE(), recipient), "Recipient should not have minter role");
    }
    
    function testMint() public {
        vm.startPrank(minter);
        
        // Mint a new NFT
        uint256 tokenId = attendanceNFT.mint(recipient, sessionTitle, badgeURI);
        
        // Verify token ownership
        assertEq(attendanceNFT.ownerOf(tokenId), recipient, "Token ownership mismatch");
        
        // Verify token URI
        assertEq(attendanceNFT.tokenURI(tokenId), badgeURI, "Token URI mismatch");
        
        // Verify session title
        assertEq(attendanceNFT.getSessionTitle(tokenId), sessionTitle, "Session title mismatch");
        
        vm.stopPrank();
    }
    
    function testMintMultipleTokens() public {
        vm.startPrank(minter);
        
        // Mint three tokens
        uint256 firstTokenId = attendanceNFT.mint(recipient, "Session 1", "uri1");
        uint256 secondTokenId = attendanceNFT.mint(recipient, "Session 2", "uri2");
        uint256 thirdTokenId = attendanceNFT.mint(recipient, "Session 3", "uri3");
        
        // Verify incremental token IDs
        assertEq(secondTokenId, firstTokenId + 1, "Second token ID should be incremented");
        assertEq(thirdTokenId, secondTokenId + 1, "Third token ID should be incremented");
        
        // Verify all tokens are owned by recipient
        assertEq(attendanceNFT.ownerOf(firstTokenId), recipient, "First token ownership mismatch");
        assertEq(attendanceNFT.ownerOf(secondTokenId), recipient, "Second token ownership mismatch");
        assertEq(attendanceNFT.ownerOf(thirdTokenId), recipient, "Third token ownership mismatch");
        
        // Verify all session titles
        assertEq(attendanceNFT.getSessionTitle(firstTokenId), "Session 1", "First session title mismatch");
        assertEq(attendanceNFT.getSessionTitle(secondTokenId), "Session 2", "Second session title mismatch");
        assertEq(attendanceNFT.getSessionTitle(thirdTokenId), "Session 3", "Third session title mismatch");
        
        vm.stopPrank();
    }
    
    function testSupportsInterface() public {
        // Test ERC721 interface
        bytes4 erc721InterfaceId = 0x80ac58cd; // ERC721 interface ID
        assertTrue(attendanceNFT.supportsInterface(erc721InterfaceId), "Should support ERC721 interface");
        
        // Test ERC721Metadata interface
        bytes4 erc721MetadataInterfaceId = 0x5b5e139f; // ERC721Metadata interface ID
        assertTrue(attendanceNFT.supportsInterface(erc721MetadataInterfaceId), "Should support ERC721Metadata interface");
        
        // Test AccessControl interface
        bytes4 accessControlInterfaceId = 0x7965db0b; // AccessControl interface ID
        assertTrue(attendanceNFT.supportsInterface(accessControlInterfaceId), "Should support AccessControl interface");
        
        // Test invalid interface
        bytes4 invalidInterfaceId = 0x12345678;
        assertFalse(attendanceNFT.supportsInterface(invalidInterfaceId), "Should not support invalid interface");
    }
    
    function testTransferToken() public {
        address newOwner = address(4);
        
        // Mint a token
        vm.prank(minter);
        uint256 tokenId = attendanceNFT.mint(recipient, sessionTitle, badgeURI);
        
        // Transfer the token
        vm.startPrank(recipient);
        attendanceNFT.transferFrom(recipient, newOwner, tokenId);
        vm.stopPrank();
        
        // Verify new ownership
        assertEq(attendanceNFT.ownerOf(tokenId), newOwner, "Token ownership mismatch after transfer");
    }
    
    function test_RevertWhen_MintUnauthorized() public {
        // Try to mint as non-minter (should fail)
        vm.prank(recipient);
        vm.expectRevert();
        attendanceNFT.mint(recipient, sessionTitle, badgeURI);
    }
    
    function test_RevertWhen_GetSessionTitleForNonexistentToken() public {
        // Try to get session title for nonexistent token (should fail)
        vm.expectRevert("AttendanceNFT: Token does not exist");
        attendanceNFT.getSessionTitle(999);
    }
    
    function test_RevertWhen_TransferUnauthorized() public {
        // Mint a token
        vm.prank(minter);
        uint256 tokenId = attendanceNFT.mint(recipient, sessionTitle, badgeURI);
        
        address newOwner = address(4);
        address unauthorized = address(5);
        
        // Try to transfer as unauthorized user (should fail)
        vm.prank(unauthorized);
        vm.expectRevert();
        attendanceNFT.transferFrom(recipient, newOwner, tokenId);
    }
    
    function testRoleManagement() public {
        address newMinter = address(4);
        
        // Grant minter role as admin
        vm.startPrank(admin);
        attendanceNFT.grantRole(attendanceNFT.MINTER_ROLE(), newMinter);
        vm.stopPrank();
        
        // Verify role was granted
        assertTrue(attendanceNFT.hasRole(attendanceNFT.MINTER_ROLE(), newMinter), "Role not granted");
        
        // Test minting with new minter
        vm.startPrank(newMinter);
        uint256 tokenId = attendanceNFT.mint(recipient, sessionTitle, badgeURI);
        vm.stopPrank();
        
        // Verify token was minted
        assertEq(attendanceNFT.ownerOf(tokenId), recipient, "Token ownership mismatch");
        
        // Revoke role
        vm.startPrank(admin);
        attendanceNFT.revokeRole(attendanceNFT.MINTER_ROLE(), newMinter);
        vm.stopPrank();
        
        // Verify role was revoked
        assertFalse(attendanceNFT.hasRole(attendanceNFT.MINTER_ROLE(), newMinter), "Role not revoked");
        
        // Try to mint again (should fail)
        vm.startPrank(newMinter);
        vm.expectRevert();
        attendanceNFT.mint(recipient, "Another Session", "another-uri");
        vm.stopPrank();
    }
}
