# MultisigContract Unit Tests

This documentation details the tests for the `MultisigContract` smart contract. These tests are aimed at verifying the core functionalities of the multisignature mechanism, including proposing, approving, and executing actions, as well as handling permissions and error scenarios.

## Test Setup

The setup involves initializing a `MultisigContract` with four owners (Alice, Bob, Eve, and John) and setting an approval threshold.

## Tests

### Initialization

- **`test_init`**: Confirms that all specified addresses are correctly set as owners of the multisig contract.

### Propose Action

- **`test_proposeAction`**: Checks that an owner can propose an action. It uses the `ContractManager.addContractDescription` selector as the action data, emits an `ActionProposed` event, and verifies that the action is correctly recorded.

### Approve Action

- **`test_approveAction`**: Verifies that another owner can approve a proposed action, increasing the approval count. It emits an `ActionApproved` event and checks the number of approvals associated with the action.

### Execute Action

- **`test_executeAction`**: Demonstrates that once the required number of approvals is reached, it emits `ActionExecuted` event and the action is executed and then removed from the list of pending actions, effectively clearing the execution data associated with that action ID.

## Revert Scenarios

### Invalid Action Proposal

- **`test_proposeInvalidAction`**: Ensures that proposing an action with an invalid selector results in a revert, expecting an `InvalidSelector` error.

### Duplicate Action Proposal

- **`test_proposeDuplicateAction`**: Tests that proposing an action that already exists reverts with an `ActionExists` error.

### Double Approval

- **`test_approveActionTwice`**: Confirms that an owner cannot approve an action more than once, expecting an `AleadyApproved` error.

### Non-existant Action Approval

- **`test_approveNonExistantAction`**: Checks that attempting to approve a non-existent action ID results in a revert, expecting an `ActionDoesNotExist` error.
