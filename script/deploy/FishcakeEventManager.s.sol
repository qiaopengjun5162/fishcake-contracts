// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

import {Script, console} from "forge-std/Script.sol";
import {FishcakeEventManager} from "../../src/contracts/core/FishcakeEventManager.sol";

contract FishcakeEventManagerScript is Script {
    ProxyAdmin public fishcakeProxyAdmin;
    FishcakeEventManager public fishcakeEventManager;

    function run() public {
        address _fccAddress = vm.envAddress("HOLESKY_FISHCAKE_COIN");
        address _usdtTokenAddr = vm.envAddress("HOLESKY_USDT_TOKEN");
        address _NFTManagerAddr = vm.envAddress("NFT_MANAGER_ADDRESS");

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);

        fishcakeProxyAdmin = new ProxyAdmin(deployerAddress);
        console.log("fishcakeProxyAdmin:", address(fishcakeProxyAdmin));

        fishcakeEventManager = new FishcakeEventManager();
        console.log("fishcakeEventManager:", address(fishcakeEventManager));

        TransparentUpgradeableProxy proxyFishcakeEventManager = new TransparentUpgradeableProxy(
            address(fishcakeEventManager),
            address(fishcakeProxyAdmin),
            abi.encodeWithSelector(
                FishcakeEventManager.initialize.selector, deployerAddress, _fccAddress, _usdtTokenAddr, _NFTManagerAddr
            )
        );
        console.log(
            "TransparentUpgradeableProxy proxyFishcakeEventManager deployed at:", address(proxyFishcakeEventManager)
        );

        vm.stopBroadcast();
    }
}
