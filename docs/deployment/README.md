# Borderless.company スマートコントラクトのデプロイ

## Overview

このドキュメントでは、Foundry を使用して、`Borderless.company`スマートコントラクトをデプロイする手順について説明します。

## Blockchain Network

1. BASE
   1. Mainnet: `base-mainnet`
   2. Testnet: `Sepolia` or `Holesky`
2. Polygon
   1. Mainnet: `polygon-mainnet`
   2. Testnet: `munbai`
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

1. Foundry がインストールされていること
2. Alchemy で、アカウント開設と API が作成されていること
   1. `API-KEY`を取得する
   2. RPC のエンドポイント`URI`を取得する
3. Etherscan で、アカウント開設、API 作成されていること
   1. `Etherscan`で、`API-KEY`を取得する
   2. `Polygonscan`で、`API-KEY`を取得する
4. `./src`配下に スマートコントラクトのソースコードが準備されていること
5. `./script`配下に、デプロイスクリプトが準備されていること

---

## STEP

1. プロジェクトのルートディレクトリに移動します。

---

## Others
