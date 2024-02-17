# ContractManager

**Author:**
Jan Kwiatkowski @spaceh3ad

This contract allows for the addition, updating, and removal of contract descriptions, with access control.

## State Variables

### contractToDescriptionMaping

_Maps contract addresses to their descriptions._

```solidity
mapping(address => string) public contractToDescriptionMaping;
```

### owner

The owner of the contract which is allowed to interact with contract.

```solidity
address public immutable owner;
```

## Functions

### onlyOwner

_Modifier that only allows the owner to call the function_

```solidity
modifier onlyOwner();
```

### contractMustExist

_Modifier that checks if a contract exists in the mapping_

```solidity
modifier contractMustExist(address _contract);
```

### constructor

Initializes a new instance of the ContractManager with the specified owner.

```solidity
constructor(address _owner);
```

**Parameters**

| Name     | Type      | Description                                                           |
| -------- | --------- | --------------------------------------------------------------------- |
| `_owner` | `address` | The address that will be granted ownership of this contract instance. |

### updateContractDescription

Updates the description of a contract

_Only callable via MultiSigAdmin_

```solidity
function updateContractDescription(address _contract, string memory _description)
    external
    onlyOwner
    contractMustExist(_contract);
```

**Parameters**

| Name           | Type      | Description                           |
| -------------- | --------- | ------------------------------------- |
| `_contract`    | `address` | The address of the contract to update |
| `_description` | `string`  | The new description of the contract   |

### addContractDescription

Adds a new contract description

_Only callable via MultiSigAdmin_

```solidity
function addContractDescription(address _contract, string memory _description) external onlyOwner;
```

**Parameters**

| Name           | Type      | Description                     |
| -------------- | --------- | ------------------------------- |
| `_contract`    | `address` | The address of the contract     |
| `_description` | `string`  | The description of the contract |

### removeContractDescription

Removes a contract description

_Only callable via MultiSigAdmin_

```solidity
function removeContractDescription(address _contract) external onlyOwner contractMustExist(_contract);
```

**Parameters**

| Name        | Type      | Description                           |
| ----------- | --------- | ------------------------------------- |
| `_contract` | `address` | The address of the contract to remove |

### \_insertContractDescription

_Inserts or updates a contract's description in the mapping_

```solidity
function _insertContractDescription(address _contract, string memory _description) internal;
```

**Parameters**

| Name           | Type      | Description                               |
| -------------- | --------- | ----------------------------------------- |
| `_contract`    | `address` | The address of the contract               |
| `_description` | `string`  | The description to assign to the contract |

## Events

### ContractDescriptionAdded

Emitted when a new contract description is added.

```solidity
event ContractDescriptionAdded(address indexed contractAddress, string description);
```

### ContractDescriptionUpdated

Emitted when a contract description is updated.

```solidity
event ContractDescriptionUpdated(address indexed contractAddress, string description);
```

### ContractDescriptionRemoved

Emitted when a contract description is removed.

```solidity
event ContractDescriptionRemoved(address indexed contractAddress);
```

## Errors

### ContractNotExist

_Error used when an operation references a contract address that does not exist in the mapping._

```solidity
error ContractNotExist();
```

### CannotBeZeroAddress

_Error used when an attempt is made to set the owner to the zero address._

```solidity
error CannotBeZeroAddress();
```

### StaleDescription

_Error used when an attempt is made to update a contract's description to the same description it already has._

```solidity
error StaleDescription();
```

### CannotSetToEmpty

_Error used when an attempt is made to update a contract's description to an empty string._

```solidity
error CannotSetToEmpty();
```

### NotOwner

_Error used when an operation is attempted by an unauthorized user._

```solidity
error NotOwner();
```
