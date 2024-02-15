// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";

/// @author Jan Kwiatkowski @spaceh3ad
/// @title Contract Manager for Managing Contract Descriptions
/// @dev Extends OpenZeppelin's AccessControl for role-based permission management
/// @notice This contract allows for the addition, updating, and removal of contract descriptions, with access control.
contract ContractManager is AccessControl {
    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @dev Error used when an operation references a contract address that does not exist in the mapping.
    error ContractNotExist();

    /// @dev Error used when an attempt is made to update a contract's description to the same description it already has.
    error StaleDescription();

    /// @dev Error used when an attempt is made to update a contract's description to an empty string.
    error CannotSetToEmpty();

    /*//////////////////////////////////////////////////////////////
                                STORAGE
    //////////////////////////////////////////////////////////////*/

    /// @dev Maps contract addresses to their descriptions
    mapping(address => string) public contractToDescriptionMaping;

    /// @notice Role hash for the remove operation
    bytes32 public constant REMOVE_ROLE = keccak256("REMOVE_ROLE");

    /// @notice Role hash for the add operation
    bytes32 public constant ADD_ROLE = keccak256("ADD_ROLE");

    /// @notice Role hash for the update operation
    bytes32 public constant UPDATE_ROLE = keccak256("UPDATE_ROLE");

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /// @dev Grants `DEFAULT_ADMIN_ROLE` to the account that deploys the contract.
    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Updates the description of a contract
    /// @dev Requires `UPDATE_ROLE`; Reverts if the contract does not exist or if the description is stale
    /// @param _contract The address of the contract to update
    /// @param _description The new description of the contract
    function updateContractDescription(
        address _contract,
        string memory _description
    ) external onlyRole(UPDATE_ROLE) {
        if (bytes(contractToDescriptionMaping[_contract]).length == 0) {
            revert ContractNotExist();
        }
        if (
            keccak256(bytes(contractToDescriptionMaping[_contract])) ==
            keccak256(bytes(_description))
        ) {
            revert StaleDescription();
        }
        if (bytes(_description).length == 0) {
            revert CannotSetToEmpty();
        }
        _insertContractDescription(_contract, _description);
    }

    /// @notice Adds a new contract description
    /// @dev Requires `ADD_ROLE`
    /// @param _contract The address of the contract
    /// @param _description The description of the contract
    function addContractDescription(
        address _contract,
        string memory _description
    ) external onlyRole(ADD_ROLE) {
        _insertContractDescription(_contract, _description);
    }

    /// @notice Removes a contract description
    /// @dev Requires `REMOVE_ROLE`
    /// @param _contract The address of the contract to remove
    function removeContractDescription(
        address _contract
    ) external onlyRole(REMOVE_ROLE) {
        delete contractToDescriptionMaping[_contract];
    }

    /*//////////////////////////////////////////////////////////////
                           INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @dev Inserts or updates a contract's description in the mapping
    /// @param _contract The address of the contract
    /// @param _description The description to assign to the contract
    function _insertContractDescription(
        address _contract,
        string memory _description
    ) internal {
        contractToDescriptionMaping[_contract] = _description;
    }
}
