// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {YoinkChing} from "../src/YoinkChing.sol";
import {MockMoxie} from "../test/MockMoxie.sol";

contract YoinkChingDeploy is Script {
    YoinkChing public yoinkChing;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);
        vm.startBroadcast(deployerPrivateKey);
        MockMoxie moxie = new MockMoxie("TestMoxie", "TMOXIE");
        moxie.mint(deployerAddress, 1_000_000 * 10 ** 18);
        yoinkChing = new YoinkChing(address(moxie));
        console.logString("YoinkChing deployed at address: ");
        console.logAddress(address(yoinkChing));
        console.logString("Moxie deployed at address: ");
        console.logAddress(address(moxie));
        vm.stopBroadcast();
    }
}
