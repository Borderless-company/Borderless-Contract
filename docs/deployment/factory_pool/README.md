# Factory Pool

## Overview

- Borderless.company サービスの Factory Pool に関するドキュメントです

---

## Summary

---

## Step

- `Service`のデプロイフロー
- Borderless.company のメンテナー `Admin`が実行する

1. 提供する`Service機能群のFactoryコントラクト`のデプロイ
2. 業務執行社員・代表社員が、createBorderless を実行する時に、1 が呼び出される

---

1. `OverlayAG Admin` オペレーションによるデプロイ（サービス提供者）
   1. `Whitelist`コントラクトのデプロイ
      1. `Whitelist`は、`業務執行社員・代表社員`のホワイトリスト管理と、その登録機能を有する
   2. `FactoryPool`コントラクトのデプロイする。
      1. `FactoryPool`は、`各Serviceリリース用のFacotry`の ID・アドレス管理と、その登録機能を有する
   3. `Register`コントラクトのデプロイし、その時に、`Whitelist`, `FactoryPool`コントラクトのアドレスを登録する。
   4. `各Serviceリリース用のFacotry`コントラクトをデプロイし、その時に、`Register`コントラクトのアドレスを登録する。
   5. `FactoryPool`コントラクトへデプロイした、`各Serviceリリース用のFacotry`コントラクトのアドレスを登録する。
      1. `Register`コントラクトで、`createBorderlessCompany`機能をコールする時にアドレスを参照する。
2. `業務執行社員・代表社員` オペレーションによるデプロイ（サービス利用者）
   1. `Register`コントラクトで、`createBorderlessCompany`を実行する。
   2. `BorderlessCompany`コントラクトが起動する。
   3. `FactoryPool`コントラクトより、`_services`を参照し`各Serviceリリース用のFacotry`コントラクトを実行する
   4. 3 をもとに`各Serviceリリース用のFacotry`コントラクトアドレスを指定して、 `setup`により Service を起動する

---

## Diagrams

### flowchart

### sequence
