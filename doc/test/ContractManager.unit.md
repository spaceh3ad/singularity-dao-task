# ContractManager Unit Tests

This documentation covers the tests for the `ContractManager` smart contract. The tests are designed to verify the functionality of contract operations, including adding, updating, and removing contract descriptions, as well as handling permissions.

## Test Setup

- **ContractManager Setup:** Initializes the `ContractManager` contract with a predefined owner address.
- **Test Addresses:** Utilizes fixed addresses for the owner and other participants (e.g., Eve) to simulate contract interactions.

## Tests

### Initialization

- **`test_init`**: Verifies that the `ContractManager` is initialized with the correct owner.

### Adding Contract Description

- **`test_addContractDescription`**: Checks that a privileged user (the owner) can add a new contract description. This test emits a `ContractDescriptionAdded` event and verifies the addition by checking the contract's description mapping.

### Updating Contract Description

- **`test_updateContractDescription`**: Ensures that a privileged user can update an existing contract description. It first adds a description, then updates it, emits a `ContractDescriptionUpdated` event, and verifies the update in the contract's mapping.

### Removing Contract Description

- **`test_removeContractDescription`**: Confirms that a privileged user can remove a contract description. After adding a description, the test attempts to remove it, emits a `ContractDescriptionRemoved` event, and checks that the description is cleared.

## Revert Scenarios

### Non-Privileged Actions

- **`test_removeContractDescriptionNonPrivileged`**: Verifies that a non-privileged user (e.g., Eve) cannot remove a contract description, expecting a revert with `NotOwner`.
- **`test_updateContractDescriptionNonPrivileged`**: Tests that a non-privileged user cannot update a contract description, expecting a revert with `NotOwner`.
- **`test_addContractDescriptionNonPrivileged`**: Ensures that a non-privileged user cannot add a contract description, expecting a revert with `NotOwner`.

### Update Edge Cases

- **`test_revertUpdate_contractDoesNotExist`**: Checks that attempting to update a description for a non-existent contract address reverts with `CannotSetToEmpty`.
- **`test_revertUpdate_contractDescriptionIsEmpty`**: Verifies that updating a contract description to an empty string is not allowed, expecting a revert with `ContractNotExist`.
- **`test_revertUpdate_contractDescriptionIsStale`**: Ensures that trying to update a contract with the same description it already has reverts with `StaleDescription`.
