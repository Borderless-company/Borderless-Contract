# Borderless.company スマートコントラクトのデプロイ

## Overview

このドキュメントでは、Foundry を使用して、`Borderless.company`スマートコントラクトをデプロイする手順について説明します。

## Blockchain Network

1. BASE
   1. Mainnet: `base-mainnet`
   2. Testnet: `Sepolia` or `Holesky`
2. Polygon
   1. Mainnet: `polygon-mainnet`
   2. Testnet: `Amoy`
3. Ethereum
   1. Mainnet: `mainnet`
   2. Testnet: `Sepolia` or `Holesky`
4. `JOC`(Japan Open Chain)
5. L2
   1. Intmax
      1. Mainnet: `Intmax-mainnet`
      2. Testnet: `b`

---

## Setup

- テストネット情報 [Ethereum Sepolia](), [Polygon Amoy](https://polygon.technology/blog/introducing-the-amoy-testnet-for-polygon-pos)

1. Foundry がインストールされていること
2. Alchemy で、`アカウント開設`と `API` が作成されていること
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

### 1. Deploy Local-net

- ローカルネットへのデプロイと動作テスト

1. `anvil`cli でブロックチェーンを起動します
2. `make deploy-localnet`で指定したソースコードをローカルネットにデプロイします
3. `cast`などにより、コントラクトの機能が呼び出せることを確認します

### 2. Deploy Test-net

- テストネットへのデプロイ

---

- Ethereum Test-net Sepolia

1. `make deploy-localnet-sepolia`で指定したソースコードをローカルネットにデプロイします
2. `cast`などにより、コントラクトの機能が呼び出せることを確認します

---

- Polygon Test-net Mumbai

1. `make deploy-localnet-munbai`で指定したソースコードをローカルネットにデプロイします
2. `cast`などにより、コントラクトの機能が呼び出せることを確認します

---

## Others
