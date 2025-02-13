## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

- Local

```shell
$ forge script script/SC.s.sol:SCScript --fork-url http://127.0.0.1:8545 --broadcast -vvvv
```

- Metis Testnet

```shell
$ forge script script/SC.s.sol:SCScript \
    --chain 59902 \
    --rpc-url https://sepolia.metisdevops.link \
    --broadcast \
    --verify \
    --verifier blockscout \
    --verifier-url https://sepolia-explorer.metisdevops.link/api/ \
    --legacy \
    -vvvv
```

### Verify

```shell
$ forge script script/SC.s.sol:SCScript \
  --rpc-url https://sepolia.metisdevops.link \
  --resume \
  --verify \
  --verifier blockscout \
  --verifier-url https://sepolia-explorer.metisdevops.link/api/
```

```shell
$ forge verify-contract \
  --rpc-url https://sepolia.metisdevops.link \
  0x79BCB147E56053bcD1B9CcB6d282302b0Ba2ad77 \
  src/Factory/ServiceFactory.sol:ServiceFactory \
  --verifier blockscout \
  --verifier-url https://andromeda-explorer.metis.io/api
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

## Contract

```bash
┌─────────────────────┬────────────────────────────────────────────┐
│        ContractName │                                    Address │
├─────────────────────┼────────────────────────────────────────────┤
│      ServiceFactory │ 0x65aEE29e90CFC1A529b810056721E6A60fd8AC63 │
│                 SCR │ 0x40D1Eb8fCc5b56744850C371237Fee8a6b91c868 │
│        SC_JP_DAOLLC │ 0xf8eBFC5618c3CbD237D50F4eb08f79Dccb96A66D │
│     LETS_JP_LLC_EXE │ 0xc7759E7A160079149F5ae5F6DF97d8E688bcCE3d │
│ LETS_JP_LLC_NON_EXE │ 0xbFC5Ec106001Cea080585C661E7F058Af6A0128D │
│   Governance_JP_LLC │ 0xf3148E7075A616461A7BffeFda990a08f668f08E │
└─────────────────────┴────────────────────────────────────────────┘
```