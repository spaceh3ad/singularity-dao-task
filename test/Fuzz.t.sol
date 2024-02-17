// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {MultisigContract} from "../src/MultisigContract.sol";
import "forge-std/Test.sol";
import "../src/ContractManager.sol";

/// @author Jan Kwiatkowski @spaceh3ad
/// @title Fuzz Testing for ContractManager
/// @dev This contract performs fuzz testing on the ContractManager's functions to ensure they handle a wide range of inputs correctly.
contract ContractManagerFuzz is Test {
    ContractManager public manager;
    address public owner;
    address public nonOwner;

    /// @notice Sets up the testing environment by deploying the ContractManager and initializing owner and nonOwner addresses.
    function setUp() public {
        owner = address(1);
        nonOwner = address(2);
        manager = new ContractManager(owner);
    }

    /// @notice Fuzz test for adding a new contract description.
    /// @dev This test checks that a contract description can be added successfully by the owner.
    /// @param _contract The address of the contract (fuzzed) to add a description for.
    /// @param _description The description to add for the contract.
    function testFuzz_addContractDescription(
        uint160 _contract,
        string calldata _description
    ) public {
        bound(_contract, uint160(1), type(uint160).max);
        address contractAddress = address(_contract);

        vm.assume(bytes(_description).length > 0); // Assume description is not empty

        vm.prank(owner); // Simulate actions from the owner's address
        manager.addContractDescription(contractAddress, _description);

        // Verify the contract description was added
        assertEq(
            manager.contractToDescriptionMaping(contractAddress),
            _description,
            "Contract description should match the added description."
        );
    }

    /// @notice Fuzz test for updating an existing contract description.
    /// @dev This test verifies that an existing contract description can be updated successfully by the owner.
    /// @param _contract The address of the contract (fuzzed) to update the description for.
    /// @param _description The initial description to add for the contract.
    /// @param _newDescription The new description to update the contract with.
    function testFuzz_updateContractDescription(
        uint160 _contract,
        string calldata _description,
        string calldata _newDescription
    ) public {
        bound(_contract, uint160(1), type(uint160).max);
        address contractAddress = address(_contract);

        vm.assume(
            bytes(_description).length > 0 && bytes(_newDescription).length > 0
        );

        // New description must be different from the original.
        vm.assume(
            keccak256(bytes(_description)) != keccak256(bytes(_newDescription))
        );

        vm.startPrank(owner);
        manager.addContractDescription(contractAddress, _description); // First, add a description
        manager.updateContractDescription(contractAddress, _newDescription); // Then, update it

        // Verify the contract description was updated
        assertEq(
            manager.contractToDescriptionMaping(contractAddress),
            _newDescription,
            "Contract description should match the updated description."
        );
        vm.stopPrank();
    }

    /// @notice Fuzz test for removing a contract description.
    /// @dev This test ensures that a contract description can be removed successfully by the owner.
    /// @param _contract The address of the contract (fuzzed) to remove the description from.
    /// @param _description The description to add and then remove for the contract.
    function testFuzz_removeContractDescription(
        uint160 _contract,
        string calldata _description
    ) public {
        bound(_contract, uint160(1), type(uint160).max);
        address contractAddress = address(_contract);

        vm.assume(bytes(_description).length > 0);

        vm.startPrank(owner);
        manager.addContractDescription(contractAddress, _description);
        manager.removeContractDescription(contractAddress);

        // Verify the contract description was removed
        assertEq(
            bytes(manager.contractToDescriptionMaping(contractAddress)).length,
            0,
            "Contract description should be removed, resulting in an empty string."
        );
        vm.stopPrank();
    }
}
