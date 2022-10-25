// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {IAvatar} from "./SafeAware.sol";
import {ERC2771Context} from "./ERC2771Context.sol";
import {EIP1967Upgradeable} from "./EIP1967Upgradeable.sol";
import {IModuleMetadata} from "./IModuleMetadata.sol";

abstract contract FirmBase is EIP1967Upgradeable, ERC2771Context, IModuleMetadata {
    event Initialized(IAvatar indexed safe, IModuleMetadata indexed implementation);

    function __init_firmBase(IAvatar safe_, address trustedForwarder_) internal {
        // checks-effects-interactions violated so that the init event always fires first
        emit Initialized(safe_, _implementation());
        
        __init_setSafe(safe_);
        if (trustedForwarder_ != address(0)) {
            _setTrustedForwarder(trustedForwarder_, true);
        }
    }
}