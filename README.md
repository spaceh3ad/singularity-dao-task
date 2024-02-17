## Requirements

This repository was build with Foundry

```
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### Clone repository

```
git clone git@github.com:spaceh3ad/singularity-dao-task.git
cd singularity-dao-task
```

### Build

```shell
forge build
```

### Test & Coverage

```shell
forge test
forge coverage
```

### Security Analysis

1. [Slither](https://github.com/crytic/slither)

   ```shell
   slither .
   ```

2. [Aderyn](https://github.com/Cyfrin/aderyn)

   ```shell
   aderyn .
   ```

   It generates [report.md](./report.md) at project root.

3. [Mythril](https://github.com/Consensys/mythril)

   ```shell
   ❯ myth analyze src/*.sol
   The analysis was completed successfully. No issues were detected.
   ```

### Documentation

Documentation regarding approach and methodology for developing and testing can be found [here](./DOCUMENTATION.md), also more in-depth documentation about test, contract and security analysis can be found in [doc](./doc/)
