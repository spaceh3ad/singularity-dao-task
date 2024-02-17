# ContractManager

## Contract Overview

- **Author:** Jan Kwiatkowski @spaceh3ad
- **Title:** Contract Manager for Managing Contract Descriptions
- **Notice:** This contract allows for the addition, updating, and removal of contract descriptions, with access control. It is designed to be interacted with by a multisignature contract or an owner with specific privileges for managing metadata of various contracts.

## Errors

- `ContractNotExist`: Used when an operation references a contract address that does not exist in the mapping.
- `StaleDescription`: Used when an attempt is made to update a contract's description to the same description it already has.
- `CannotSetToEmpty`: Used when an attempt is made to update a contract's description to an empty string.
- `NotOwner`: Used when an operation is attempted by an unauthorized user.

## Events

- `ContractDescriptionAdded`: Emitted when a new contract description is added. Includes the `contractAddress` and `description`.
- `ContractDescriptionUpdated`: Emitted when a contract description is updated. Includes the `contractAddress` and `description`.
- `ContractDescriptionRemoved`: Emitted when a contract description is removed. Includes the `contractAddress`.

## Storage

- `contractToDescriptionMapping`: Maps contract addresses to their descriptions. This mapping allows the contract to keep track of metadata associated with different contract addresses.
- `owner`: The owner of the contract which is allowed to interact with contract functions for managing descriptions.

## Constructor & Modifiers

### Constructor

- Initializes a new instance of the ContractManager with the specified owner. The `owner` parameter is the address that will be granted ownership of this contract instance.

### Modifiers

- `onlyOwner`: Ensures that a function is only callable by the owner of the contract.
- `contractMustExist`: Checks if a contract address exists in the `contractToDescriptionMapping` before allowing certain operations to proceed.

## Functions

### Public Functions

#### updateContractDescription

- Updates the description of a contract. This function is only callable by the contract owner and requires that the contract address already exists in the `contractToDescriptionMapping`.
- Parameters:
  - `_contract`: The address of the contract to update.
  - `_description`: The new description of the contract.

#### addContractDescription

- Adds a new contract description. This function is only callable by the contract owner.
- Parameters:
  - `_contract`: The address of the contract.
  - `_description`: The description of the contract.

#### removeContractDescription

- Removes a contract description. This function is only callable by the contract owner and requires that the contract address exists in the `contractToDescriptionMapping`.
- Parameters:
  - `_contract`: The address of the contract to remove.

## Internal Functions

### \_insertContractDescription

- Inserts or updates a contract's description in the `contractToDescriptionMapping`. This internal function is utilized by both the `addContractDescription` and `updateContractDescription` public functions.
- Parameters:
  - `_contract`: The address of the contract.
  - `_description`: The description to assign to the contract.
