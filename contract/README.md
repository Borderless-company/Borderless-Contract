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

|Service|Implementation Address|Proxy Address|Explorer Link|
|--------|----------------------|-------------|-------------|
|Reserve Contract|-| 0x7b3D6D013525CE19F1686451287de295071F9880 | [Explorer](https://sepolia-explorer.metisdevops.link/address/0x7b3D6D013525CE19F1686451287de295071F9880) |
|Borderless Company| 0xB1e22330d1DD3F411E2c02bf5bC016740c52d959 | 0x6EeB8AF621D8c35C05dEb759A813B4Af9B58E613 | [Explorer](https://sepolia-explorer.metisdevops.link/address/0x6EeB8AF621D8c35C05dEb759A813B4Af9B58E613) |
|Factory Pool Beacon| 0xbdA28953fB1cEc9b11beEb764FD1fA3da0f698Cc | 0xaE7637761A24916061d5e20683f6Da91E86A0D33 | [Explorer](https://sepolia-explorer.metisdevops.link/address/0xaE7637761A24916061d5e20683f6Da91E86A0D33) |
|Governance Service| 0x3f289A88dca5D00037626F2E9b10FB5eB7554B5F | 0xa7575Da6Dc92FaC730C9F1b9F266B9DdA495fA96 | [Explorer](https://sepolia-explorer.metisdevops.link/address/0xa7575Da6Dc92FaC730C9F1b9F266B9DdA495fA96) |
|Treasury Service| 0xD199ec2892C8E2370773777C8efB4220c6dCeE2e | 0x86Ec265360b0a8C9AB02e700Bc783c76277B96cB | [Explorer](https://sepolia-explorer.metisdevops.link/address/0x86Ec265360b0a8C9AB02e700Bc783c76277B96cB) |
|Token Service| 0xa7B7Cb3906a18101F5FBFd9126583A13C1A0545A | 0xFaA6b0F372f8effcc95f1581AaAaa4Afd8419ad5 | [Explorer](https://sepolia-explorer.metisdevops.link/address/0xFaA6b0F372f8effcc95f1581AaAaa4Afd8419ad5) |
--------------------------------
