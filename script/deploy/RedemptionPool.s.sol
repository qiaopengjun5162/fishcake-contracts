// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {RedemptionPool} from "../../src/contracts/core/RedemptionPool.sol";

contract RedemptionPoolScript is Script {
    RedemptionPool public redemptionPool;

    function run() public {
        address _fishcakeCoin = vm.envAddress("HOLESKY_FISHCAKE_COIN");
        address _usdtToken = vm.envAddress("HOLESKY_USDT_TOKEN");
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);
        console.log("deployerAddress", deployerAddress);

        vm.startBroadcast(deployerPrivateKey);

        redemptionPool = new RedemptionPool(_fishcakeCoin, _usdtToken);
        console.log("RedemptionPool deployed to:", address(redemptionPool));

        vm.stopBroadcast();
    }
}
