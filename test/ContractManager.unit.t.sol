// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ContractManager} from "../src/ContractManager.sol";
import {MultisigContract} from "../src/MultisigContract.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract TestContracts is Test {
    ContractManager public contractManager;
    MultisigContract public multisig;

    address alice = address(0xa71ce);
    address bob = address(0xb0b);
    address eve = address(0xe3e);

    address other = address(0x07e1);

    // @dev some contract address for description
    address someContractAddress = address(0x8541);

    function setUp() public {
        address[] memory owners = new address[](3);
        owners[0] = alice;
        owners[1] = bob;
        owners[2] = eve;

        multisig = new MultisigContract(owners, 2);
        contractManager = multisig.contractManager();
    }

    ///@dev should allow privileged user to add contract with description
    function test_addContractDescription() public {
        bytes memory data = multisig.encodeAdd(
            address(contractManager),
            "some description"
        );
        vm.expectEmit();
        vm.prank(alice);
        multisig.proposeAction(data);
    }

    // ///@dev should allow privileged user to update contract with description
    // function test_updateContractDescription() public {
    //     test_addContractDescription();
    //     vm.prank(bob);
    //     t.updateContractDescription(
    //         someContractAddress,
    //         "some contract updated"
    //     );
    //     assertEq(
    //         t.contractToDescriptionMaping(someContractAddress),
    //         "some contract updated"
    //     );
    // }

    // ///@dev should allow privileged user to remove contract with description
    // function test_removeContractDescription() public {
    //     test_addContractDescription();
    //     vm.prank(eve);
    //     t.removeContractDescription(someContractAddress);
    //     assertEq(t.contractToDescriptionMaping(someContractAddress), "");
    // }

    // /*//////////////////////////////////////////////////////////////
    //                             REVERTS
    // //////////////////////////////////////////////////////////////*/

    // ///@dev should revert if not privileged user tries to add contract with description
    // function test_revert_interactContractDescriptionNonPrivileged() public {
    //     address contractAddress = address(0x8541);
    //     vm.prank(other);
    //     vm.expectRevert();
    //     t.addContractDescription(contractAddress, "some contract");
    //     vm.expectRevert();
    //     t.updateContractDescription(contractAddress, "some contract");
    //     vm.expectRevert();
    //     t.removeContractDescription(contractAddress);
    // }

    // ///@dev should allow privileged user to remove contract with description
    // function test_revert_updateNonExistantContract() public {
    //     test_addContractDescription();
    //     vm.prank(bob);
    //     vm.expectRevert(
    //         abi.encodeWithSelector(ContractManager.ContractNotExist.selector)
    //     );
    //     t.updateContractDescription(address(0x99999999), "");
    // }

    // ///@dev should revert if description is set to empty
    // function test_revert_updateContractDescriptionWithEmptyDescription()
    //     public
    // {
    //     test_addContractDescription();
    //     vm.prank(bob);
    //     vm.expectRevert(
    //         abi.encodeWithSelector(ContractManager.CannotSetToEmpty.selector)
    //     );
    //     t.updateContractDescription(someContractAddress, "");
    // }

    // ///@dev should allow privileged user to remove contract with description
    // function test_revert_updateContractDescriptionWithStaleDescription()
    //     public
    // {
    //     test_addContractDescription();
    //     vm.prank(bob);
    //     vm.expectRevert(
    //         abi.encodeWithSelector(ContractManager.StaleDescription.selector)
    //     );
    //     t.updateContractDescription(someContractAddress, "some contract");
    // }
}
