// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ContractManager} from "../src/ContractManager.sol";
import {MultisigContract} from "../src/MultisigContract.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract TestContracts is Test {
    ContractManager public contractManager;
    MultisigContract public multisig;

    address alice = address(0xa71ce);
    address bob = address(0xb0b);
    address eve = address(0xe3e);
    address john = address(0x01035);

    address other = address(0x07e1);

    // @dev some contract address for description
    address someContractAddress = address(0x8541);

    function setUp() public {
        address[] memory owners = new address[](4);
        owners[0] = alice;
        owners[1] = bob;
        owners[2] = eve;
        owners[3] = john;

        multisig = new MultisigContract(owners, 3);
        contractManager = multisig.contractManager();
    }

    ///@dev should allow privileged user to propose action for adding contract description
    function test_proposeAction_addContractDescription()
        public
        returns (uint256)
    {
        bytes memory data = multisig.encodeAdd(
            address(someContractAddress),
            "some description"
        );
        vm.prank(alice);
        multisig.proposeAction(data);
        (bytes memory _executionData, uint8 approvals) = multisig
            .pendingActions(uint256(keccak256(data)));

        assertEq(approvals, 1);
        assertEq(_executionData, data);
        return uint256(keccak256(data));
    }

    ///@dev should allow privileged user to propose action for updating contract description
    function test_proposeAction_updateContractDescription() public {
        bytes memory data = multisig.encodeUpdate(
            address(someContractAddress),
            "some new description"
        );
        vm.prank(bob);
        multisig.proposeAction(data);
        (bytes memory _executionData, uint8 approvals) = multisig
            .pendingActions(uint256(keccak256(data)));

        assertEq(approvals, 1);
        assertEq(_executionData, data);
    }

    ///@dev should allow privileged user to propose action for removing contract description
    function test_proposeAction_removeContractDescription() public {
        bytes memory data = multisig.encodeRemove(address(someContractAddress));
        vm.prank(eve);
        multisig.proposeAction(data);
        (bytes memory _executionData, uint8 approvals) = multisig
            .pendingActions(uint256(keccak256(data)));

        assertEq(approvals, 1);
        assertEq(_executionData, data);
    }

    ///@dev should add contract description after threshold approval reached
    function test_executeAction_addContractDescription() public {
        uint256 _actionId = test_proposeAction_addContractDescription();
        vm.prank(bob);
        multisig.approveAction(_actionId);

        vm.prank(eve);
        multisig.approveAction(_actionId);

        assertEq(
            contractManager.contractToDescriptionMaping(someContractAddress),
            "some description"
        );
    }

    ///@dev should update contract description after threshold approval reached
    function test_executeAction_updateContractDescription() public {
        /// @dev add contract description
        test_executeAction_addContractDescription();

        bytes memory data = multisig.encodeUpdate(
            address(someContractAddress),
            "some new description"
        );

        vm.prank(bob);
        multisig.proposeAction(data);
        vm.prank(alice);
        multisig.approveAction(uint256(keccak256(data)));
        vm.prank(eve);
        multisig.approveAction(uint256(keccak256(data)));

        assertEq(
            contractManager.contractToDescriptionMaping(someContractAddress),
            "some new description"
        );
    }

    ///@dev should remove contract description after threshold approval reached
    function test_executeAction_removeContractDescription() public {
        /// @dev add contract description
        test_executeAction_addContractDescription();

        bytes memory data = multisig.encodeRemove(address(someContractAddress));

        vm.prank(bob);
        multisig.proposeAction(data);
        vm.prank(alice);
        multisig.approveAction(uint256(keccak256(data)));
        vm.prank(eve);
        multisig.approveAction(uint256(keccak256(data)));

        assertEq(
            contractManager.contractToDescriptionMaping(someContractAddress),
            ""
        );
    }

    ///@dev should revert when actionId does not exist
    function test_shouldNotAllowApprovingNonExistantAction() public {
        vm.expectRevert();
        vm.prank(alice);
        multisig.approveAction(uint256(keccak256("nonExistantAction")));
    }

    ///@dev should revert when owner tries to approve action that he proposed (avoid double counting)
    function test_shouldNotAllowApprovingOfProposedAction() public {
        uint256 actionId = test_proposeAction_addContractDescription();
        vm.expectRevert();
        vm.prank(alice);
        multisig.approveAction(actionId);
    }

    ///@dev should revert when owner tries to propose empty action
    function test_shouldNotAllowProposingEmptyAction() public {
        vm.expectRevert();
        vm.prank(alice);
        bytes memory data = new bytes(0);
        multisig.proposeAction(data);
    }

    ///@dev should revert when owner tries to propose action that already exists
    function test_shouldNotAllowProposingDuplicateAction() public {
        test_proposeAction_addContractDescription();
        bytes memory data = multisig.encodeAdd(
            address(someContractAddress),
            "some description"
        );
        vm.expectRevert();
        vm.prank(alice);
        multisig.proposeAction(data);
    }

    ///@dev should revert when owner tries to propose action that already exists
    function test_shouldRevertWhenExecutingActionFails() public {
        bytes memory data = abi.encodeWithSignature(
            "deposit(uint256,address)",
            1000,
            address(someContractAddress)
        );
        vm.prank(alice);
        multisig.proposeAction(data);
        vm.prank(bob);
        multisig.approveAction(uint256(keccak256(data)));
        vm.expectRevert();
        vm.prank(eve);
        multisig.approveAction(uint256(keccak256(data)));
    }

    // ///@dev should allow privileged user to remove contract with description
    // function test_removeContractDescription() public {
    //     test_addContractDescription();
    //     vm.prank(eve);
    //     t.removeContractDescription(someContractAddress);
    //     assertEq(t.contractToDescriptionMaping(someContractAddress), "");
    // }

    // /*//////////////////////////////////////////////////////////////
    //                             REVERTS
    // //////////////////////////////////////////////////////////////*/

    // ///@dev should revert if not privileged user tries to add contract with description
    // function test_revert_interactContractDescriptionNonPrivileged() public {
    //     address contractAddress = address(0x8541);
    //     vm.prank(other);
    //     vm.expectRevert();
    //     t.addContractDescription(contractAddress, "some contract");
    //     vm.expectRevert();
    //     t.updateContractDescription(contractAddress, "some contract");
    //     vm.expectRevert();
    //     t.removeContractDescription(contractAddress);
    // }

    // ///@dev should allow privileged user to remove contract with description
    // function test_revert_updateNonExistantContract() public {
    //     test_addContractDescription();
    //     vm.prank(bob);
    //     vm.expectRevert(
    //         abi.encodeWithSelector(ContractManager.ContractNotExist.selector)
    //     );
    //     t.updateContractDescription(address(0x99999999), "");
    // }

    // ///@dev should revert if description is set to empty
    // function test_revert_updateContractDescriptionWithEmptyDescription()
    //     public
    // {
    //     test_addContractDescription();
    //     vm.prank(bob);
    //     vm.expectRevert(
    //         abi.encodeWithSelector(ContractManager.CannotSetToEmpty.selector)
    //     );
    //     t.updateContractDescription(someContractAddress, "");
    // }

    // ///@dev should allow privileged user to remove contract with description
    // function test_revert_updateContractDescriptionWithStaleDescription()
    //     public
    // {
    //     test_addContractDescription();
    //     vm.prank(bob);
    //     vm.expectRevert(
    //         abi.encodeWithSelector(ContractManager.StaleDescription.selector)
    //     );
    //     t.updateContractDescription(someContractAddress, "some contract");
    // }
}
