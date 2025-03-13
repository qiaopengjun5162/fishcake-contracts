// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "forge-std/Vm.sol";
import {Script, console} from "forge-std/Script.sol";
import {FishcakeEventManagerV1} from "../../src/contracts/core/FishcakeEventManagerV1.sol";

contract FishcakeEventManagerV1Script is Script {
    ProxyAdmin public proxyAdminFishcakeEventManager;

    function run() public {
        address proxyAdmin = vm.envAddress("PROXY_ADMIN_FISHCAKE_EVENT_MANAGER");
        console.log("proxyAdmin:", proxyAdmin);
        address proxyFishcakeEventManager = vm.envAddress("PROXY_FISHCAKE_EVENT_MANAGER");

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);
        console.log("Deployer:", deployerAddress);

        vm.startBroadcast(deployerPrivateKey);
        FishcakeEventManagerV1 fishcakeEventManagerV1 = new FishcakeEventManagerV1();

        console.log("FishcakeEventManagerV1:", address(fishcakeEventManagerV1));
        proxyAdminFishcakeEventManager = ProxyAdmin(getProxyAdminAddress(address(proxyFishcakeEventManager)));
        console.log("proxyAdminFishcakeEventManager:", address(proxyAdminFishcakeEventManager));

        ProxyAdmin(proxyAdmin).upgradeAndCall(
            ITransparentUpgradeableProxy(proxyFishcakeEventManager), address(fishcakeEventManagerV1), bytes("")
        );

        vm.stopBroadcast();
    }

    function getProxyAdminAddress(address proxy) internal view returns (address) {
        address CHEATCODE_ADDRESS = 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D;
        Vm vm = Vm(CHEATCODE_ADDRESS);

        bytes32 adminSlot = vm.load(proxy, ERC1967Utils.ADMIN_SLOT);
        return address(uint160(uint256(adminSlot)));
    }
}
