# Invariant Test Suite for MultisigContract and ContractManager

## Overview

The `Invariant` test suite ensure the integrity and correctness of interactions between the `MultisigContract` and `ContractManager`. It focuses on the actions that can be proposed and executed through the multisig mechanism and their compliance with the system's rules.

## Test Environment Setup

- **Initialization**: The test environment is set up by deploying the `MultisigContract` with four predefined owners (Alice, Bob, Eve, and John) and a requirement for three approvals to execute an action.
- **Contracts**: Interacts with `MultisigContract` and `ContractManager` to test the integration and functionality.

## Invariants

### Action Proposal Validation

- **Purpose**: Ensures that only specific actions related to the `ContractManager` (adding, updating, or removing contract descriptions) can be proposed through the `MultisigContract`.
- **Method**: `invariant_actionProposal()`
- **Validation**: Checks the execution data of a pending action to ensure it matches one of the allowed `ContractManager` function selectors. This ensures that only valid actions can be processed.

### Execution Data Completeness

- **Purpose**: Verifies that any action with more than one approval has non-empty execution data, ensuring that there are no empty or invalid actions pending execution.
- **Method**: `invariant_executionDataNotEmpty()`
- **Validation**: Confirms that for actions deemed valid by the multisig contract (indicated by having more than one approval), the execution data is not empty. This invariant helps prevent the execution of invalid or incomplete actions.

## Helper Functions

### Selector Extraction

- **Purpose**: Provides a utility to extract the function selector from execution data, facilitating the verification of proposed actions.
- **Method**: `getSelector(bytes memory _func)`
- **Returns**: The first four bytes of the execution data, representing the function selector. This is used to validate the type of actions being proposed in the multisig contract.
