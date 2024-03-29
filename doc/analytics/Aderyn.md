# Aderyn Analysis Report

This report was generated by [Aderyn](https://github.com/Cyfrin/aderyn), a static analysis tool built by [Cyfrin](https://cyfrin.io), a blockchain security company. This report is not a substitute for manual audit or security review. It should not be relied upon for any purpose other than to assist in the identification of potential security vulnerabilities.
# Table of Contents

- [Summary](#summary)
  - [Files Summary](#files-summary)
  - [Files Details](#files-details)
  - [Issue Summary](#issue-summary)
- [Medium Issues](#medium-issues)
  - [M-1: Centralization Risk for trusted owners](#m-1-centralization-risk-for-trusted-owners)
- [Low Issues](#low-issues)
  - [L-1: PUSH0 is not supported by all chains](#l-1-push0-is-not-supported-by-all-chains)
- [NC Issues](#nc-issues)
  - [NC-1: Constants should be defined and used instead of literals](#nc-1-constants-should-be-defined-and-used-instead-of-literals)
  - [NC-2: Event is missing `indexed` fields](#nc-2-event-is-missing-indexed-fields)


# Summary

## Files Summary

| Key | Value |
| --- | --- |
| .sol Files | 2 |
| Total nSLOC | 143 |


## Files Details

| Filepath | nSLOC |
| --- | --- |
| src/ContractManager.sol | 67 |
| src/MultisigContract.sol | 76 |
| **Total** | **143** |


## Issue Summary

| Category | No. of Issues |
| --- | --- |
| Critical | 0 |
| High | 0 |
| Medium | 1 |
| Low | 1 |
| NC | 2 |


# Medium Issues

## M-1: Centralization Risk for trusted owners

Contracts have owners with privileged rights to perform admin tasks and need to be trusted to not perform malicious updates or drain funds.

- Found in src/ContractManager.sol [Line: 88](src/ContractManager.sol#L88)

	```solidity
	    ) external onlyOwner contractMustExist(_contract) {
	```

- Found in src/ContractManager.sol [Line: 110](src/ContractManager.sol#L110)

	```solidity
	    ) external onlyOwner {
	```

- Found in src/ContractManager.sol [Line: 120](src/ContractManager.sol#L120)

	```solidity
	    ) external onlyOwner contractMustExist(_contract) {
	```

- Found in src/MultisigContract.sol [Line: 111](src/MultisigContract.sol#L111)

	```solidity
	    function proposeAction(bytes calldata _executionData) external onlyOwner {
	```

- Found in src/MultisigContract.sol [Line: 135](src/MultisigContract.sol#L135)

	```solidity
	    function approveAction(uint256 _actionId) external onlyOwner {
	```



# Low Issues

## L-1: PUSH0 is not supported by all chains

Solc compiler version 0.8.20 switches the default target EVM version to Shanghai, which means that the generated bytecode will include PUSH0 opcodes. Be sure to select the appropriate EVM version in case you intend to deploy on a chain other than mainnet like L2 chains that may not support PUSH0, otherwise deployment of your contracts will fail.

- Found in src/ContractManager.sol [Line: 2](src/ContractManager.sol#L2)

	```solidity
	pragma solidity 0.8.20;
	```

- Found in src/MultisigContract.sol [Line: 2](src/MultisigContract.sol#L2)

	```solidity
	pragma solidity 0.8.20;
	```



# NC Issues

## NC-1: Constants should be defined and used instead of literals



- Found in src/MultisigContract.sol [Line: 126](src/MultisigContract.sol#L126)

	```solidity
	        pendingActions[actionId] = Action(_executionData, 1);
	```



## NC-2: Event is missing `indexed` fields

Index event fields make the field more quickly accessible to off-chain tools that parse events. However, note that each index field costs extra gas during emission, so it's not necessarily best to index the maximum allowed per event (three fields). Each event should use three indexed fields if there are three or more fields, and gas usage is not particularly of concern for the events in question. If there are fewer than three fields, all of the fields should be indexed.

- Found in src/ContractManager.sol [Line: 32](src/ContractManager.sol#L32)

	```solidity
	    event ContractDescriptionAdded(
	```

- Found in src/ContractManager.sol [Line: 37](src/ContractManager.sol#L37)

	```solidity
	    event ContractDescriptionUpdated(
	```



