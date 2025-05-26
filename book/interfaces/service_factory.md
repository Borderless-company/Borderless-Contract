# Service Factory

- [Service Factory](#service-factory)
  - [概要](#概要)
  - [基本情報](#基本情報)
  - [データ定義](#データ定義)
    - [Mapping](#mapping)
  - [インターフェース](#インターフェース)
    - [関数](#関数)
      - [`setService`](#setservice)
        - [概要](#概要-1)
        - [詳細](#詳細)
        - [パラメータ](#パラメータ)
        - [イベント](#イベント)
      - [`getServiceType`](#getservicetype)
        - [概要](#概要-2)
        - [詳細](#詳細-1)
        - [パラメータ](#パラメータ-1)
        - [戻り値](#戻り値)
      - [`getFounderService`](#getfounderservice)
        - [概要](#概要-3)
        - [パラメータ](#パラメータ-2)
        - [戻り値](#戻り値-1)
    - [イベント](#イベント-1)
      - [`ActivateService`](#activateservice)
    - [エラー](#エラー)
  - [変更履歴](#変更履歴)

## 概要

Serviceコントラクトの管理やデプロイを行うコントラクト。

## 基本情報

| 項目 | 内容 |
| --- | --- |
| コントラクト名 | `ServiceFactory` |
| バージョン | v0.1.0 |
| 監査状況 | **未監査** |

## データ定義

### Mapping

| 配列名 | Key | Value | 説明 |
| --- | --- | --- | --- |
| `serviceTypes` | `address` | `ServiceType` | Beacon Proxyコントラクトのアドレスごとに、どのServiceタイプかを管理。 |
| `founderServices` | `address` | `ServiceType,address` | founderのアドレスごとに、founderがデプロイしたSmart Companyコントラクトに紐づくServiceタイプとServiceコントラクトのアドレスを管理。 |

## インターフェース

### 関数

#### `setService`

##### 概要

新しいServiceコントラクトを登録する関数。

##### 詳細

`DEFAULT_ADMIN_ROLE`が付与されているアドレスからのみの実行可能。
Beacon Proxyコントラクトを新たにデプロイします。

##### パラメータ

| パラメータ名 | 型 | 説明 |
| --- | --- | --- |
| `implementation` | `address` | Beacon ProxyコントラクトのImplementationコントラクトに設定したいアドレス。 |
| `name` | `string` | Beacon Proxyコントラクトの名前。 |
| `serviceType` | `ServiceType` | Serviceコントラクトのタイプ。 |

##### イベント

- `DeploySmartCompany`

#### `getServiceType`

##### 概要

ServiceコントラクトServiceタイプを取得する関数。

##### 詳細

##### パラメータ

| パラメータ名 | 型 | 説明 |
| --- | --- | --- |
| `beacon` | `address` | Serviceタイプを取得したいBeacon Proxyコントラクトのアドレス。 |

##### 戻り値

| パラメータ名 | 型 | 説明 |
| --- | --- | --- |
| `` | `ServiceType` | Serviceタイプ。 |

#### `getFounderService`

##### 概要

founderとServiceタイプごとのProxyコントラクトアドレスを取得する関数。

##### パラメータ

| パラメータ名 | 型 | 説明 |
| --- | --- | --- |
| `founder` | `address` | founderのアドレス。 |
| `serviceType` | `ServiceType` | Serviceタイプ。 |

##### 戻り値

| パラメータ名 | 型 | 説明 |
| --- | --- | --- |
| `` | `address` | Proxyコントラクトのアドレス。 |

- `getService`

### イベント

#### `ActivateService`

| 引数 | 型 | 説明 |
| --- | --- | --- |
| `beacon` | `address indexed` | デプロイしたProxyのBeacon Proxyコントラクトのアドレス。 |
| `service` | `address indexed` | デプロイしたProxyコントラクトのアドレス。 |

### エラー

| エラー名 | 引数 | 説明 |
| --- | --- | --- |
| `FailDeployService` | `address account, address company, address beacon` | Serviceコントラクトのデプロイに失敗した場合のエラー。 |
| `ServiceNotOnline` | `address address` | デプロイしようとしているServiceコントラクトが無効化されている場合のエラー。 |

## 変更履歴

| バージョン | 日付 | 変更内容 |
| --- | --- | --- |
| v1.0.0 | 2025-05-07 | 初版 |
