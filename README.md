## Requirements

```
git clone <this repo>
```

foundry

### Build

```shell
$ forge build
```

### Test & Coverage

```shell
forge test
forge coverage
```

### Security Analysis

1. [Slither](https://github.com/crytic/slither)

   ```shell
   slither src/ContractManager.sol --filter-paths /lib
   ```

2. [Aderyn](https://github.com/Cyfrin/aderyn)

   ```shell
   aderyn .
   ```

   It generates [report.md](./report.md) at project root.

3. [Mythril](https://github.com/Consensys/mythril)

   ```shell
   ❯ myth analyze --solc-json mythril.solc.json src/ContractManager.sol
   The analysis was completed successfully. No issues were detected.
   ```

## Documentation

https://book.getfoundry.sh/

## Usage

### Test

```shell
$ forge test
```
