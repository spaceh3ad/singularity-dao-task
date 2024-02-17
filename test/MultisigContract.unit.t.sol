// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ContractManager} from "../src/ContractManager.sol";
import {MultisigContract} from "../src/MultisigContract.sol";

/// @title Multisig Unit Test
/// @author Jan Kwiatkowski
/// @dev Unit tests for the MultisigContract's basic functionalities including proposal, approval, and execution of actions.
contract MultisigUnitTest is Test {
    MultisigContract public multisig;

    address alice = address(0xa71ce);
    address bob = address(0xb0b);
    address eve = address(0xe3e);
    address john = address(0x01035);

    address other = address(0x07e1);

    // Events to monitor contract interactions
    event ActionExecuted(uint256 indexed actionId);
    event ActionProposed(uint256 indexed actionId, address indexed proposer);
    event ActionApproved(uint256 indexed actionId, address indexed approver);

    /// @notice Initializes the test suite by setting up a MultisigContract instance with predefined owners.
    function setUp() public {
        address[] memory owners = new address[](4);
        owners[0] = alice;
        owners[1] = bob;
        owners[2] = eve;
        owners[3] = john;

        multisig = new MultisigContract(owners, 3);
    }

    /// @notice Verifies that the MultisigContract owners were assigned correctly.
    function test_init() public {
        assertEq(multisig.isOwner(alice), true);
        assertEq(multisig.isOwner(bob), true);
        assertEq(multisig.isOwner(eve), true);
        assertEq(multisig.isOwner(john), true);
    }

    /// @notice Tests the ability to propose an action within the MultisigContract.
    /// @dev Proposes an action and verifies it's correctly recorded.
    /// @return actionId The unique ID of the proposed action for further testing.
    function test_proposeAction() public returns (uint256) {
        bytes memory data = abi.encodeWithSelector(
            ContractManager.addContractDescription.selector,
            other,
            "some description"
        );

        uint256 actionId = uint256(keccak256(data));

        vm.expectEmit(true, true, false, true);
        emit ActionProposed(actionId, alice);

        vm.prank(alice);
        multisig.proposeAction(data);

        (bytes memory _executionData, ) = multisig.pendingActions(actionId);

        assertEq(_executionData, data);
        return actionId;
    }

    /// @notice Tests the approval process for an action by another owner.
    /// @dev Approves a previously proposed action and verifies the updated approval count.
    function test_approveAction() public {
        uint256 actionId = test_proposeAction();

        vm.expectEmit(true, true, false, true);
        emit ActionApproved(actionId, bob);
        vm.prank(bob);
        multisig.approveAction(actionId);

        (, uint8 _approvals) = multisig.pendingActions(actionId);

        assertEq(_approvals, 2);
    }

    /// @notice Tests the execution of an action after reaching the required approval threshold.
    /// @dev Verifies that an action is executed and its execution data is cleared.
    function test_executeAction() public {
        uint256 actionId = test_proposeAction();

        vm.prank(bob);
        multisig.approveAction(actionId);

        vm.expectEmit(true, true, false, true);
        emit ActionExecuted(actionId);
        vm.prank(eve);
        multisig.approveAction(actionId);

        (bytes memory _executionData, ) = multisig.pendingActions(actionId);

        assertEq(_executionData, "");
    }

    /*//////////////////////////////////////////////////////////////
                                REVERTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Tests that proposing an action with an invalid function selector reverts.
    function test_proposeInvalidAction() public {
        bytes memory data = abi.encodeWithSignature("NonExistantFunction()");
        vm.expectRevert(MultisigContract.InvalidSelector.selector);
        vm.prank(alice);
        multisig.proposeAction(data);
    }

    /// @notice Tests that proposing a duplicate action reverts.
    function test_proposeDuplicateAction() public {
        test_proposeAction();

        bytes memory data = abi.encodeWithSelector(
            ContractManager.addContractDescription.selector,
            other,
            "some description"
        );

        vm.expectRevert(MultisigContract.ActionExists.selector);
        vm.prank(bob);
        multisig.proposeAction(data);
    }

    /// @notice Tests that an owner cannot approve an action more than once.
    function test_approveActionTwice() public {
        uint256 actionId = test_proposeAction();

        vm.expectRevert(MultisigContract.AleadyApproved.selector);
        vm.prank(alice);
        multisig.approveAction(actionId);
    }

    /// @notice Tests that approving a non-existent action reverts.
    function test_approveNonExistantAction() public {
        vm.expectRevert(MultisigContract.ActionDoesNotExist.selector);
        vm.prank(alice);
        multisig.approveAction(55); // some random actionId
    }
}
