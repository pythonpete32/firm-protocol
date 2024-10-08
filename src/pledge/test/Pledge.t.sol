pragma solidity 0.8.17;

import {FirmTest} from "src/bases/test/lib/FirmTest.sol";
import {SafeStub} from "src/bases/test/mocks/SafeStub.sol";
import {Pledge} from "../Pledge.sol";
import {FirmBase} from "src/bases/FirmBase.sol";
import {SafeAware} from "src/bases/SafeAware.sol";
import {ISafe} from "src/bases/interfaces/ISafe.sol";

contract BasePledgeTest is FirmTest {
    Pledge pledge;
    ISafe safe;

    function setUp() public virtual {
        // Create a new SafeStub with a non-zero address
        safe = ISafe(payable(address(new SafeStub())));

        // Ensure the safe address is not zero
        require(address(safe) != address(0), "Safe address is zero");

        pledge = Pledge(
            createProxy(
                new Pledge(),
                abi.encodeCall(Pledge.initialize, (safe, address(0)))
            )
        );
    }
}

contract PledgeInitTest is BasePledgeTest {
    function testInitialState() public {
        assertEq(address(pledge.safe()), address(safe));
        assertEq(pledge.moduleId(), "org.firm.pledge");
        assertEq(pledge.moduleVersion(), 1);
    }

    function testCannotReinit() public {
        vm.expectRevert(
            abi.encodeWithSelector(SafeAware.AlreadyInitialized.selector)
        );
        pledge.initialize(ISafe(payable(address(1))), address(1));
    }
}

// Add more test contracts as needed for different functionalities
