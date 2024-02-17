// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ContractManager} from "../src/ContractManager.sol";
import {MultisigContract} from "../src/MultisigContract.sol";

/// @title Integration Tests for ContractManager and MultisigContract
/// @author Jan Kwiatkowski
/// @dev This contract integrates and tests interactions between ContractManager and MultisigContract, ensuring they work together as expected.
contract Integration is Test {
    ContractManager public contractManager;
    MultisigContract public multisig;

    address alice = address(0xa71ce);
    address bob = address(0xb0b);
    address eve = address(0xe3e);
    address john = address(0x01035);

    address other = address(0x07e1);

    /// Represents a generic contract address for testing descriptions.
    address someContractAddress = address(0x8541);

    event ContractDescriptionAdded(
        address indexed contractAddress,
        string description
    );
    event ContractDescriptionUpdated(
        address indexed contractAddress,
        string description
    );
    event ContractDescriptionRemoved(address indexed contractAddress);
    event ActionExecuted(uint256 indexed actionId);

    /// @notice Sets up the test environment with a MultisigContract and a ContractManager.
    function setUp() public {
        address[] memory owners = new address[](4);
        owners[0] = alice;
        owners[1] = bob;
        owners[2] = eve;
        owners[3] = john;

        multisig = new MultisigContract(owners, 3);
        contractManager = multisig.contractManager();
    }

    /// @notice Tests that a privileged user can propose an action to add a contract description via the multisig mechanism.
    /// @dev Proposes an action and checks for the appropriate event emissions.
    /// @return The action ID of the proposed action.
    function test_addContractDescription() public returns (uint256) {
        string memory desc = "some description";
        uint256 _actionId = proposeAction(
            contractManager.addContractDescription.selector,
            someContractAddress,
            desc
        );

        vm.prank(alice);
        multisig.approveAction(_actionId);

        vm.expectEmit(true, false, false, true);
        emit ContractDescriptionAdded(someContractAddress, desc);

        vm.expectEmit(true, false, false, true);
        emit ActionExecuted(_actionId);

        vm.prank(eve);
        multisig.approveAction(_actionId);

        return _actionId;
    }

    /// @notice Tests that a privileged user can propose an action to update a contract description via the multisig mechanism.
    /// @dev Proposes an action to update the description and verifies it through event emissions.
    function test_updateContractDescription() public {
        test_addContractDescription();

        string memory desc = "some new description";
        uint256 _actionId = proposeAction(
            contractManager.updateContractDescription.selector,
            someContractAddress,
            desc
        );

        vm.prank(alice);
        multisig.approveAction(_actionId);

        vm.expectEmit(true, false, false, true);
        emit ContractDescriptionUpdated(someContractAddress, desc);

        vm.expectEmit(true, false, false, true);
        emit ActionExecuted(_actionId);

        vm.prank(eve);
        multisig.approveAction(_actionId);

        assertEq(
            contractManager.contractToDescriptionMaping(someContractAddress),
            desc
        );
    }

    /// @notice Tests that a privileged user can propose an action to remove a contract description via the multisig mechanism.
    /// @dev Proposes an action to remove the description and checks for the removal through event emissions.
    function test_removeContractDescription() public {
        test_addContractDescription();

        uint256 _actionId = proposeAction(
            contractManager.removeContractDescription.selector,
            someContractAddress,
            ""
        );

        vm.prank(alice);
        multisig.approveAction(_actionId);

        vm.expectEmit(true, false, false, true);
        emit ContractDescriptionRemoved(someContractAddress);
        vm.expectEmit(true, false, false, true);
        emit ActionExecuted(_actionId);
        vm.prank(eve);
        multisig.approveAction(_actionId);

        assertEq(
            contractManager.contractToDescriptionMaping(someContractAddress),
            ""
        );
    }

    /// @dev Proposes and approves an action with given parameters.
    /// @param _selector The function selector of the action to be proposed.
    /// @param _contract The contract address related to the action.
    /// @param _desc The description for the action, if applicable.
    /// @return The action ID of the proposed action.
    function proposeAction(
        bytes4 _selector,
        address _contract,
        string memory _desc
    ) internal returns (uint256) {
        bytes memory data = _selector ==
            contractManager.addContractDescription.selector
            ? encodeAdd(_contract, _desc)
            : _selector == contractManager.updateContractDescription.selector
            ? encodeUpdate(_contract, _desc)
            : encodeRemove(_contract);

        vm.prank(bob);
        multisig.proposeAction(data);

        return uint256(keccak256(data));
    }

    /// Encodes parameters for adding a contract description.
    function encodeAdd(
        address _contract,
        string memory _description
    ) public pure returns (bytes memory) {
        return
            abi.encodeWithSelector(
                ContractManager.addContractDescription.selector,
                _contract,
                _description
            );
    }

    /// Encodes parameters for updating a contract description.
    function encodeUpdate(
        address _contract,
        string memory _description
    ) public pure returns (bytes memory) {
        return
            abi.encodeWithSelector(
                ContractManager.updateContractDescription.selector,
                _contract,
                _description
            );
    }

    /// Encodes parameters for removing a contract description.
    function encodeRemove(
        address _contract
    ) public pure returns (bytes memory) {
        return
            abi.encodeWithSelector(
                ContractManager.removeContractDescription.selector,
                _contract
            );
    }
}
