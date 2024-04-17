# Borderless.company スマートコントラクトのデプロイ

## Overview

このドキュメントでは、Foundry を使用して、`Borderless.company`スマートコントラクトをデプロイする手順について説明します。

---

## Blockchain Network

1. Ethereum
   1. Mainnet: `mainnet`
   2. Testnet: `Sepolia` or `Holesky`
2. Polygon
   1. Mainnet: `polygon-mainnet`
   2. Testnet: `Amoy`
3. BASE
   1. Mainnet: `base-mainnet`
   2. Testnet: `Sepolia` or `Holesky`
4. `JOC`(Japan Open Chain)
5. L2
   1. Intmax
      1. Mainnet: `Intmax-mainnet`
      2. Testnet: `b`

---

## Setup

### Setup_1 Network Info

- [Ethereum Sepolia](https://www.alchemy.com/faucets/ethereum-sepolia),
- [Polygon Amoy](https://polygon.technology/blog/introducing-the-amoy-testnet-for-polygon-pos)

### Setup_2 Deploy Setting

1. [Foundry](https://book.getfoundry.sh/getting-started/installation) がインストールされていること
2. [Alchemy](https://www.alchemy.com/) で、`アカウント開設`と `API` が作成されていること
   1. `API-KEY`を取得する
   2. RPC のエンドポイント`URI`を取得する
3. Etherscan で、アカウント開設、API 作成されていること
   1. [Etherscan](https://etherscan.io/)で、`API-KEY`を取得する
   2. [Polygonscan](https://polygonscan.com/)で、`API-KEY`を取得する
4. `Faucet`でデプロイ用のトークン手数料を取得する
   1. Metamask に必要なネットワーク追加設定
   2. [Ethereum Sepolia faucet](https://www.alchemy.com/faucets/ethereum-sepolia)でトークン取得
   3. [Polygon Amoy faucet](https://faucet.polygon.technology/)でトークン取得
5. `./src`配下に スマートコントラクトのソースコードが準備されていること
6. `./script`配下に、デプロイスクリプトが準備されていること

---

## STEP

### STEP_1. Deploy Local-net

1. `anvil`cli でブロックチェーンを起動します
2. `make deploy-localnet`で指定したソースコードをローカルネットにデプロイします
3. `cast`などにより、コントラクトの機能が呼び出せることを確認します

---

### STEP_2. Deploy Test-net

#### Ethereum Test-net Sepolia

1. `make deploy-localnet-sepolia`で指定したソースコードをローカルネットにデプロイします
2. `cast` cli などで、コントラクトの機能が呼び出せることを確認します

---

#### Polygon Test-net Mumbai

1. `make deploy-localnet-munbai`で指定したソースコードをローカルネットにデプロイします
2. `cast` cli などで、コントラクトの機能が呼び出せることを確認します

---

## Others

- `make run-abi` cli で、コントラクトの ABI を出力できます。
- `foundry-cli`でのコントラクトコール。実際は`makefile`を参照ください。

```linux
// cli sample

// cast send
cast send <contract-address> "<feature-name>(<callback-param-type>)" "<return-param-type>" --rpc-url $(RPC_ENDPOINT_URI) --private-key $(PRIVATE_KEY)

// cast call
cast call <contract-address> "<feature-name>(<callback-param-type>)" "<return-param-type>" --rpc-url $(RPC_ENDPOINT_URI)

// example for call and cast
cast send 0x19a05acce11caf4b33b2fdc097b45a96518d8bba "mintNFT()" "" --rpc-url $(RPC_ENDPOINT_URI) --private-key $(PRIVATE_KEY)

cast call 0xdc64a140aa3e981100a9beca4e685f962f0cf6ca "getBlockTimeStamp()(int256)" "" --rpc-url http://127.0.0.1:8545
```
