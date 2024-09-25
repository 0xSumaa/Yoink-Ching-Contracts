// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {YoinkChing} from "../src/YoinkChing.sol";
import {MockMoxie} from "../test/MockMoxie.sol";

contract YoinkChingDeploy is Script {
    YoinkChing public yoinkChing;
    address public constant MOXIE_ADDRESS =
        0x8C9037D1Ef5c6D1f6816278C7AAF5491d24CD527;
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);
        vm.startBroadcast(deployerPrivateKey);
        yoinkChing = new YoinkChing(MOXIE_ADDRESS);
        MockMoxie moxie = MockMoxie(MOXIE_ADDRESS);
        moxie.approve(address(yoinkChing), 100000 ether);
        yoinkChing.startGame(100000 ether);

        console.logString("YoinkChing deployed at address: ");
        console.logAddress(address(yoinkChing));

        vm.stopBroadcast();
    }
}
