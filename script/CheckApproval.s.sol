// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {YoinkChing} from "../src/YoinkChing.sol";
import {MockMoxie} from "../test/MockMoxie.sol";

contract CheckApproval is Script {
    YoinkChing public yoinkChing;
    address public constant MOXIE_ADDRESS =
        0x44718aaFb9245D6374bd9f939D8DCaF564bB14b6;
    address public constant YOINK_ADDRESS =
        0x9a4B72E31a5aF83332451555B939C5d45c4B4c18;
    address public constant CHECK_ADDRESS =
        0x9a4B72E31a5aF83332451555B939C5d45c4B4c18;
    function setUp() public {}

    function run() public {
        uint256 interactorKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(interactorKey);
        MockMoxie moxie = MockMoxie(MOXIE_ADDRESS);
        uint256 approval = moxie.allowance(CHECK_ADDRESS, YOINK_ADDRESS);
        console.logString("Approval: ");
        console.logUint(approval);
        vm.stopBroadcast();
    }
}
