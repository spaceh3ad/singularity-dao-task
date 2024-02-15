// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

/// @author Jan Kwiatkowski @spaceh3ad
/// @title Contract Manager for Managing Contract Descriptions
/// @notice This contract allows for the addition, updating, and removal of contract descriptions, with access control.
contract ContractManager {
    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @dev Error used when an operation references a contract address that does not exist in the mapping.
    error ContractNotExist();

    /// @dev Error used when an attempt is made to update a contract's description to the same description it already has.
    error StaleDescription();

    /// @dev Error used when an attempt is made to update a contract's description to an empty string.
    error CannotSetToEmpty();

    /// @dev Error used when an operation is attempted by an unauthorized user.
    error NotOwner();

    /*//////////////////////////////////////////////////////////////
                                STORAGE
    //////////////////////////////////////////////////////////////*/

    /// @dev Maps contract addresses to their descriptions
    mapping(address => string) public contractToDescriptionMaping;

    address public multisigAmin;

    /*//////////////////////////////////////////////////////////////
                        CONSTRUCTOR & MODIFIERS
    //////////////////////////////////////////////////////////////*/
    modifier onlyMultiSigAdmin() {
        if (msg.sender == multisigAmin) {
            _;
        } else revert NotOwner();
    }

    constructor(address _multisigAmin) {
        multisigAmin = _multisigAmin;
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Updates the description of a contract
    /// @dev Only callable via MultiSigAdmin
    /// @param _contract The address of the contract to update
    /// @param _description The new description of the contract
    function updateContractDescription(
        address _contract,
        string memory _description
    ) external onlyMultiSigAdmin {
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
    /// @dev Only callable via MultiSigAdmin
    /// @param _contract The address of the contract
    /// @param _description The description of the contract
    function addContractDescription(
        address _contract,
        string memory _description
    ) external onlyMultiSigAdmin {
        _insertContractDescription(_contract, _description);
    }

    /// @notice Removes a contract description
    /// @dev Only callable via MultiSigAdmin
    /// @param _contract The address of the contract to remove
    function removeContractDescription(
        address _contract
    ) external onlyMultiSigAdmin {
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
