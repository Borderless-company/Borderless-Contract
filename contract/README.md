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
$ yarn deploy --network metis_sepolia
```

## Verify

```bash
$ yarn hardhat-verify --network metis_sepolia <contract address>
```

- Governance Service

```bash
$ yarn hardhat-verify --network metis_sepolia --contract contracts/FactoryPool/FactoryServices/GovernanceServiceFactory.sol:GovernanceServiceFactory <contract address>
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
│      ServiceFactory │ 0x65aEE29e90CFC1A529b810056721E6A60fd8AC63 │
│                 SCR │ 0x40D1Eb8fCc5b56744850C371237Fee8a6b91c868 │
│        SC_JP_DAOLLC │ 0xf8eBFC5618c3CbD237D50F4eb08f79Dccb96A66D │
│     LETS_JP_LLC_EXE │ 0xc7759E7A160079149F5ae5F6DF97d8E688bcCE3d │
│ LETS_JP_LLC_NON_EXE │ 0xbFC5Ec106001Cea080585C661E7F058Af6A0128D │
│   Governance_JP_LLC │ 0xf3148E7075A616461A7BffeFda990a08f668f08E │
└─────────────────────┴────────────────────────────────────────────┘
```
