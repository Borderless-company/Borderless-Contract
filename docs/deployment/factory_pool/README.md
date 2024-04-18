# Factory Pool

## Overview

- Borderless.company サービスの Factory Pool に関するドキュメント
  - Borderless.company のサービスリリース（デプロイ）のためのアーキテクト設計、そのためのテンプレートコントラクトを定めています。

---

## Summary

1. Operations
2. FactoryPool
3. FactoryService template
4. Diagram

---

### Operations

1. Actor(実行者)によるオペレーションを記載
2. 【オペレーション詳細】に記載の、`1-Ⅱ-1` "FactoryPool の機能責務"、`1-Ⅴ`"登録"、`2-Ⅳ`"Service 起動"が主なオペレーションになります。

---

#### 1. Actor(実行者)によるオペレーション

1. `Admin`（OverlayAG）の オペレーションによるデプロイ（サービス提供者）
   1. 提供する`Service機能群のFactoryコントラクト`のデプロイ
2. `業務執行社員・代表社員` オペレーションによるデプロイ（サービス利用者）
   1. 業務執行社員・代表社員が、createBorderless を実行する時に、1 が呼び出される

---

#### 2. オペレーション詳細

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

## Contract

1. FactoryPool
2. FactoryService Template

### 1. FactoryPool

1. Data structure
2. Interfaces

---

#### 1-1. Data structure

```solidity
struct ServiceInfo{
   address _service;
   bool _online;
}

address private _owner;
uint256 private _lastIndex;
mapping(uint256 index_ => ServiceInfo info_) _services;
```

---

#### 1-2. Interfaces

- Actor

1. `Owner(OverlayAG)` Devloper(service provider)
2. `exMember(executive-member)` call `getService` from `Register`(RegisterBorderlessCompany) contract

---

- interface

1. `ServiceコントラクトFactory`の登録をする機能
2. 登録した`ServiceコントラクトFactory`のアドレスを参照できる機能
3. 登録した`ServiceコントラクトFactory`のアドレスを更新できる機能
4. 登録した`ServiceコントラクトFactory`の提供状態を更新できる機能

```solidity
/// @title feature interface
interface IFactoryPool{
   function setService(address service_) external;
   function getService(uint256 index_) external returns(address service_, bool online_);
   function updateService(address service_, uint256 index_) external;
   function updateService(address service_, uint256 index_, bool online_) external;
}
```

---

- Event-handling

1. FactoryPool への`新規Service機能追加`イベント
2. `Service リソース（アドレス・状態）の更新`イベント

```solidity
/// @title Event interface
interface EventFactoryPool {
   event NewService(address indexed service_, uint256 indexed index_);
   event UpdateService(address indexed service_, uint256 indexed index_, bool online_);
}
```

---

- Error-handling

1. `Error: FactoryPool/Invalid-Param` 不正なパラメータのリバート
2. `Error: FactoryPool/Only-Owner` 不正なパラメータのリバート

```solidity
/// @title Error interface
interface ErrorFactoryPool {
   error InvalidParam(address service_, uint256 index_, bool online_);
}

modifier onlyOwner() {
    require(msg.sender == _owner, "FactoryPool: Only-Owner");
    _;
}
```

---

### 2. FacotryService Template

- Borderless.company のサービスをデプロイする Factory テンプレート（共通箇所）を定義しています。

1. Data Structure
2. interfaces
3. Template code

#### 2-1. Data structre

```solidity
address private _admin;
address private _register;
```

#### 2-2. interfaces

- Actor

1. `Admin(OverlayAG)` Devloper(service provider)
2. `exMember(executive-member)` call `activate` from `Register`(RegisterBorderlessCompany) contract

---

- interface

```solidity
/// @title common interface for factory service
interface IFactoryService {
    function activate(address admin_, address company_, uint256 serviceID_) external returns (address service_);
}
```

---

- Event-handling

```solidity
/// @title common interface for factory service
interface EventFactoryService {
    event ActivateBorderlessService(address indexed admin_, address indexed service, uint256 indexed serviceID);
}
```

---

- Error-handling

```solidity
// Error-handling
modifier onlyRegister() {
    require(msg.sender == _register, "FactoryService: Only-Register");
    _;
}
```

---

#### 2-3. FacotryService template

- Borderless.company のサービスを生成する Factory コントラクトのテンプレートです。
- **この箇所を変更する** に、サービスコントラクトをコーディングし、デプロイをします。

```solidity
/// @title Test factory smart contract for Borderless.company service
contract FactorySampleService is IFactoryService, EventFactoryService {
    address private _owner;
    address private _register;

    constructor(address register_) {
        _owner = msg.sender;
        _register = register_;
    }

    function activate(address admin_, address company_, uint256 serviceID_) external override onlyRegister returns (address service_) {
        /// Note: common service setup
        SampleService service = new SampleService(admin_, company_); // Note: **この箇所を変更する**

        emit ActivateBorderlessService(admin_, address(service), serviceID_);

        service_ = address(service);
    }

    modifier onlyRegister() {
        require(msg.sender == _register, "FactoryService: Only-Register");
        _;
    }
}
```

---

### 3. Diagram

1. setService
2. updateService
3. getService, activate // Note: createBorderlessCompany methods sequence

---

#### 1. `setService` sequence

![`setService` sequence ](README.md-1.svg)

