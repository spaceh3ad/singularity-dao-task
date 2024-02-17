// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ContractManager} from "../src/ContractManager.sol";
import {MultisigContract} from "../src/MultisigContract.sol";

/// @author Jan Kwiatkowski @spaceh3ad
/// @title Test Suite for ContractManager
/// @dev This contract tests the ContractManager's functionality including adding, updating, and removing contract descriptions.
contract ContractManagerTest is Test {
    ContractManager public contractManager;

    address owner = address(0x03e80);
    address eve = address(0xe3e);

    /// Some contract address for description
    address someContractAddress = address(0x8541);

    event ContractDescriptionAdded(
        address indexed contractAddress,
        string description
    );
    event ContractDescriptionUpdated(
        address indexed contractAddress,
        string description
    );
    event ContractDescriptionRemoved(address indexed contractAddress);

    /// @notice Sets up the ContractManager contract for testing
    function setUp() public {
        contractManager = new ContractManager(owner);
    }

    /// @notice Verifies the initialization of the ContractManager with the correct owner
    function test_init() public {
        assertEq(contractManager.owner(), owner);
    }

    /// @notice Tests adding a contract description by a privileged user
    /// @dev Simulates adding a contract description and checks if the operation was successful
    function test_addContractDescription() public {
        string memory desc = "some description";

        vm.expectEmit(true, false, false, true);
        emit ContractDescriptionAdded(someContractAddress, desc);
        vm.prank(owner);
        contractManager.addContractDescription(someContractAddress, desc);

        assertEq(
            contractManager.contractToDescriptionMaping(someContractAddress),
            desc
        );
    }

    /// @notice Tests updating a contract description by a privileged user
    /// @dev Simulates updating a contract description and verifies the update
    function test_updateContractDescription() public {
        test_addContractDescription();
        string memory desc = "some new description";

        vm.expectEmit(true, false, false, true);
        emit ContractDescriptionUpdated(someContractAddress, desc);
        vm.prank(owner);
        contractManager.updateContractDescription(someContractAddress, desc);

        assertEq(
            contractManager.contractToDescriptionMaping(someContractAddress),
            desc
        );
    }

    /// @notice Tests removing a contract description by a privileged user
    /// @dev Simulates removing a contract description and checks for deletion
    function test_removeContractDescription() public {
        test_addContractDescription();

        vm.expectEmit(true, false, false, true);
        emit ContractDescriptionRemoved(someContractAddress);
        vm.prank(owner);
        contractManager.removeContractDescription(someContractAddress);

        assertEq(
            contractManager.contractToDescriptionMaping(someContractAddress),
            ""
        );
    }

    /*//////////////////////////////////////////////////////////////
                                REVERT SCENARIOS
    //////////////////////////////////////////////////////////////*/

    /// @notice Verifies that non-privileged users cannot remove a contract description
    function test_removeContractDescriptionNonPrivileged() public {
        test_addContractDescription();

        vm.expectRevert(ContractManager.NotOwner.selector);
        vm.prank(eve);
        contractManager.removeContractDescription(someContractAddress);
    }

    /// @notice Checks that non-privileged users cannot update a contract description
    function test_updateContractDescriptionNonPrivileged() public {
        test_addContractDescription();

        vm.expectRevert(ContractManager.NotOwner.selector);
        vm.prank(eve);
        contractManager.updateContractDescription(
            someContractAddress,
            "something new"
        );
    }

    /// @notice Ensures that non-privileged users cannot add a contract description
    function test_addContractDescriptionNonPrivileged() public {
        string memory desc = "some description";

        vm.expectRevert(ContractManager.NotOwner.selector);
        vm.prank(eve);
        contractManager.addContractDescription(someContractAddress, desc);
    }

    /// @notice Tests the revert scenario when trying to update a contract description to an empty string
    function test_revertUpdate_contractDoesNotExist() public {
        test_addContractDescription();

        vm.prank(owner);
        vm.expectRevert(ContractManager.CannotSetToEmpty.selector);
        contractManager.updateContractDescription(someContractAddress, "");
    }

    /// @notice Verifies that updating a non-existent contract's description reverts as expected
    function test_revertUpdate_contractDescriptionIsEmpty() public {
        test_addContractDescription();

        vm.prank(owner);
        vm.expectRevert(ContractManager.ContractNotExist.selector);
        contractManager.updateContractDescription(
            address(0x123456789),
            "some description updated"
        );
    }

    /// @notice Checks revert behavior when attempting to update a contract description to its current value
    function test_revertUpdate_contractDescriptionIsStale() public {
        test_addContractDescription();

        vm.prank(owner);
        vm.expectRevert(ContractManager.StaleDescription.selector);
        contractManager.updateContractDescription(
            someContractAddress,
            "some description"
        );
    }
}
