# Borderless Company

## Setup

```bash
$ yarn compile
```

## Test

```bash
$ cd packages/hardhat
$ forge test
```

## Deploy

- Local

```bash
$ yarn chain
$ yarn deploy
```

- Metis Sepolia

```bash
$ yarn deploy --network metis_sepolia --tags DeployBorderlessCompanyContract
$ yarn deploy --network metis_sepolia --tags DeployVoteContract
```

## Verify

```bash
$ yarn hardhat-verify --network metis_sepolia <contract address>
```

- Governance Service

```bash
$ yarn hardhat-verify --network metis_sepolia --contract contracts/Vote/Vote.sol:Vote <contract address>
```

- Treasury Service

```bash
$ yarn hardhat-verify --network metis_sepolia --contract contracts/FactoryPool/FactoryServices/TreasuryServiceFactory.sol:TreasuryServiceFactory <contract address>
```

- Token Service

```bash
$ yarn hardhat-verify --network metis_sepolia --contract contracts/FactoryPool/FactoryServices/TokenServiceFactory.sol:TokenServiceFactory <contract address>
```



## Contract Addresses

```bash
┌─────────────────────┬────────────────────────────────────────────┐
│        ContractName │                                    Address │
├─────────────────────┼────────────────────────────────────────────┤
│      ServiceFactory │ 0xFDb81CcBB51003C84cAa40266a69baDB52503206 │
│                 SCR │ 0xBC5104DAe6F28AF74A58fef0FeAdA6e69a7C08e6 │
│        SC_JP_DAOLLC │ 0x7540b4Df437868939e44a52C1A36123Cd31AEFD6 │
│     LETS_JP_LLC_EXE │ 0x3C04183324dCeDd7784a0a052c2c1c811d82889D │
│ LETS_JP_LLC_NON_EXE │ 0x26FF3d340b98eB3c5126dBBF2E0C41Ed97b7aCAd │
│   Governance_JP_LLC │ 0x28991b6120a010509AA7Fa99b638AFF508e13880 │
│                Vote │ 0x185dE225F3E97A17CF64658aa79fb35919a131DC │
└─────────────────────┴────────────────────────────────────────────┘
```

