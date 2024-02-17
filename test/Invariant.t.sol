// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {MultisigContract} from "../src/MultisigContract.sol";
import {ContractManager} from "../src/ContractManager.sol";

/// @title ContractManager and MultisigContract Invariants Test Suite
/// @author Jan Kwiatkowski (@spaceh3ad)
/// @dev It employs Foundry's Test framework to assess invariants within the MultisigContract, specifically targeting ContractManager's action functionalities.
contract Invariant is Test {
    MultisigContract public multisig;

    address alice = address(0xa71ce);
    address bob = address(0xb0b);
    address eve = address(0xe3e);
    address john = address(0x01035);

    /// Generic address used for testing purposes
    address other = address(0x07e1);

    /// Another generic address used for contract descriptions
    address someContractAddress = address(0x8541);

    /// Initializes the MultisigContract with four owners and a specified approval threshold.
    /// @dev Sets up a MultisigContract instance with a 3 out of 4 approval requirement for actions.
    function setUp() public {
        address[] memory owners = new address[](4);
        owners[0] = alice;
        owners[1] = bob;
        owners[2] = eve;
        owners[3] = john;

        multisig = new MultisigContract(owners, 3);
    }

    /// Validates that only specific actions related to contract management can be proposed.
    /// @dev Asserts that any proposed action's selector must match one of the ContractManager's allowed actions.
    function invariant_actionProposal() public view {
        (bytes memory executionData, ) = multisig.pendingActions(12345);
        if (executionData.length > 0) {
            bytes4 selector = getSelector(executionData);
            assert(
                selector == ContractManager.addContractDescription.selector ||
                    selector ==
                    ContractManager.updateContractDescription.selector ||
                    selector ==
                    ContractManager.removeContractDescription.selector
            );
        }
    }

    /// Ensures that valid actions contain non-empty execution data.
    /// @dev Checks for the presence of execution data in actions with more than one approval, ensuring actions are properly defined before execution.
    function invariant_executionDataNotEmpty() public view {
        (bytes memory executionData, uint8 approvals) = multisig.pendingActions(
            12345
        );
        if (approvals > 1) {
            assert(executionData.length > 0);
        }
    }

    /// Extracts the function selector from provided execution data.
    /// @param _func Execution data from which to extract the function selector.
    /// @return selector The first four bytes of the execution data, representing the function's selector.
    function getSelector(
        bytes memory _func
    ) internal pure returns (bytes4 selector) {
        return bytes4(_func);
    }
}
