// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "forge-std/Vm.sol";
import {Script, console} from "forge-std/Script.sol";
import {FishcakeEventManagerV1} from "../../src/contracts/core/FishcakeEventManagerV1.sol";
import {EmptyContract} from "../../src/utils/EmptyContract.sol";

contract FishcakeEventManagerV1TestScript is Script {
    EmptyContract public emptyContract;
    ProxyAdmin public proxyAdminFishcakeEventManagerV1;
    FishcakeEventManagerV1 public fishcakeEventManagerV1;
    FishcakeEventManagerV1 public fishcakeEventManagerV1Implementation;

    function run() public {
        console.log("\n=== fishcakeEventManagerV1 Deployment ===");

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);
        emptyContract = new EmptyContract();
        TransparentUpgradeableProxy proxyFishcakeEventManagerV1 =
            new TransparentUpgradeableProxy(address(emptyContract), deployerAddress, "");
        fishcakeEventManagerV1 = FishcakeEventManagerV1(payable(address(proxyFishcakeEventManagerV1)));

        fishcakeEventManagerV1Implementation = new FishcakeEventManagerV1();
        console.log("fishcakeEventManagerV1Implementation:", address(fishcakeEventManagerV1Implementation));
        proxyAdminFishcakeEventManagerV1 = ProxyAdmin(getProxyAdminAddress(address(proxyFishcakeEventManagerV1)));
        console.log("proxyAdminFishcakeEventManagerV1:", address(proxyAdminFishcakeEventManagerV1));

        proxyAdminFishcakeEventManagerV1.upgradeAndCall(
            ITransparentUpgradeableProxy(address(fishcakeEventManagerV1)),
            address(fishcakeEventManagerV1Implementation),
            bytes("")
        );

        console.log(
            "\n=== FishcakeEventManagerV1 Deployment Summary ===\n" "Deployer:    %s\n" "Contract:    %s\n"
            "Status:      Upgrade Completed\n" "================================",
            deployerAddress,
            address(fishcakeEventManagerV1Implementation)
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
