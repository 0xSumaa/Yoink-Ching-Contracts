// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {YoinkChing} from "../src/YoinkChing.sol";
import {MockMoxie} from "../test/MockMoxie.sol";

contract YoinkChingDeploy is Script {
    YoinkChing public yoinkChing;
    address public constant PLAYER_TWO =
        0x29F0cbED796f0C6663f1ca3F0e3c51De29c78Ec8;
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);
        vm.startBroadcast(deployerPrivateKey);
        MockMoxie moxie = new MockMoxie("TestMoxie", "TMOXIE");
        yoinkChing = new YoinkChing(address(moxie));

        moxie.mint(deployerAddress, 1_000_000 * 10 ** 18);
        moxie.mint(PLAYER_TWO, 1_000_000 * 10 ** 18);
        moxie.approve(address(yoinkChing), 100_000 * 10 ** 18);
        yoinkChing.startGame(100_000 ether);

        console.logString("YoinkChing deployed at address: ");
        console.logAddress(address(yoinkChing));
        console.logString("Moxie deployed at address: ");
        console.logAddress(address(moxie));

        vm.stopBroadcast();
    }
}
