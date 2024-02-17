# MultisigContract

**Author:**
Jan Kwiatkowski @spaceh3ad

Implements a multisignature contract mechanism where actions require multiple approvals from designated owners before they can be executed. This contract is designed to interact with a ContractManager for managing contract descriptions.

_The contract utilizes mappings to track ownership, action approvals, and the state of pending actions. Each action is uniquely identified by a hash of its execution data._

## State Variables

### isOwner

Tracks whether an address is an owner of the contract.

```solidity
mapping(address => bool) public isOwner;
```

### approvalThreshold

_Assumes the contract will have no more than 255 owners._

```solidity
uint8 public immutable approvalThreshold;
```

### contractManager

The ContractManager contract used to execute actions.

```solidity
ContractManager public immutable contractManager;
```

### actionApprovalMapping

Maps an action ID to its approval status by address.

```solidity
mapping(uint256 => mapping(address => bool)) public actionApprovalMapping;
```

### pendingActions

Maps an action ID to its corresponding Action struct.

```solidity
mapping(uint256 => Action) public pendingActions;
```

## Functions

### onlyOwner

Restricts function access to contract owners.

```solidity
modifier onlyOwner();
```

### constructor

Initializes the contract with given owners and approval threshold.

```solidity
constructor(address[] memory _owners, uint8 _approvalThreshold);
```

**Parameters**

| Name                 | Type        | Description                                                |
| -------------------- | ----------- | ---------------------------------------------------------- |
| `_owners`            | `address[]` | Array of owner addresses.                                  |
| `_approvalThreshold` | `uint8`     | Number of approvals required for an action to be executed. |

### proposeAction

Proposes a new action for approval by the contract owners.

_Only callable by an owner._

_Reverts if the action already exists or the selector is invalid._

```solidity
function proposeAction(bytes calldata _executionData) external onlyOwner;
```

**Parameters**

| Name             | Type    | Description                                          |
| ---------------- | ------- | ---------------------------------------------------- |
| `_executionData` | `bytes` | The data to be executed once the action is approved. |

### approveAction

Approves an action proposed by an owner.

_Only callable by an owner. Reverts if the action doesn't exist or has already been approved by the caller._

```solidity
function approveAction(uint256 _actionId) external onlyOwner;
```

**Parameters**

| Name        | Type      | Description                                     |
| ----------- | --------- | ----------------------------------------------- |
| `_actionId` | `uint256` | The unique identifier of the action to approve. |

### execute

Executes an action.

_Internal function called once an action has the required number of approvals._

```solidity
function execute(uint256 _actionId, bytes memory _data) internal;
```

**Parameters**

| Name        | Type      | Description                                     |
| ----------- | --------- | ----------------------------------------------- |
| `_actionId` | `uint256` | The unique identifier of the action to execute. |
| `_data`     | `bytes`   | The execution data of the action.               |

### getSelector

_Internal function to extract the selector from a function call._

```solidity
function getSelector(bytes calldata _func) internal pure returns (bytes4);
```

**Parameters**

| Name    | Type    | Description             |
| ------- | ------- | ----------------------- |
| `_func` | `bytes` | The function call data. |

## Events

### ActionExecuted

Emitted when an action is successfully executed.

```solidity
event ActionExecuted(uint256 indexed actionId);
```

**Parameters**

| Name       | Type      | Description                                            |
| ---------- | --------- | ------------------------------------------------------ |
| `actionId` | `uint256` | The unique identifier of the action that was executed. |

### ActionProposed

Emitted when a new action is proposed by an owner.

```solidity
event ActionProposed(uint256 indexed actionId, address indexed proposer);
```

**Parameters**

| Name       | Type      | Description                                   |
| ---------- | --------- | --------------------------------------------- |
| `actionId` | `uint256` | The unique identifier of the proposed action. |
| `proposer` | `address` | The address of the proposer.                  |

### ActionApproved

Emitted when an owner approves an action.

```solidity
event ActionApproved(uint256 indexed actionId, address indexed approver);
```

**Parameters**

| Name       | Type      | Description                                   |
| ---------- | --------- | --------------------------------------------- |
| `actionId` | `uint256` |                                               |
| `approver` | `address` | The address of the user that approved action. |

## Errors

### NotOwner

_Thrown when an unauthorized user attempts to perform an operation reserved for owners._

```solidity
error NotOwner();
```

### NotEnoughApprovals

_Thrown when an action does not have the required number of approvals to be executed._

```solidity
error NotEnoughApprovals();
```

### ExecutionFailed

_Thrown when an attempt to execute an action fails at the ContractManager level._

```solidity
error ExecutionFailed(uint256 actionId);
```

### ActionDoesNotExist

_Thrown when an action being approved does not exist in the contract._

```solidity
error ActionDoesNotExist();
```

### ActionExists

_Thrown when a proposed action already exists._

```solidity
error ActionExists();
```

### AleadyApproved

_Thrown when an owner tries to approve an action they have already approved._

```solidity
error AleadyApproved();
```

### InvalidSelector

_Thrown when an action is proposed with an invalid selector._

```solidity
error InvalidSelector();
```

### CannotBeZeroAddress

_Error used when an attempt is made to set the owner to the zero address._

```solidity
error CannotBeZeroAddress();
```

## Structs

### Action

```solidity
struct Action {
    bytes executionData;
    uint8 approvals;
}
```
