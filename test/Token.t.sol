// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Token} from "../src/Token.sol";

contract TokenTest is Test {
    Token token;
    uint256 public constant PUBLIC_MINT = 0.02 ether;

    // uint256 public constant SPECIAL_LIST_MINT = 0.01 ether;
    // uint256 public constant LIMIT_PER_WALLET = 100;
    // uint256 public constant MAX_SUPPLY = 1500;

    function setUp() public {
        token = new Token();
    }

    function test_OnlyOwner() public {
        assertEq(token.owner(), address(this));
    }

    // function test_setURI() public {
    //     token.setURI("test");
    //     assertEq(token.uri(0), "test");
    // }

    function testFail_OnlyOwner() public {
        vm.prank(address(1));
        assertEq(token.owner(), address(1));
    }

    function test_setMintWindow() public {
        token.setMintWindow(true, false);
        assertEq(token.s_publicMintIsOpen(), true);
        assertEq(token.s_specialMintIsOpen(), false);
    }

    function test_setMintWindowAllowlist() public {
        address[] memory addr = new address[](2);
        addr[0] = address(1);
        addr[1] = address(2);
        token.setMintWindow(addr);
        assertEq(token.s_specialMintIsOpen(), true);
        assertEq(token.allowList(address(1)), true);
    }

    // fix this
    function test_publicMint() public payable {
        token.setMintWindow(true, false);
        uint256 balanceBefore = address(this).balance;
        token.publicMint{value: PUBLIC_MINT * 1 wei}(0, 1 wei);
        uint256 balanceAfter = address(this).balance;
        assertEq(balanceBefore - balanceAfter, PUBLIC_MINT * 1 wei);
    }
   
   //add value
   function test_specialListMint() public{
        address[] memory addr = new address[](2);
        addr[0] = address(1);
        addr[1] = address(2);
        token.setMintWindow(addr);
        assertEq(token.allowList(address(1)), true);
        assertEq(token.s_specialMintIsOpen(), true);
        // assertEq({value: })
   }

    //fix this too
//    function test_mint() public {
//         token.mint(0, 1);
//         assertEq(token.totalSupply(0), 1);
//    }

   function test_withdraw() public {
        uint256 balanceBefore = address(this).balance;
        token.withdraw(address(3));
        uint256 balanceAfter = address(this).balance;
        uint256 withdrawAmount = balanceBefore - balanceAfter;
        assertEq(address(3).balance, withdrawAmount);
   }

//    function test_uri() public {
//         assertEq(token.uri(0), "");
//    }
}
