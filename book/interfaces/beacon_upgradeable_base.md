# Beacon Upgradeable Base

- [Beacon Upgradeable Base](#beacon-upgradeable-base)
  - [概要](#概要)
  - [基本情報](#基本情報)
  - [データ定義](#データ定義)
    - [Struct](#struct)
    - [Mapping](#mapping)
  - [インターフェース](#インターフェース)
    - [関数](#関数)
      - [`createBeaconProxy`](#createbeaconproxy)
        - [概要](#概要-1)
        - [詳細](#詳細)
        - [パラメータ](#パラメータ)
        - [戻り値](#戻り値)
        - [イベント](#イベント)
      - [`createProxy`](#createproxy)
        - [概要](#概要-2)
        - [詳細](#詳細-1)
        - [パラメータ](#パラメータ-1)
        - [イベント](#イベント-1)
      - [`upgradeBeacon`](#upgradebeacon)
        - [概要](#概要-3)
        - [詳細](#詳細-2)
        - [パラメータ](#パラメータ-2)
        - [イベント](#イベント-2)
      - [`updateBeaconName`](#updatebeaconname)
        - [概要](#概要-4)
      - [詳細](#詳細-3)
        - [パラメータ](#パラメータ-3)
        - [イベント](#イベント-3)
      - [`changeBeaconOnline`](#changebeacononline)
        - [概要](#概要-5)
      - [詳細](#詳細-4)
        - [パラメータ](#パラメータ-4)
        - [イベント](#イベント-4)
      - [`getBeacon`](#getbeacon)
        - [概要](#概要-6)
      - [詳細](#詳細-5)
        - [パラメータ](#パラメータ-5)
      - [戻り値](#戻り値-1)
      - [`getProxy`](#getproxy)
        - [概要](#概要-7)
      - [詳細](#詳細-6)
        - [パラメータ](#パラメータ-6)
      - [戻り値](#戻り値-2)
    - [イベント](#イベント-5)
      - [`BeaconUpgraded`](#beaconupgraded)
      - [`DeployBeaconProxy`](#deploybeaconproxy)
      - [`DeployProxy`](#deployproxy)
      - [`BeaconOnline`](#beacononline)
      - [`BeaconOffline`](#beaconoffline)
    - [エラー](#エラー)
  - [変更履歴](#変更履歴)

## 概要

コントラクトをBeacon Proxy Patternでデプロイさせる。

## 基本情報

| 項目 | 内容 |
| --- | --- |
| コントラクト名 | `BeaconUpgradeableBase`  |
| バージョン | v0.1.0 |
| 監査状況 | **未監査** |

## データ定義

### Struct

| 構造体名  | フィールド名 | 型 | 説明 |
| --- | --- | --- | --- |
| `Beacon` | `name` | `string` | Beaconの名前。 |
|  | `implementation` | `address` | 現在のImplementationコントラクトのアドレス。 |
|  | `isOnline` | `bool` | 現在有効かどうか。 |
|  | `proxyCount` | `uint256` | このBeaconからデプロイされたProxyコントラクトの数。 |
| `Proxy` | `name` | `string` | Proxyコントラクトの名前。 |
|  | `beacon` | `address` | 紐づいているBeacon Proxyコントラクトのアドレス。 |

### Mapping

| 配列名 | Key | Value | 説明 |
| --- | --- | --- | --- |
| `beacons` | `address` | `Beacon` | Beacon Proxyコントラクトのアドレスをキーにして、Beacon構造体を管理している配列。 |
| `proxies` | `address` | `Proxy` | Proxyコントラクトのアドレスをキーにして、Proxy構造体を管理している配列。 |

## インターフェース

### 関数

#### `createBeaconProxy`

##### 概要

Beacon Proxyをデプロイする関数。

##### 詳細

- SCRコントラクト、ServiceFactoryコントラクトから実行されます。
- Beacon Proxyに設定したいImplementationコントラクトは事前にデプロイしておく必要があります。

##### パラメータ

| パラメータ名 | 型 | 説明 |
| --- | --- | --- |
| `implementation` | `address` | Beacon Proxyに設定したいImplementationコントラクトのアドレス |
| `name` | `byte` | Beacon Proxyコントラクトの名前。 |

##### 戻り値

- デプロイしたBeacon Proxyコントラクトのアドレス。

##### イベント

- `DeployBeaconProxy`

#### `createProxy`

##### 概要

デプロイをしたいImplementationコントラクトに紐づくBeacon Proxyコントラクトから、新たなProxyコントラクトをデプロイする関数。

##### 詳細

- SCRコントラクト、ServiceFactoryコントラクトから実行されます。

##### パラメータ

| パラメータ名 | 型 | 説明 |
| --- | --- | --- |
| `beaconProxy`     | `address` | デプロイしたいBeacon Proxyコントラクトのアドレス |
| `initData` | `byte` | デプロイ時に実行するデータ。 |

##### イベント

- `DeployProxy`

#### `upgradeBeacon`

##### 概要

Beacon Proxyコントラクト紐づいているImplementationコントラクトのアドレスを別のアドレスに差し替えて、コントラクトをアップグレードする関数。

##### 詳細

- SCRコントラクト、ServiceFactoryコントラクトから実行されます。
- 更新したいImplementationコントラクは事前にデプロイしておく必要があります。

##### パラメータ

| パラメータ名 | 型 | 説明 |
| --- | --- | --- |
| `beacon`     | `address` | UpgradeしたいBeacon Proxyコントラクトのアドレス。 |
| `newImplementation` | `address` | 更新対象のImplementationコントラクトのアドレス。 |

##### イベント

- `BeaconUpgraded`

#### `updateBeaconName`

##### 概要

Beacon Proxyに紐づけている名前を更新する関数。

#### 詳細

以下の2つの関数が用意されています。

- `updateSCRBeaconName`
  - SCRコントラクト用の関数。
- `updateServiceFactoryBeaconName`
  - ServiceFactoryコントラクト用の関数。

##### パラメータ

| パラメータ名 | 型 | 説明 |
| --- | --- | --- |
| `beacon` | `address` | 名前を更新したいBeacon Proxyコントラクトのアドレス。 |
| `name` | `uint256` | 更新後の名前。 |

##### イベント

- `BeaconNameUpdated`

#### `changeBeaconOnline`

##### 概要

Beacon Proxyを有効化/無効化する関数。

#### 詳細

以下の2つの関数が用意されています。

- `changeSCRBeaconOnline`
  - SCRコントラクト用の関数。
- `changeServiceFactoryBeaconOnline`
  - ServiceFactoryコントラクト用の関数。

##### パラメータ

| パラメータ名 | 型 | 説明 |
| --- | --- | --- |
| `beacon` | `address` | 有効化/無効化したいBeacon Proxyコントラクトのアドレス。 |
| `isOnline` | `uint256` | 有効化/無効化の値。 |

##### イベント

- `BeaconOnline`
- `BeaconOffline`

#### `getBeacon`

##### 概要

Beacon構造体を取得する関数。

#### 詳細

以下の2つの関数が用意されています。

- `getSCRBeacon`
  - SCRコントラクト用の関数。
- `getServiceFactoryBeacon`
  - ServiceFactoryコントラクト用の関数。

##### パラメータ

| パラメータ名 | 型 | 説明 |
| --- | --- | --- |
| `beacon` | `address` | Beaconの情報を取得したいBeacon Proxyコントラクトのアドレス。 |

#### 戻り値

- `Beacon`

#### `getProxy`

##### 概要

Proxy構造体を取得する関数。

#### 詳細

以下の2つの関数が用意されています。

- `getSCRProxy`
  - SCRコントラクト用の関数。
- `getServiceFactoryProxy`
  - ServiceFactoryコントラクト用の関数。

##### パラメータ

| パラメータ名 | 型 | 説明 |
| --- | --- | --- |
| `proxy` | `address` | Proxyの情報を取得したいProxyコントラクトのアドレス。 |

#### 戻り値

- `Proxy`

### イベント

#### `BeaconUpgraded`

Beacon ProxyのImplementationコントラクトアドレスが更新された時に発行されるイベント。

| 引数 | 型 | 説明 |
| --- | --- | --- |
| `implementation` | `address` | 更新前のImplementationコントラクトのアドレス。 |
| `newImplementation` | `address` | 更新後のImplementationコントラクトのアドレス。 |

#### `DeployBeaconProxy`

Beacon Proxyがデプロイされた時に発行されるイベント。

| 引数 | 型 | 説明 |
| --- | --- | --- |
| `beacon` | `address indexed` | デプロイされたBeacon Proxyコントラクトのアドレス。 |
| `name` | `address` | Beacon Proxyコントラクトの名前。 |

#### `DeployProxy`

Beacon ProxyコントラクトからProxyがデプロイされた時に発行されるイベント。

| 引数 | 型 | 説明 |
| --- | --- | --- |
| `proxy` | `address indexed` | Beacon ProxyコントラクトからデプロイされたProxyコントラクトのアドレス。 |
| `name` | `address` | Proxyコントラクトの名前。 |

#### `BeaconOnline`

Beacon Proxyコントラクトが有効化された時に発行されるイベント。

| 引数 | 型 | 説明 |
| --- | --- | --- |
| `beacon` | `address indexed` | 有効化されたBeacon Proxyコントラクトのアドレス。 |

#### `BeaconOffline`

Beacon Proxyコントラクトが無効化された時に発行されるイベント。

| 引数 | 型 | 説明 |
| --- | --- | --- |
| `beacon` | `address indexed` | 無効化されたBeacon Proxyコントラクトのアドレス。 |

### エラー

| エラー名 | 引数 | 説明 |
| --- | --- | --- |
| `InvalidImplementation` | `address`  | Implementationコントラクトが0アドレスの場合のエラー。 |
| `InvalidBeacon` | `address`  | Beacon Proxyコントラクトが適切でない場合のエラー。 |
| `BeaconAlreadyOnlineOrOffline` | `address`  | Beacon Proxyコントラクトが既に有効化・無効化されている場合のエラー。 |

## 変更履歴

| バージョン | 日付 | 変更内容 |
| --- | --- | --- |
| v1.0.0 | 2025-05-07 | 初版 |
