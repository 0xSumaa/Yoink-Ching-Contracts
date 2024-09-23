// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {YoinkChing} from "../src/YoinkChing.sol";
import {MockMoxie} from "./MockMoxie.sol";

contract YoinkChingTest is Test {
    YoinkChing public yoinkChing;
    MockMoxie public moxie;
    address public yoinkOwner;
    address[5] public players;
    uint256 constant INITIAL_BALANCE = 1_000_000 * 10 ** 18; // 1,000,000 tokens with 18 decimals

    function setUp() public {
        // Create MockMoxie token
        moxie = new MockMoxie("Moxie", "MOXIE");

        // Create YoinkChing contract
        yoinkChing = new YoinkChing(address(moxie));

        // Create 5 player accounts and mint tokens
        for (uint i = 0; i < 5; i++) {
            players[i] = vm.addr(i + 1);
            moxie.mint(players[i], INITIAL_BALANCE);
        }

        yoinkOwner = players[0];
    }

    function testConstructor() public {
        assertEq(yoinkChing.moxieAddress(), address(moxie));
    }

    function testConstructorWithZeroAddress() public {
        vm.expectRevert("invalid moxie address");
        new YoinkChing(address(0));
    }

    function testStartGame() public {
        uint256 startAmount = 50_000 * 10 ** 18;
        vm.startPrank(yoinkOwner);
        moxie.approve(address(yoinkChing), startAmount);
        yoinkChing.startGame(startAmount);
        vm.stopPrank();

        assertEq(yoinkChing.lastYoinker(), yoinkOwner);
        assertEq(yoinkChing.lastYoinked(), block.timestamp);
        assertEq(yoinkChing.gamesPlayed(), 1);
        assertEq(moxie.balanceOf(address(yoinkChing)), startAmount);
    }

    function testStartGameInsufficientAmount() public {
        uint256 startAmount = 49_999 * 10 ** 18;
        vm.startPrank(yoinkOwner);
        moxie.approve(address(yoinkChing), startAmount);
        vm.expectRevert("must start with at least 10 MOXIE");
        yoinkChing.startGame(startAmount);
        vm.stopPrank();
    }

    function testStartGameAlreadyStarted() public {
        uint256 startAmount = 50_000 * 10 ** 18;
        vm.startPrank(yoinkOwner);
        moxie.approve(address(yoinkChing), startAmount);
        yoinkChing.startGame(startAmount);

        vm.expectRevert("game already started");
        yoinkChing.startGame(startAmount);
        vm.stopPrank();
    }

    function testYoink() public {
        // Start the game
        uint256 startAmount = 50_000 * 10 ** 18;
        vm.startPrank(yoinkOwner);
        moxie.approve(address(yoinkChing), startAmount);
        yoinkChing.startGame(startAmount);
        vm.stopPrank();

        // Yoink
        vm.startPrank(players[1]);
        moxie.approve(address(yoinkChing), yoinkChing.YOINK_COST());
        yoinkChing.yoink();
        vm.stopPrank();

        assertEq(yoinkChing.lastYoinker(), players[1]);
        assertEq(yoinkChing.lastYoinked(), block.timestamp);
        assertEq(
            moxie.balanceOf(address(yoinkChing)),
            startAmount + yoinkChing.YOINK_COST()
        );
    }

    function testYoinkGameNotStarted() public {
        vm.startPrank(players[1]);
        moxie.approve(address(yoinkChing), yoinkChing.YOINK_COST());
        vm.expectRevert("game not started");
        yoinkChing.yoink();
        vm.stopPrank();
    }

    function testYoinkAndWin() public {
        // Start the game
        uint256 startAmount = 50_000 * 10 ** 18;
        vm.startPrank(yoinkOwner);
        moxie.approve(address(yoinkChing), startAmount);
        yoinkChing.startGame(startAmount);
        vm.stopPrank();

        // Yoink
        vm.startPrank(players[1]);
        moxie.approve(address(yoinkChing), yoinkChing.YOINK_COST());
        yoinkChing.yoink();
        vm.stopPrank();

        // Fast forward time
        vm.warp(block.timestamp + yoinkChing.HODL_TIME_TO_WIN() + 1);

        // Try to yoink again, which should trigger win condition
        uint256 balanceBefore = moxie.balanceOf(players[1]);
        vm.startPrank(players[2]);
        moxie.approve(address(yoinkChing), yoinkChing.YOINK_COST());
        yoinkChing.yoink();
        vm.stopPrank();

        uint256 expectedWinnings = startAmount + yoinkChing.YOINK_COST();
        assertEq(moxie.balanceOf(players[1]), balanceBefore + expectedWinnings);
        assertEq(yoinkChing.lastYoinker(), address(0));
        assertEq(yoinkChing.lastYoinked(), 0);
        assertEq(moxie.balanceOf(address(yoinkChing)), 0);
    }

    function testMultipleGames() public {
        // Game 1
        uint256 startAmount = 50_000 * 10 ** 18;
        vm.startPrank(yoinkOwner);
        moxie.approve(address(yoinkChing), startAmount);
        yoinkChing.startGame(startAmount);
        vm.stopPrank();

        vm.startPrank(players[1]);
        moxie.approve(address(yoinkChing), yoinkChing.YOINK_COST());
        yoinkChing.yoink();
        vm.stopPrank();

        vm.warp(block.timestamp + yoinkChing.HODL_TIME_TO_WIN() + 1);

        vm.startPrank(players[2]);
        moxie.approve(address(yoinkChing), yoinkChing.YOINK_COST());
        yoinkChing.yoink();
        vm.stopPrank();

        assertEq(yoinkChing.gamesPlayed(), 1);

        // Game 2
        vm.startPrank(players[3]);
        moxie.approve(address(yoinkChing), startAmount);
        yoinkChing.startGame(startAmount);
        vm.stopPrank();

        assertEq(yoinkChing.gamesPlayed(), 2);
    }
}
