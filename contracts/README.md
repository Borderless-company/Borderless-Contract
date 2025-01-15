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
