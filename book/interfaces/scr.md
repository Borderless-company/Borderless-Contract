# SCR

- [SCR](#scr)
  - [概要](#概要)
  - [基本情報](#基本情報)
  - [データ定義](#データ定義)
    - [Struct](#struct)
    - [Mapping](#mapping)
  - [インターフェース](#インターフェース)
    - [関数](#関数)
      - [`createSmartCompany`](#createsmartcompany)
        - [概要](#概要-1)
        - [詳細](#詳細)
        - [パラメータ](#パラメータ)
        - [イベント](#イベント)
    - [Modifier](#modifier)
      - [`setCompanyInfo`](#setcompanyinfo)
        - [概要](#概要-2)
        - [詳細](#詳細-1)
        - [パラメータ](#パラメータ-1)
        - [イベント](#イベント-1)
    - [Modifier](#modifier-1)
      - [`setSCContract`](#setsccontract)
        - [概要](#概要-3)
        - [詳細](#詳細-2)
        - [パラメータ](#パラメータ-2)
        - [イベント](#イベント-2)
      - [`updateSCContract`](#updatesccontract)
        - [概要](#概要-4)
        - [詳細](#詳細-3)
        - [パラメータ](#パラメータ-3)
        - [イベント](#イベント-3)
      - [`addCompanyInfoFields`](#addcompanyinfofields)
        - [概要](#概要-5)
        - [詳細](#詳細-4)
        - [パラメータ](#パラメータ-4)
        - [イベント](#イベント-4)
      - [`updateCompanyInfoFields`](#updatecompanyinfofields)
        - [概要](#概要-6)
        - [詳細](#詳細-5)
        - [パラメータ](#パラメータ-5)
        - [イベント](#イベント-5)
      - [`deleteCompanyInfoFields`](#deletecompanyinfofields)
        - [概要](#概要-7)
        - [詳細](#詳細-6)
        - [パラメータ](#パラメータ-6)
        - [イベント](#イベント-6)
      - [`getCompanyInfoFields`](#getcompanyinfofields)
        - [概要](#概要-8)
        - [パラメータ](#パラメータ-7)
        - [戻り値](#戻り値)
      - [`getCompanyInfo`](#getcompanyinfo)
        - [概要](#概要-9)
        - [パラメータ](#パラメータ-8)
        - [戻り値](#戻り値-1)
      - [`getCompanyField`](#getcompanyfield)
        - [概要](#概要-10)
        - [パラメータ](#パラメータ-9)
        - [戻り値](#戻り値-2)
      - [`getSmartCompanyId`](#getfoundercompanies)
        - [概要](#概要-11)
        - [パラメータ](#パラメータ-10)
        - [戻り値](#戻り値-3)
    - [イベント](#イベント-7)
      - [`DeploySmartCompany`](#deploysmartcompany)
      - [`UpdateCompanyInfo`](#updatecompanyinfo)
      - [`AddCompanyInfoField`](#addcompanyinfofield)
      - [`UpdateCompanyInfoField`](#updatecompanyinfofield)
      - [`DeleteCompanyInfoField`](#deletecompanyinfofield)
    - [エラー](#エラー)
  - [変更履歴](#変更履歴)

## 概要

Smart Companyコントラクトをデプロイするコントラクト。

## 基本情報

| 項目 | 内容 |
| --- | --- |
| コントラクト名 | `SCR` |
| バージョン | v0.1.0 |
| 監査状況 | **未監査** |

## データ定義

### Struct

| 構造体名  | フィールド名 | 型 | 説明 |
| --- | --- | --- | --- |
| `CompanyInfo` | `companyName` | `string` | Smart Companyの会社名。 |
|  | `companyAddress` | `address` | デプロイしたいSmart Company TemplateのBeacon Proxyコントラクトのアドレス。 |
|  | `founder` | `address` | `FOUNDER_ROLE`を付与するアドレス。 |
|  | `establishmentDate` | `string` | 会社設立日。 |
|  | `jurisdiction` | `string` | 法域。例）JP |
|  | `entityType` | `string` | 法人。例）DAO_LLC |
|  | `createAt` | `uint256` | 作成日。 |
|  | `updateAt` | `uint256` | 更新日。 |

### Mapping

| 配列名 | Key | Value | 説明 |
| --- | --- | --- | --- |
| `companyInfoFields` | `string legalEntityCode` | `string[] countryInfoFields` | 法域・法人ごとに、コントラクト内で管理する会社情報を管理。 |
| `companiesInfo` | `string scid` | `string countryField`, `string value` | 法人番号とコントラクト内で管理する会社情報のフィールドごとに会社情報を管理。 |
| `companies` | `string scid` | `CompanyInfo companyInfo` | 法人番号ごとにSmart Companyの情報を管理。 |
| `founderCompanies` | `address founder` | `string scid` | 代表者ごとに法人番号を管理。 |

## インターフェース

### 関数

#### `createSmartCompany`

##### 概要

Smart CompanyコントラクトとServiceコントラクト群をデプロイする関数。

##### 詳細

`FOUNDER_ROLE`が付与されているアドレスからのみ実行可能。

##### パラメータ

| パラメータ名 | 型 | 説明 |
| --- | --- | --- |
| `scid` | `string` | 法人番号。 |
| `scBeaconProxy` | `address` | デプロイするSmart Company TemplateのBeacon Proxyコントラクトのアドレス。 |
| `legalEntityCode` | `string` | 法域・法人の情報。例）JP_DAO_LLC |
| `companyName` | `string` | 会社名。 |
| `establishmentDate` | `string` | 会社設立日。 |
| `jurisdiction` | `string` | 法域。 |
| `entityType` | `string` | 法人。 |
| `scDeployParam` | `bytes32` | Smart Companyデプロイ時の引数。 |
| `companyInfo` | `string[]` | `countryInfoFields`に登録するデータの配列。 |
| `scsBeaconProxy` | `address[]` | デプロイするServiceコントラクト群のBeacon Proxyコントラクトのアドレス。 |
| `scsDeployParams` | `bytes[]` | Serviceコントラクト群のデプロイ時の引数。 |

##### イベント

- `DeploySmartCompany`

### Modifier

- `onlyOnceEstablish`

#### `setCompanyInfo`

##### 概要

法人番号に紐づく会社情報を更新する関数。

##### 詳細

`FOUNDER_ROLE`が付与されているアドレスからのみ実行可能。

##### パラメータ

| パラメータ名 | 型 | 説明 |
| --- | --- | --- |
| `scid` | `string` | 法人番号。 |
| `companyInfoField` | `string` | 更新したい会社情報のフィールド。 |
| `value` | `string` | 更新したい会社情報のフィールドに格納する値。 |

##### イベント

- `UpdateCompanyInfo`

### Modifier

- `onlyFounder`

#### `setSCContract`

##### 概要

Smart Company Templateを登録する関数。

##### 詳細

`DEFAULT_ADMIN_ROLE`が付与されているアドレスからのみ実行可能。

##### パラメータ

| パラメータ名 | 型 | 説明 |
| --- | --- | --- |
| `scImplementation` | `address` | 追加したいSmart CompanyのImplementationアドレス。 |
| `scName` | `string` | Smart Company Templateの名前。 |

##### イベント

- `DeployBeaconProxy`

#### `updateSCContract`

##### 概要

Smart Company TemplateのImplementationコントラクトを更新する関数。

##### 詳細

`DEFAULT_ADMIN_ROLE`が付与されているアドレスからのみ実行可能。

##### パラメータ

| パラメータ名 | 型 | 説明 |
| --- | --- | --- |
| `beacon` | `address` | 更新したいBeacon Proxyコントラクトのアドレス。 |
| `newSCImplementation` | `address` | 設定したいSmart CompanyのImplementationアドレス。 |

##### イベント

- `BeaconUpgraded`

#### `addCompanyInfoFields`

##### 概要

法域・法人ごとにコントラクト内で管理する会社情報を追加する関数。

##### 詳細

`DEFAULT_ADMIN_ROLE`が付与されているアドレスからのみ実行可能。

##### パラメータ

| パラメータ名 | 型 | 説明 |
| --- | --- | --- |
| `legalEntityCode` | `string` | 法域・法人情報。例）JP_DAO_LLC |
| `field` | `string` | 追加したいフィールド名。 |

##### イベント

- `AddCompanyInfoField`

#### `updateCompanyInfoFields`

##### 概要

法域・法人ごとにコントラクト内で管理する会社情報を更新する関数。

##### 詳細

`DEFAULT_ADMIN_ROLE`が付与されているアドレスからのみ実行可能。

##### パラメータ

| パラメータ名 | 型 | 説明 |
| --- | --- | --- |
| `legalEntityCode` | `string` | 法域・法人情報。例）JP_DAO_LLC |
| `fieldIndex` | `uint256` | 更新したいフィールドのインデックス番号。 |
| `field` | `string` | 設定したいフィールド名。 |

##### イベント

- `UpdateCompanyInfoField`

#### `deleteCompanyInfoFields`

##### 概要

法域・法人ごとにコントラクト内で管理する会社情報を削除する関数。

##### 詳細

`DEFAULT_ADMIN_ROLE`が付与されているアドレスからのみ実行可能。

##### パラメータ

| パラメータ名 | 型 | 説明 |
| --- | --- | --- |
| `legalEntityCode` | `string` | 法域・法人情報。例）JP_DAO_LLC |
| `fieldIndex` | `uint256` | 削除したいフィールドのインデックス番号。 |

##### イベント

- `DeleteCompanyInfoField`

#### `getCompanyInfoFields`

##### 概要

法域・法人ごとにコントラクト内で管理されている会社情報を取得する関数。

##### パラメータ

| パラメータ名 | 型 | 説明 |
| --- | --- | --- |
| `legalEntityCode` | `string` | 法域・法人情報。例）JP_DAO_LLC |

##### 戻り値

| パラメータ名 | 型 | 説明 |
| --- | --- | --- |
| `fields` | `address[]` | フィールド名の配列。 |

#### `getCompanyInfo`

##### 概要

法人番号ごとのコントラクト内で管理されている会社情報を取得する関数。

##### パラメータ

| パラメータ名 | 型 | 説明 |
| --- | --- | --- |
| `scid` | `string` | 法人番号。 |

##### 戻り値

| パラメータ名 | 型 | 説明 |
| --- | --- | --- |
| `companyInfo` | `CompanyInfo` | `CompanyInfo`構造体。 |

#### `getCompanyField`

##### 概要

法域・法人ごとにコントラクト内で管理されている会社情報を、法人番号とフィールド名をもとに取得する関数。

##### パラメータ

| パラメータ名 | 型 | 説明 |
| `scid` | `string` | 法人番号。 |
| `companyInfoField` | `string` | フィールド名。 |

##### 戻り値

| パラメータ名 | 型 | 説明 |
| --- | --- | --- |
| `` | `string` | `companyInfoField`に対応した値。 |

#### `getSmartCompanyId`

##### 概要

founderアドレスの法人番号を取得する関数。

##### パラメータ

| パラメータ名 | 型 | 説明 |
| --- | --- | --- |
| `founder` | `address` | founderのアドレス。 |

##### 戻り値

| パラメータ名 | 型 | 説明 |
| --- | --- | --- |
| `` | `string` | 法人番号。 |

### イベント

#### `DeploySmartCompany`

Smart Companyコントラクトがデプロイされた時に発行されるイベント。

| 引数 | 型 | 説明 |
| --- | --- | --- |
| `founder` | `address indexed` | founderのアドレス。 |
| `company` | `address indexed` | デプロイしたSmart Companyコントラクトのアドレス。 |
| `scid` | `string` | 法人番号。 |

#### `UpdateCompanyInfo`

法人番号に紐づく会社情報が更新された時に発行されるイベント。

| 引数 | 型 | 説明 |
| --- | --- | --- |
| `founder` | `address indexed` | founderのアドレス。 |
| `scid` | `string` | 法人番号。 |
| `companyInfoField` | `string` | 更新された会社情報のフィールド。 |
| `value` | `string` | 更新された値。 |

#### `AddCompanyInfoField`

法域・法人ごとにコントラクト内で管理する会社情報を追加された時に発行されるイベント。

| 引数 | 型 | 説明 |
| --- | --- | --- |
| `account` | `address indexed` | 処理を実行したアドレス。 |
| `legalEntityCode` | `string` | 法域・法人の情報。例）JP_DAO_LLC |
| `field` | `string` | 追加されたフィールド名。 |

#### `UpdateCompanyInfoField`

法域・法人ごとにコントラクト内で管理する会社情報を更新された時に発行されるイベント。

| 引数 | 型 | 説明 |
| --- | --- | --- |
| `account` | `address indexed` | 処理を実行したアドレス。 |
| `fieldIndex` | `uint256 indexed` | 更新されたデータのインデックス番号。 |
| `legalEntityCode` | `string` | 法域・法人の情報。例）JP_DAO_LLC |
| `field` | `string` | 追加されたフィールド名。 |

#### `DeleteCompanyInfoField`

法域・法人ごとにコントラクト内で管理する会社情報を削除された時に発行されるイベント。

| 引数 | 型 | 説明 |
| --- | --- | --- |
| `account` | `address indexed` | 処理を実行したアドレス。 |
| `fieldIndex` | `uint256 indexed` | 削除されたデータのインデックス番号。 |
| `legalEntityCode` | `string` | 法域・法人の情報。例）JP_DAO_LLC |
| `field` | `string` | 削除されたフィールド名。 |

### エラー

| エラー名 | 引数 | 説明 |
| --- | --- | --- |
| `InvalidCompanyInfo` | | Smart Companyコントラクトのデプロイ時に会社情報に登録する引数が適切な形式でない場合のエラー。 |
| `InvalidCompanyInfoLength` | `uint256 expected, uint256 length` | Smart Companyコントラクトのデプロイ時に会社情報に登録する引数の数が適切でない場合のエラー。 |
| `NotActivateService` | `address account, address company, address service` | デプロイしようとしているServiceコントラクトが無効化されている場合のエラー。 |
| `AlreadyRegisteredScid` | `string scid` | Smart Companyコントラクトをデプロイしようとしているfounderアドレスが既に別のSmart Companyコントラクトをデプロイしている場合のエラー。 |
| `InvalidFounder` | `address founder` | founderのアドレスでない場合のエラー。 |
| `FailedDeploySmartCompany` | `string scid` | なんらかの理由でSmart Companyコントラクトのデプロイに失敗した場合のエラー。 |
| `AlreadyEstablish` | `address founder, string scid` | デプロイしようとしている法人番号に紐づくSmart Companyコントラクトが既にデプロイされている場合のエラー。 |
| `SmartCompanyNotOnline` | `address scBeaconProxy` | デプロイしようとしているSmart Companyコントラクトが無効化されている場合のエラー。 |
| `AlreadyDeployedService` | `address founder,address scsAddress,uint256 scsType` | 同じServiceタイプのServiceコントラクトをデプロイしようとしている場合のエラー。 |

## 変更履歴

| バージョン | 日付 | 変更内容 |
| --- | --- | --- |
| v1.0.0 | 2025-05-07 | 初版 |
