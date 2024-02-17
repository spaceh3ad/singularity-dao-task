# MultisigContract

## Contract Overview

- **Author:** Jan Kwiatkowski @spaceh3ad
- **Title:** MultisigContract
- **Notice:** Implements a multisignature contract mechanism where actions require multiple approvals from designated owners before they can be executed. This contract is designed to interact with a ContractManager for managing contract descriptions.
- **Dev:** The contract utilizes mappings to track ownership, action approvals, and the state of pending actions. Each action is uniquely identified by a hash of its execution data.

## Errors

- `NotOwner`: Thrown when an unauthorized user attempts to perform an operation reserved for owners.
- `NotEnoughApprovals`: Thrown when an action does not have the required number of approvals to be executed.
- `ExecutionFailed`: Thrown when an attempt to execute an action fails at the ContractManager level. Includes `actionId`.
- `ActionDoesNotExist`: Thrown when an action being approved does not exist in the contract.
- `ActionExists`: Thrown when a proposed action already exists.
- `AleadyApproved`: Thrown when an owner tries to approve an action they have already approved.
- `InvalidSelector`: Thrown when an action is proposed with an invalid selector.

## Events

- `ActionExecuted`: Emitted when an action is successfully executed. Parameters include `actionId`.
- `ActionProposed`: Emitted when a new action is proposed by an owner. Parameters include `actionId` and `proposer`.
- `ActionApproved`: Emitted when an owner approves an action. Parameters include `actionId` and `approver`.

## Storage

- `isOwner`: Tracks whether an address is an owner of the contract.
- `approvalThreshold`: Assumes the contract will have no more than 255 owners.
- `contractManager`: The ContractManager contract used to execute actions.
- `actionApprovalMapping`: Maps an action ID to its approval status by address.
- `pendingActions`: Maps an action ID to its corresponding Action struct.

## Constructor & Modifiers

- **Constructor:** Initializes the contract with given owners and approval threshold. Parameters include `_owners` array and `_approvalThreshold`.
- `onlyOwner`: Restricts function access to contract owners.

## Functions

### proposeAction

- **Notice:** Proposes a new action for approval by the contract owners.
- **Dev:** Only callable by an owner. Reverts if the action already exists or the selector is invalid.
- **Parameters:** `_executionData` - The data to be executed once the action is approved.

### approveAction

- **Notice:** Approves an action proposed by an owner.
- **Dev:** Only callable by an owner. Reverts if the action doesn't exist or has already been approved by the caller.
- **Parameters:** `_actionId` - The unique identifier of the action to approve.

### execute

- **Dev:** Internal function called once an action has the required number of approvals. Not directly callable.
- **Parameters:** `_actionId` - The unique identifier of the action to execute, `_data` - The execution data of the action.

## Helper Functions

### getSelector

- **Dev:** Internal function to extract the selector from a function call.
- **Parameters:** `_func` - The function call data.
