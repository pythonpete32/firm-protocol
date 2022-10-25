// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "forge-std/Test.sol";

import {GnosisSafe} from "gnosis-safe/GnosisSafe.sol";
import {GnosisSafeProxyFactory} from "gnosis-safe/proxies/GnosisSafeProxyFactory.sol";

import {TestinprodFactory, UpgradeableModuleProxyFactory} from "src/factory/TestinprodFactory.sol";
import {FirmRelayer} from "src/metatx/FirmRelayer.sol";
import {Roles} from "src/roles/Roles.sol";
import {Budget} from "src/budget/Budget.sol";
import {LlamaPayStreams, LlamaPayFactory} from "src/budget/modules/streams/LlamaPayStreams.sol";

abstract contract DeployBase is Test {
    function baseContracts() internal virtual returns (address safeProxyFactory, address safeImpl, address llamaPayFactory);

    function run() public returns (TestinprodFactory factory, UpgradeableModuleProxyFactory moduleFactory) {
        (address safeProxyFactory, address safeImpl, address llamaPayFactory) = baseContracts();

        vm.startBroadcast();

        moduleFactory = new UpgradeableModuleProxyFactory();
        moduleFactory.register(new Roles());
        moduleFactory.register(new Budget());
        moduleFactory.register(new LlamaPayStreams(LlamaPayFactory(llamaPayFactory)));
        
        factory = new TestinprodFactory(
            GnosisSafeProxyFactory(safeProxyFactory),
            moduleFactory,
            new FirmRelayer(),
            safeImpl
        );

        vm.stopBroadcast();
    }
}

contract TestinprodDeploy is DeployBase {
    error UnsupportedChain(uint256 chainId);

    function baseContracts() internal view override returns (address safeProxyFactory, address safeImpl, address llamaPayFactory) {
        // Safe v1.3.0 from https://github.com/safe-global/safe-deployments/blob/8dea757/src/assets/v1.3.0/proxy_factory.json
        // LlamaPay v1 from https://docs.llamapay.io/technical-stuff/contracts
        if (block.chainid == 1) {
            // Mainnet
            safeProxyFactory = 0xa6B71E26C5e0845f74c812102Ca7114b6a896AB2;
            safeImpl = 0xd9Db270c1B5E3Bd161E8c8503c55cEABeE709552;
            llamaPayFactory = 0xde1C04855c2828431ba637675B6929A684f84C7F;
        } else if (block.chainid == 5) {
            // Goerli
            safeProxyFactory = 0xa6B71E26C5e0845f74c812102Ca7114b6a896AB2;
            safeImpl = 0xd9Db270c1B5E3Bd161E8c8503c55cEABeE709552;
            llamaPayFactory = 0xcCDd688d7eDcF89bFa217492E247d1395FcEC23D;
        } else {
            revert UnsupportedChain(block.chainid);
        }
    }
}