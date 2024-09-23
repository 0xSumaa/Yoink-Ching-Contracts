// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {YoinkChing} from "../src/YoinkChing.sol";
import {MockMoxie} from "../test/MockMoxie.sol";

contract TransferMoxie is Script {
    YoinkChing public yoinkChing;
    address public constant MOXIE_ADDRESS =
        0x44718aaFb9245D6374bd9f939D8DCaF564bB14b6;
    uint256 public constant TRANSFER_AMOUNT = 100_000 ether;
    address public constant TRANSFER_TO =
        0x29F0cbED796f0C6663f1ca3F0e3c51De29c78Ec8;
    function setUp() public {}

    function run() public {
        uint256 interactorKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(interactorKey);
        MockMoxie moxie = MockMoxie(MOXIE_ADDRESS);
        moxie.transfer(TRANSFER_TO, TRANSFER_AMOUNT);
        payable(TRANSFER_TO).transfer(0.01 ether);
        vm.stopBroadcast();
    }
}
