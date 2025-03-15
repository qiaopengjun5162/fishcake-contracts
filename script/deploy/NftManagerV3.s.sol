// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

import {Script, console} from "forge-std/Script.sol";
import {NftManagerV3} from "../../src/contracts/core/token/NftManagerV3.sol";

contract NftManagerV3Script is Script {
    ProxyAdmin public nftManagerV3ProxyAdmin;
    NftManagerV3 public nftManagerV3;

    function run() public {
        address _fccTokenAddr = vm.envAddress("FISHCAKE_COIN");
        address _tokenUsdtAddr = vm.envAddress("USDT_ADDRESS");
        address _redemptionPoolAddress = vm.envAddress("REDEMPTION_POOL_ADDR");
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);

        nftManagerV3ProxyAdmin = new ProxyAdmin(deployerAddress);
        console.log("fishcakeProxyAdmin:", address(nftManagerV3ProxyAdmin));

        nftManagerV3 = new NftManagerV3();
        console.log("NftManagerV3 deployed at:", address(nftManagerV3));

        TransparentUpgradeableProxy proxyNftManagerV3 = new TransparentUpgradeableProxy(
            address(nftManagerV3),
            address(nftManagerV3ProxyAdmin),
            abi.encodeWithSelector(
                NftManagerV3.initialize.selector, deployerAddress, _fccTokenAddr, _tokenUsdtAddr, _redemptionPoolAddress
            )
        );
        console.log("TransparentUpgradeableProxy proxyNftManagerV3 deployed at:", address(proxyNftManagerV3));

        vm.stopBroadcast();
    }
}