<details>
<summary>mermaid code</summary>
      ```mermaid
         sequenceDiagram
            participant OW as Owner
            participant FP as FactoryPool<br/>Contract
            participant FS as FactoryService<br/>Contract
            participant EVM as EVM
            participant BC as Blockchain

            alt: Deploy new service factory contract
            Note over OW: 新Service機能コントラクトのデプロイ
            OW ->>+ EVM: Deploy New FactoryService
            EVM ->> EVM: create new FactoryService contract
            EVM -->> BC: transaction
            EVM ->> FS: create contract
            EVM ->>- OW: res: tx and contract address
            end

            alt: setService
            Note over OW: 新Service機能アドレスのFacotryPool登録
            OW ->>+ FP: call setService(address service_)

            FP ->> FP: Error-handling: FactoryPool/Only-Owner
            alt: Error-handling

            Note over FP: Error: FactoryPool/Only-Owner
            FP -->> OW: res: Error Revert FactoryPool/Only-Owner
            Note over FP: OK: FactoryPool/Only-Owner
            end

            FP ->> FP: Error-handling: FactoryPool/Invalid-Param

            alt: Error-handling
            Note over FP: Error: FactoryPool/Invalid-Param
            FP -->> OW: res: Error Revert FactoryPool/Invalid-Param
            Note over FP: OK: FactoryPool/Invalid-Param
            end

            FP ->> FP: increment index
            FP ->> FP: create ServiceInfo
            FP ->> FP: create ServiceInfo
            alt: event NewService
            FP ->> FP: execute event: NewService(address indexed service_, uint256 indexed index_)
            FP -->> BC: transaction
            end

            FP ->>- OW: req: done
            end
      ```

</details>

---

#### 2. `updateService` sequence

![`updateService` sequence ](README.md-2.svg)

<details>
<summary>mermaid code</summary>
      ```mermaid
         sequenceDiagram
            participant OW as Owner
            participant FP as FactoryPool<br/>Contract
            participant FS as FactoryService<br/>Contract
            participant EVM as EVM
            participant BC as Blockchain

            alt: setService sequence
            OW ->> FP: setService down
            end

            alt: updateService
            Note over OW: 登録アドレスのサービス状態更新メソッド
            OW ->>+ FP: call updateService(address service_, uint256 index_, bool online_)
            Note over OW: 登録アドレスのみの更新メソッド
            OW ->>+ FP: call updateService(address service_, uint256 index_)

            FP ->> FP: Error-handling: FactoryPool/Only-Owner
            alt: Error-handling

            Note over FP: Error: FactoryPool/Only-Owner
            FP -->> OW: res: Error Revert FactoryPool/Only-Owner
            Note over FP: OK: FactoryPool/Only-Owner
            end

            FP ->> FP: Error-handling: FactoryPool/Invalid-Param

            alt: Error-handling
            Note over FP: Error: FactoryPool/Invalid-Param
            FP -->> OW: res: Error Revert FactoryPool/Invalid-Param
            Note over FP: OK: FactoryPool/Invalid-Param
            end

            FP ->> FP: getService(index_) return service info

            Note over FP: update ServiceInfo
            FP ->> FP: update address or online state
            FP ->> FP: update ServiceInfo
            alt: event NewService
            FP ->> FP: execute event: UpdateService(address indexed service_, uint256 indexed index_, bool online_)
            FP -->> BC: transaction
            end

            FP ->>- OW: req: done
            end
      ```

</details>

---

#### 3. `getService, activate` sequence

![`getService, activate` sequence ](README.md-3.svg)

<details>
<summary>mermaid code</summary>
      ```mermaid
         sequenceDiagram
            participant EM as Executive Member
            participant OW as Owner
            participant RBC as RegisterBorderlessCompany<br/>Contract
            participant FP as FactoryPool<br/>Contract
            participant FS as FactoryService<br/>Contract
            participant BC as Blockchain

            alt: setService sequence
            OW ->> FP: setService done
            end

            alt: create Borderless.company
            Note over EM: Borderless.company起動
            EM ->>+ RBC: req: BorderlessCompany設立（起動）
            RBC ->> RBC: createBorderlessCompany()
            RBC ->> BC: transaction

            alt: setup Borderless.company service
            Note over RBC: ServiceFactoryアドレスの取得
            alt: getService
            RBC ->>+ FP: execution getService(uint256 index_)
            FP ->>- RBC: res: service address and online status
            end

            alt: Error-handling
            Note over RBC: Error: Register/Service-Offline
            RBC -->> RBC: Error-handling
            RBC -->> EM: res: Error Revert Register/Service-Offline
            Note over RBC: OK: Register/Service-Offline
            end

            alt: IFactory(address).setup
            Note over FS: Service起動（インスタンス化）
            RBC ->>+ FS: execute setup

            alt: Error-handling
            Note over FS: Error: FactoryService/Only-Register
            FS -->> EM: res: Error Revert FactoryService/Only-Register
            Note over FS: OK: FactoryService/Only-Register
            end

            alt: event SetupBorderlessService
            FS ->> FS: execute event: SetupBorderlessService(address indexed service_, uint256 indexed index_, bool online_)
            FS -->> BC: transaction
            end

            end

            end

            FS ->>- RBC: req: done
            RBC ->>- EM: req: done
            end
      ```

</details>

---

## Others

- Mermaid の SVG 変換

```linux
docker pull minlag/mermaid-cli:latest
docker run -it --rm -u "${UID}:${GID}" -v ${PWD}:/data minlag/mermaid-cli:latest -i /data/README.md
```
