// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

import {Script, console} from "forge-std/Script.sol";
import {FishCakeCoin} from "../../src/contracts/core/token/FishCakeCoin.sol";

contract FishCakeCoinScript is Script {
    ProxyAdmin public fishCakeCoinProxyAdmin;
    FishCakeCoin public fishCakeCoin;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);

        fishCakeCoinProxyAdmin = new ProxyAdmin(deployerAddress);
        console.log("fishcakeProxyAdmin:", address(fishCakeCoinProxyAdmin));

        fishCakeCoin = new FishCakeCoin();

        console.log("FishCakeCoin deployed at:", address(fishCakeCoin));

        TransparentUpgradeableProxy proxyFishCakeCoin = new TransparentUpgradeableProxy(
            address(fishCakeCoin),
            address(fishCakeCoinProxyAdmin),
            abi.encodeWithSelector(FishCakeCoin.initialize.selector, deployerAddress, address(0))
        );
        console.log("TransparentUpgradeableProxy proxyFishCakeCoin deployed at:", address(proxyFishCakeCoin));

        vm.stopBroadcast();
    }
}
