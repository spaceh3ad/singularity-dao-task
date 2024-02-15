// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.13;

// import {Test, console} from "forge-std/Test.sol";
// import {ContractManager} from "../src/ContractManager.sol";

// contract ContractManagerTestInvariant is Test {
//     ContractManager public t;

//     address alice = address(0xa71ce);
//     address bob = address(0xb0b);
//     address eve = address(0xe3e);

//     address other = address(0x07e1);

//     // @dev some contract address for description
//     address someContractAddress = address(0x8541);

//     function setUp() public {
//         t = new ContractManager();
//         t.grantRole(t.ADD_ROLE(), alice);
//         t.grantRole(t.UPDATE_ROLE(), bob);
//         t.grantRole(t.REMOVE_ROLE(), eve);
//         t.renounceRole(t.DEFAULT_ADMIN_ROLE(), address(this));
//     }

//     function invariant_metadata() public view {
//         // Invariant to check: The contract description for a given address cannot be empty if it exists in the mapping
//         if (
//             bytes(t.contractToDescriptionMaping(someContractAddress)).length > 0
//         ) {
//             assert(
//                 bytes(t.contractToDescriptionMaping(someContractAddress))
//                     .length > 0
//             );
//         }
//     }

//     function checkRole(bytes32 role, address account) internal view {
//         assert(t.hasRole(role, account));
//     }

//     function invariant_roleIntegrity() public view {
//         // assert(t.hasRole(role, account));

//         // checkRole(t.DEFAULT_ADMIN_ROLE(), address(0));
//         checkRole(t.ADD_ROLE(), alice);
//         checkRole(t.UPDATE_ROLE(), bob);
//         checkRole(t.REMOVE_ROLE(), eve);
//     }
// }
