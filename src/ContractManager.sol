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
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Emitted when a new contract description is added.
    event ContractDescriptionAdded(
        address indexed contractAddress,
        string description
    );
    /// @notice Emitted when a contract description is updated.
    event ContractDescriptionUpdated(
        address indexed contractAddress,
        string description
    );
    /// @notice Emitted when a contract description is removed.
    event ContractDescriptionRemoved(address indexed contractAddress);

    /*//////////////////////////////////////////////////////////////
                                STORAGE
    //////////////////////////////////////////////////////////////*/

    /// @dev Maps contract addresses to their descriptions.
    mapping(address => string) public contractToDescriptionMaping;

    /// @notice The owner of the contract which is allowed to interact with contract.
    address public owner;

    /*//////////////////////////////////////////////////////////////
                        CONSTRUCTOR & MODIFIERS
    //////////////////////////////////////////////////////////////*/
    /// @dev Modifier that only allows the owner to call the function
    modifier onlyOwner() {
        if (msg.sender == owner) {
            _;
        } else revert NotOwner();
    }

    /// @dev Modifier that checks if a contract exists in the mapping
    modifier contractMustExist(address _contract) {
        if (bytes(contractToDescriptionMaping[_contract]).length > 0) {
            _;
        } else revert ContractNotExist();
    }

    /// @notice Initializes a new instance of the ContractManager with the specified owner.
    /// @param _owner The address that will be granted ownership of this contract instance.
    constructor(address _owner) {
        owner = _owner;
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
    ) external onlyOwner contractMustExist(_contract) {
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
        emit ContractDescriptionUpdated(_contract, _description);
    }

    /// @notice Adds a new contract description
    /// @dev Only callable via MultiSigAdmin
    /// @param _contract The address of the contract
    /// @param _description The description of the contract
    function addContractDescription(
        address _contract,
        string memory _description
    ) external onlyOwner {
        _insertContractDescription(_contract, _description);
        emit ContractDescriptionAdded(_contract, _description);
    }

    /// @notice Removes a contract description
    /// @dev Only callable via MultiSigAdmin
    /// @param _contract The address of the contract to remove
    function removeContractDescription(
        address _contract
    ) external onlyOwner contractMustExist(_contract) {
        delete contractToDescriptionMaping[_contract];
        emit ContractDescriptionRemoved(_contract);
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
