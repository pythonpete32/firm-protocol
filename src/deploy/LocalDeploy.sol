// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "../factory/FirmFactory.sol";
import {IRoles, IAvatar} from "../roles/Roles.sol";

contract LocalDeploy {
    GnosisSafeProxyFactory public safeProxyFactory = new GnosisSafeProxyFactory();
    UpgradeableModuleProxyFactory public moduleProxyFactory = new UpgradeableModuleProxyFactory();
    address public safeImpl = address(new GnosisSafe());
    address public rolesImpl = address(new Roles(IAvatar(address(10))));
    address public budgetImpl = address(new Budget(IAvatar(address(10)), IRoles(address(10))));

    FirmFactory public firmFactory = new FirmFactory(
            safeProxyFactory,
            moduleProxyFactory,
            safeImpl,
            rolesImpl,
            budgetImpl
        );

    constructor() {
        // deploy a test firm
        firmFactory.createFirm(msg.sender);
    }
}
