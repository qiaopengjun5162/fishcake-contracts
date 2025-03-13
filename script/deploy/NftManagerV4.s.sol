// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin-foundry-upgrades/Upgrades.sol";
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "forge-std/Vm.sol";
import "@openzeppelin-foundry-upgrades/Upgrades.sol";

import {Script, console} from "forge-std/Script.sol";
import {NftManagerV4} from "../../src/contracts/core/token/NftManagerV4.sol";

contract NftManagerV4Script is Script {
    ProxyAdmin public proxyAdminNftManager;

    function run() public {
        address proxyAdminNftManagerV3 = vm.envAddress("NFT_MANAGER_V3_PROXY_ADMIN");
        address proxyNftManagerV3 = vm.envAddress("NFT_MANAGER_V3_TRANSPARENT_UPGRADEABLE_PROXY");

        address _fccTokenAddr = vm.envAddress("HOLESKY_FISHCAKE_COIN");
        address _tokenUsdtAddr = vm.envAddress("HOLESKY_USDT_TOKEN");
        address _redemptionPoolAddress = vm.envAddress("REDEMPTION_POOL_ADDR");

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);
        NftManagerV4 nftManagerV4 = new NftManagerV4();
        Upgrades.upgradeProxy(proxyAdminNftManagerV3, "NftManagerV4.sol:NftManagerV4", "");

        console.log(
            "\n=== NftManagerV4 Deployment Summary ===\n" "Deployer:    %s\n" "Contract:    %s\n"
            "Status:      Upgrade Completed\n" "================================",
            deployerAddress,
            address(nftManagerV4)
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
