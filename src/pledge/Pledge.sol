// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

import {FirmBase} from "../bases/FirmBase.sol";
import {ISafe} from "../bases/interfaces/ISafe.sol";
import {Captable} from "../captable/Captable.sol";

/**
 * @title Pledge
 * @author Firm (engineering@firm.org)
 * @notice Pledge manages the pledging of funds to shareholders
 */
contract Pledge is FirmBase {
    string public constant moduleId = "org.firm.pledge";
    uint256 public constant moduleVersion = 1;

    // State variables
    uint256 public minContributionPerWeek;
    uint256 public maxContributionPerWeek;
    uint256 public minBufferWeeks;
    uint256 public startWeek;
    uint256 public currentWeek;
    Captable public captable;
    uint256 public shareClassId;

    // week -> user -> amount
    mapping(uint256 => mapping(address => uint256)) public userContributions;

    // mapping(address => UserContribution) public userContributions;
    mapping(uint256 => uint256) public totalWeekContributions;

    event ContributionMade(address user, uint256 amount, uint256 week);
    event TokensMinted(address user, uint256 amount, uint256 week);

    constructor() {} // Empty constructor

    function initialize(
        ISafe safe_,
        address trustedForwarder_,
        uint256 _minContributionPerWeek,
        uint256 _maxContributionPerWeek,
        uint256 _minBufferWeeks,
        uint256 _startWeek,
        Captable _captable,
        uint256 _shareClassId
    ) public {
        __init_firmBase(safe_, trustedForwarder_);
        minContributionPerWeek = _minContributionPerWeek;
        maxContributionPerWeek = _maxContributionPerWeek;
        minBufferWeeks = _minBufferWeeks;
        startWeek = _startWeek;
        currentWeek = 0;
        captable = _captable;
        shareClassId = _shareClassId;
    }

    function contribute() external payable {}

    function processWeek() external {}

    function getActiveUsers(
        uint256 week
    ) internal view returns (address[] memory) {
        // This function should return an array of addresses that have contributed in the given week
        // Implementation depends on how you want to track active users
    }

    // Add more helper functions as needed
}
