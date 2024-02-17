// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "./ContractManager.sol";

/// @author Jan Kwiatkowski @spaceh3ad
/// @title MultisigContract
/// @notice Implements a multisignature contract mechanism where actions require multiple approvals from designated owners before they can be executed. This contract is designed to interact with a ContractManager for managing contract descriptions.
/// @dev The contract utilizes mappings to track ownership, action approvals, and the state of pending actions. Each action is uniquely identified by a hash of its execution data.
contract MultisigContract {
    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @dev Thrown when an unauthorized user attempts to perform an operation reserved for owners.
    error NotOwner();
    /// @dev Thrown when an action does not have the required number of approvals to be executed.
    error NotEnoughApprovals();
    /// @dev Thrown when an attempt to execute an action fails at the ContractManager level.
    error ExecutionFailed(uint256 actionId);
    /// @dev Thrown when an action being approved does not exist in the contract.
    error ActionDoesNotExist();
    /// @dev Thrown when a proposed action already exists.
    error ActionExists();
    /// @dev Thrown when an owner tries to approve an action they have already approved.
    error AleadyApproved();
    /// @dev Thrown when an action is proposed with an invalid selector.
    error InvalidSelector();

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Emitted when an action is successfully executed.
    /// @param actionId The unique identifier of the action that was executed.
    event ActionExecuted(uint256 indexed actionId);

    /// @notice Emitted when a new action is proposed by an owner.
    /// @param actionId The unique identifier of the proposed action.
    /// @param proposer The address of the proposer.
    event ActionProposed(uint256 indexed actionId, address indexed proposer);

    /// @notice Emitted when an owner approves an action.
    /// @param approver The address of the user that approved action.
    event ActionApproved(uint256 indexed actionId, address indexed approver);

    /*//////////////////////////////////////////////////////////////
                                STORAGE
    //////////////////////////////////////////////////////////////*/

    /// @notice Tracks whether an address is an owner of the contract.
    mapping(address => bool) public isOwner;

    /// @dev Assumes the contract will have no more than 255 owners.
    uint8 public approvalThreshold;

    /// @notice The ContractManager contract used to execute actions.
    ContractManager public contractManager;

    struct Action {
        bytes executionData;
        uint8 approvals;
    }

    /// @notice Maps an action ID to its approval status by address.
    mapping(uint256 => mapping(address => bool)) public actionApprovalMapping;

    /// @notice Maps an action ID to its corresponding Action struct.
    mapping(uint256 => Action) public pendingActions;

    /*//////////////////////////////////////////////////////////////
                        CONSTRUCTOR & MODIFIERS
    //////////////////////////////////////////////////////////////*/

    /// @notice Restricts function access to contract owners.
    modifier onlyOwner() {
        if (!isOwner[msg.sender]) revert NotOwner();
        _;
    }

    /// @notice Initializes the contract with given owners and approval threshold.
    /// @param _owners Array of owner addresses.
    /// @param _approvalThreshold Number of approvals required for an action to be executed.
    constructor(address[] memory _owners, uint8 _approvalThreshold) {
        for (uint256 i = 0; i < _owners.length; i++) {
            isOwner[_owners[i]] = true;
        }
        approvalThreshold = _approvalThreshold;
        contractManager = new ContractManager(address(this));
    }

    /*//////////////////////////////////////////////////////////////
                             FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Proposes a new action for approval by the contract owners.
    /// @dev Only callable by an owner.
    /// @dev Reverts if the action already exists or the selector is invalid.
    /// @param _executionData The data to be executed once the action is approved.
    function proposeAction(bytes calldata _executionData) external onlyOwner {
        bytes4 _selector = getSelector(_executionData);

        if (
            _selector != contractManager.updateContractDescription.selector &&
            _selector != contractManager.removeContractDescription.selector &&
            _selector != contractManager.addContractDescription.selector
        ) {
            revert InvalidSelector();
        }

        uint256 actionId = uint256(keccak256(_executionData));
        if (pendingActions[actionId].executionData.length > 0)
            revert ActionExists();

        pendingActions[actionId] = Action(_executionData, 1);
        actionApprovalMapping[actionId][msg.sender] = true;

        emit ActionProposed(actionId, msg.sender);
    }

    /// @notice Approves an action proposed by an owner.
    /// @dev Only callable by an owner. Reverts if the action doesn't exist or has already been approved by the caller.
    /// @param _actionId The unique identifier of the action to approve.
    function approveAction(uint256 _actionId) external onlyOwner {
        if (pendingActions[_actionId].executionData.length == 0)
            revert ActionDoesNotExist();
        if (actionApprovalMapping[_actionId][msg.sender])
            revert AleadyApproved();

        Action storage action = pendingActions[_actionId];
        action.approvals++;

        bytes memory _executionData = action.executionData;

        if (action.approvals < approvalThreshold) {
            actionApprovalMapping[_actionId][msg.sender] = true;
            emit ActionApproved(_actionId, msg.sender);
        } else {
            delete pendingActions[_actionId];
            execute(_actionId, _executionData);
        }
    }

    /// @notice Executes an action.
    /// @dev Internal function called once an action has the required number of approvals.
    /// @param _actionId The unique identifier of the action to execute.
    /// @param _data The execution data of the action.
    function execute(uint256 _actionId, bytes memory _data) internal {
        (bool success, ) = address(contractManager).call(_data);
        if (!success) revert ExecutionFailed(_actionId);
        emit ActionExecuted(_actionId);
    }

    /*//////////////////////////////////////////////////////////////
                               HELPER FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /// @dev Internal function to extract the selector from a function call.
    /// @param _func The function call data.
    function getSelector(bytes calldata _func) internal pure returns (bytes4) {
        return bytes4((_func));
    }
}
