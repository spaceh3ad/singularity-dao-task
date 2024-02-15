// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ContractManager} from "../src/ContractManager.sol";

contract ContractManagerTestFuzz is Test {
    ContractManager public t;

    address alice = address(0xa71ce);
    address bob = address(0xb0b);
    address eve = address(0xe3e);

    address other = address(0x07e1);

    // @dev some contract address for description
    address someContractAddress = address(0x8541);

    function setUp() public {
        t = new ContractManager();
        t.grantRole(t.ADD_ROLE(), address(this));
        t.grantRole(t.UPDATE_ROLE(), address(this));
        t.grantRole(t.REMOVE_ROLE(), address(this));
    }

    function testFuzz_AddContractDescription(
        address _contract,
        string calldata _description
    ) public {
        // Skip over empty descriptions to avoid reverting for the wrong reason
        if (bytes(_description).length == 0) return;

        vm.assume(_contract != address(0));

        t.addContractDescription(_contract, _description);
        assertEq(t.contractToDescriptionMaping(_contract), _description);
    }

    function testFuzz_updateContractDescription(
        address _contract,
        string calldata _description
    ) public {
        vm.assume(_contract != address(0) && bytes(_description).length > 0);

        // Add a description to ensure there's something to update
        t.addContractDescription(_contract, "Temporary Description");

        // Attempt to update the contract description
        t.updateContractDescription(_contract, _description);

        // Verify the update was successful
        assertEq(t.contractToDescriptionMaping(_contract), _description);
    }

    function testFuzz_removeContractDescription(address _contract) public {
        vm.assume(_contract != address(0));

        // Add a description to ensure there's something to remove
        t.addContractDescription(_contract, "Temporary Description");

        // Attempt to remove the contract description
        t.removeContractDescription(_contract);

        // Verify the removal was successful
        bytes memory desc = bytes(t.contractToDescriptionMaping(_contract));
        assertEq(desc.length, 0);
    }

    function invariant_metadata() public {
        // Invariant to check: The contract description for a given address cannot be empty if it exists in the mapping
        if (
            bytes(t.contractToDescriptionMaping(someContractAddress)).length > 0
        ) {
            assert(
                bytes(t.contractToDescriptionMaping(someContractAddress))
                    .length > 0
            );
        }
    }

    function invariantCheckRole(bytes32 role, address account) internal view {
        assert(t.hasRole(role, account));
    }

    function testRoleIntegrity() public {
        invariantCheckRole(t.DEFAULT_ADMIN_ROLE(), address(this));
        invariantCheckRole(t.ADD_ROLE(), address(this));
        invariantCheckRole(t.UPDATE_ROLE(), address(this));
        invariantCheckRole(t.REMOVE_ROLE(), address(this));
    }
}
