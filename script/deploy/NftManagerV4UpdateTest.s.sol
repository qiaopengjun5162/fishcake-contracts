// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "forge-std/Vm.sol";
import {Script, console} from "forge-std/Script.sol";
import {NftManagerV4} from "../../src/contracts/core/token/NftManagerV4.sol";
import {EmptyContract} from "../../src/utils/EmptyContract.sol";

contract NftManagerV4TestScript is Script {
    EmptyContract public emptyContract;
    ProxyAdmin public proxyAdminNftManager;
    NftManagerV4 public nftManagerV4;
    NftManagerV4 public nftManagerV4Implementation;

    function run() public {
        console.log("\n=== NftManagerV4 Deployment ===");

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);
        emptyContract = new EmptyContract();
        TransparentUpgradeableProxy proxyNftManagerV4 =
            new TransparentUpgradeableProxy(address(emptyContract), deployerAddress, "");
        nftManagerV4 = NftManagerV4(payable(address(proxyNftManagerV4)));

        nftManagerV4Implementation = new NftManagerV4();
        console.log("nftManagerV4Implementation:", address(nftManagerV4Implementation));
        proxyAdminNftManager = ProxyAdmin(getProxyAdminAddress(address(proxyNftManagerV4)));

        proxyAdminNftManager.upgradeAndCall(
            ITransparentUpgradeableProxy(address(nftManagerV4)), address(nftManagerV4Implementation), bytes("")
        );

        console.log(
            "\n=== NftManagerV4 Deployment Summary ===\n" "Deployer:    %s\n" "Contract:    %s\n"
            "Status:      Upgrade Completed\n" "================================",
            deployerAddress,
            address(nftManagerV4Implementation)
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
