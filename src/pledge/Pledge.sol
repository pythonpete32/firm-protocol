// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

import {FirmBase} from "../bases/FirmBase.sol";
import {ISafe} from "../bases/interfaces/ISafe.sol";

/**
 * @title Pledge
 * @author Firm (engineering@firm.org)
 * @notice Pledge manages the pledging of funds to shareholders
 */
contract Pledge is FirmBase {
    string public constant moduleId = "org.firm.pledge";
    uint256 public constant moduleVersion = 1;

    constructor() {} // Empty constructor

    function initialize(ISafe safe_, address trustedForwarder_) public {
        __init_firmBase(safe_, trustedForwarder_);
    }

    // Add more functions and state variables as needed
}
