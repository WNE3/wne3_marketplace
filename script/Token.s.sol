// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {Token} from "../src/Token.sol";

contract DeployToken is Script {
    function run() external returns (Token) {
        vm.startBroadcast();
        Token token = new Token();
        vm.stopBroadcast();
        return token;
    }
}
