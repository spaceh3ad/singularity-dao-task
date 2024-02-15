// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ContractManager} from "../src/ContractManager.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

contract ContractManagerTest is Test {
    ContractManager public t;

    address alice = address(0xa71ce);
    address bob = address(0xb0b);
    address eve = address(0xe3e);

    address other = address(0x07e1);

    // @dev some contract address for description
    address someContractAddress = address(0x8541);

    function setUp() public {
        t = new ContractManager();
        t.grantRole(t.ADD_ROLE(), alice);
        t.grantRole(t.UPDATE_ROLE(), bob);
        t.grantRole(t.REMOVE_ROLE(), eve);
    }

    ///@dev should allow privileged user to add contract with description
    function test_addContractDescription() public {
        vm.prank(alice);
        t.addContractDescription(someContractAddress, "some contract");
        assertEq(
            t.contractToDescriptionMaping(someContractAddress),
            "some contract"
        );
    }

    ///@dev should allow privileged user to update contract with description
    function test_updateContractDescription() public {
        test_addContractDescription();
        vm.prank(bob);
        t.updateContractDescription(
            someContractAddress,
            "some contract updated"
        );
        assertEq(
            t.contractToDescriptionMaping(someContractAddress),
            "some contract updated"
        );
    }

    ///@dev should allow privileged user to remove contract with description
    function test_removeContractDescription() public {
        test_addContractDescription();
        vm.prank(eve);
        t.removeContractDescription(someContractAddress);
        assertEq(t.contractToDescriptionMaping(someContractAddress), "");
    }

    /*//////////////////////////////////////////////////////////////
                                REVERTS
    //////////////////////////////////////////////////////////////*/

    ///@dev should revert if not privileged user tries to add contract with description
    function test_revert_interactContractDescriptionNonPrivileged() public {
        address contractAddress = address(0x8541);
        vm.prank(other);
        vm.expectRevert();
        t.addContractDescription(contractAddress, "some contract");
        vm.expectRevert();
        t.updateContractDescription(contractAddress, "some contract");
        vm.expectRevert();
        t.removeContractDescription(contractAddress);
    }

    ///@dev should allow privileged user to remove contract with description
    function test_revert_updateNonExistantContract() public {
        test_addContractDescription();
        vm.prank(bob);
        vm.expectRevert(
            abi.encodeWithSelector(ContractManager.ContractNotExist.selector)
        );
        t.updateContractDescription(address(0x99999999), "");
    }

    ///@dev should revert if description is set to empty
    function test_revert_updateContractDescriptionWithEmptyDescription()
        public
    {
        test_addContractDescription();
        vm.prank(bob);
        vm.expectRevert(
            abi.encodeWithSelector(ContractManager.CannotSetToEmpty.selector)
        );
        t.updateContractDescription(someContractAddress, "");
    }

    ///@dev should allow privileged user to remove contract with description
    function test_revert_updateContractDescriptionWithStaleDescription()
        public
    {
        test_addContractDescription();
        vm.prank(bob);
        vm.expectRevert(
            abi.encodeWithSelector(ContractManager.StaleDescription.selector)
        );
        t.updateContractDescription(someContractAddress, "some contract");
    }
}
