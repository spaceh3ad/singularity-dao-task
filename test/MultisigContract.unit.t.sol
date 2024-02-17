// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ContractManager} from "../src/ContractManager.sol";
import {MultisigContract} from "../src/MultisigContract.sol";

contract TestContracts is Test {
    MultisigContract public multisig;

    address alice = address(0xa71ce);
    address bob = address(0xb0b);
    address eve = address(0xe3e);
    address john = address(0x01035);

    address other = address(0x07e1);

    event ActionExecuted(uint256 indexed actionId);
    event ActionProposed(uint256 indexed actionId, address indexed proposer);
    event ActionApproved(uint256 indexed actionId, address indexed approver);

    error ExecutionFailed(uint256 actionId);
    error InvalidSelector();
    error ActionExists();
    error AleadyApproved();
    error ActionDoesNotExist();

    function setUp() public {
        address[] memory owners = new address[](4);
        owners[0] = alice;
        owners[1] = bob;
        owners[2] = eve;
        owners[3] = john;

        multisig = new MultisigContract(owners, 3);
    }

    function test_init() public {
        assertEq(multisig.isOwner(alice), true);
        assertEq(multisig.isOwner(bob), true);
        assertEq(multisig.isOwner(eve), true);
        assertEq(multisig.isOwner(john), true);
    }

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

    function test_approveAction() public {
        uint256 actionId = test_proposeAction();

        vm.expectEmit(true, true, false, true);
        emit ActionApproved(actionId, bob);
        vm.prank(bob);
        multisig.approveAction(actionId);

        (, uint8 _approvals) = multisig.pendingActions(actionId);

        assertEq(_approvals, 2);
    }

    function test_executeAction() public {
        uint256 actionId = test_proposeAction();

        vm.prank(bob);
        multisig.approveAction(actionId);

        vm.prank(eve);
        multisig.approveAction(actionId);

        (bytes memory _executionData, ) = multisig.pendingActions(actionId);

        assertEq(_executionData, "");
    }

    /*//////////////////////////////////////////////////////////////
                                REVERTS
    //////////////////////////////////////////////////////////////*/

    function test_proposeInvalidAction() public {
        bytes memory data = abi.encodeWithSignature("NonExistantFunction()");
        vm.expectRevert(InvalidSelector.selector);
        vm.prank(alice);
        multisig.proposeAction(data);
    }

    function test_proposeDuplicateAction() public {
        test_proposeAction();

        bytes memory data = abi.encodeWithSelector(
            ContractManager.addContractDescription.selector,
            other,
            "some description"
        );

        vm.expectRevert(ActionExists.selector);
        vm.prank(bob);
        multisig.proposeAction(data);
    }

    function test_approveActionTwice() public {
        uint256 actionId = test_proposeAction();

        vm.expectRevert(AleadyApproved.selector);
        vm.prank(alice);
        multisig.approveAction(actionId);
    }

    function test_approveInvalidAction() public {
        vm.expectRevert(ActionDoesNotExist.selector);
        vm.prank(alice);
        multisig.approveAction(55); // random actionId
    }
}
