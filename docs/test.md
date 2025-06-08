以下の要件を満たすテストファイル（TypeScript／Hardhat＋Chai）を生成してください。  
特に、コントラクト内の各関数について「正常系・異常系だけでなく、関数ロジックのあらゆる分岐や条件を網羅する」ようにテストケースを記述します。

---

## 1. 前提  
1. Hardhat 環境で動作し、`loadFixture` を使ってデプロイ／初期化を共通化すること。  
2. テストフレームワークは Mocha、アサーションには Chai（`expect`）を用いること。  
3. ユーティリティ関数群（例：`CreateCompany.ts`、`Role.ts`、`LETSMint.ts`、`Event.ts`、`Encode.ts`）を適宜インポートして活用すること。  
4. ファイル構成例：  
```
test/
├─ utils/
│   ├─ DeployFixture.ts    ← デプロイ用フィクスチャ関数を定義済みと仮定
│   ├─ CreateCompany.ts
│   ├─ Role.ts
│   ├─ LETSMint.ts
│   ├─ Event.ts
│   └─ Encode.ts
├─ SCR.test.ts            ← 既存サンプル
├─ Governance.test.ts     ← 既存サンプル
└─ 〈ContractName〉.test.ts  ← これから生成するファイル
```

5. コメントとテスト名は英語で記述すること。これにより、国際的な開発チームでも理解しやすくなり、コードの可読性が向上します。

---

## 2. テスト対象コントラクト情報（プレースホルダ）  
以下のような情報を用いて、実際のコントラクト名・関数名・イベント名・エラー名に置き換えてください。  

- コントラクト名：  
```
〈ContractName〉
```
- フィクスチャ関数：  
```
deploy〈ContractName〉Fixture
```
（`test/utils/DeployFixture.ts` 内に定義済みと仮定）  
- コントラクトを呼び出すインターフェース：  
```
ethers.getContractAt("〈ContractName〉", proxy.getAddress()) as 〈ContractName〉
```
- 主な外部メソッド例：  
- `〈methodA〉(〈arg1Type〉 arg1, 〈arg2Type〉 arg2)`  
  - **正常系**：指定の `arg1, arg2` で呼ぶと `eventA(argX, argY)` が emit される  
  - **異常系**：
    - 引数 `arg1` が不正（例：`arg1 == 0`） → `CustomErrorA` で revert  
    - `onlyRole(ROLE_A)` 条件を満たさないアドレスが呼ぶ → `CustomErrorNotAuthorized` で revert  
- `〈methodB〉(〈argType〉 arg)`  
  - ある条件分岐内で `if (someCondition) revert CustomErrorB(...)` がある → その両方を網羅  
- `〈viewMethod〉(〈argType〉 arg) returns (〈returnType〉)`  
  - 条件によって返り値が異なる場合は、両方のパターンをテスト  

- ロールやアクセス制御の例：  
- `const ROLE_ADMIN = "0x…";`  
- `grantRole(ROLE_ADMIN, someAddress)`  
- `onlyRole(ROLE_ADMIN)` で保護されたメソッドをテスト  

---

## 3. テストファイルの構成・ポイント  
以下の構造に従って、`〈ContractName〉.test.ts` を作成してください。  
適宜 `〈…〉` のプレースホルダを実際のコントラクト内容に置き換えます。

### ファイル先頭のインポート例  
```ts
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import type { 〈ContractName〉 } from "../../typechain-types";

// テストユーティリティを必要に応じてインポート
import { deploy〈ContractName〉Fixture } from "./utils/DeployFixture";
import { grantRoleUtil } from "./utils/Role";                 // ロール付与用
import { tokenMintUtil } from "./utils/LETSMint";             // トークンミント用
import { getEventDataUtil } from "./utils/Event";             // イベント引数解析用
import { encodeParamsUtil } from "./utils/Encode";            // ABI エンコード用
import { createCompanyUtil } from "./utils/CreateCompany";     // 会社作成サンプル用
```

### フィクスチャ関数（コンテキスト設定）

```ts
describe("〈ContractName〉", function () {

  // --- フィクスチャを使ったコンテキスト構築関数 ---
  const get〈ContractName〉Context = async () => {
    // 1) サインイン用アカウント取得
    const [deployer, user1, user2, user3, user4] = await ethers.getSigners();

    // 2) deploy〈ContractName〉Fixture を呼び出してコントラクトをデプロイ・初期化
    const {
      proxy,     // BorderlessProxyのインスタンス
      〈関連コントラクトアドレス／インスタンス〉
    } = await loadFixture(deploy〈ContractName〉Fixture);

    // 3) メインコントラクトのインスタンス化（proxy経由）
    const contract = (await ethers.getContractAt(
      "〈ContractName〉",
      await proxy.getAddress()
    )) as 〈ContractName〉;

    // 4) 必要に応じて、他サービスやユーティリティのインスタンスも取得（proxy経由）
    //    例: const otherService = await ethers.getContractAt("OtherService", await proxy.getAddress());

    return {
      deployer,
      user1,
      user2,
      user3,
      user4,
      proxy,
      contract,
      〈関連コントラクトインスタンス〉
    };
  };
```

### 3.1 正常系テストグループ

```ts
  describe("Normal Functionality Tests", function () {

    it("〈methodA〉: should emit eventA when called with valid arguments and proper permissions", async function () {
      const { contract, user1 } = await get〈ContractName〉Context();
      // — Grant role if needed
      await grantRoleUtil(contract, "ROLE_A", user1.address);

      // — Call the method
      await expect(
        contract.connect(user1).〈methodA〉(〈validArg1〉, 〈validArg2〉)
      )
        .to.emit(contract, "eventA")
        .withArgs(〈expectedArgX〉, 〈expectedArgY〉);

      // — Verify state after eventA
      const afterValue = await contract.〈viewMethod〉(〈someKey〉);
      expect(afterValue).to.equal(〈expectedValue〉);
    });

    it("〈viewMethod〉: should return expected value when specific state is set", async function () {
      const { contract, user1 } = await get〈ContractName〉Context();
      // — Example: Setup if needed
      await contract.connect(user1).〈methodA〉(…);
      // — Call view function
      const result = await contract.〈viewMethod〉(〈arg〉);
      expect(result).to.equal(〈expectedReturn〉);
    });

    // Add normal scenarios for all branches in the function
    it("〈methodB〉: should perform specific action and emit eventB when branch condition is met", async function () {
      const { contract, user2 } = await get〈ContractName〉Context();
      // — Example: Set up state to trigger branch
      await contract.connect(user2).〈setupMethod〉(〈args〉);

      await expect(
        contract.connect(user2).〈methodB〉(〈branchArg〉)
      )
        .to.emit(contract, "eventB")
        .withArgs(〈expectedArgForBranch〉);

      // — Verify storage after branch
      const storageValue = await contract.〈viewMethod〉(〈key〉);
      expect(storageValue).to.equal(〈branchExpectedValue〉);
    });

  });
```

### 3.2 異常系テストグループ

```ts
  describe("Error Cases", function () {

    it("should revert with CustomErrorNotAuthorized when 〈methodA〉 is called without proper permissions", async function () {
      const { contract, user2 } = await get〈ContractName〉Context();
      // user2 has no permissions
      await expect(
        contract.connect(user2).〈methodA〉(〈anyArg1〉, 〈anyArg2〉)
      ).to.be.revertedWithCustomError(contract, "CustomErrorNotAuthorized");
    });

    it("should revert with CustomErrorA when 〈methodA〉 is called with invalid arguments", async function () {
      const { contract, user1 } = await get〈ContractName〉Context();
      await grantRoleUtil(contract, "ROLE_A", user1.address);
      // Call with invalid arg1 (e.g., 0 or out of range)
      await expect(
        contract.connect(user1).〈methodA〉(〈invalidArg1〉, 〈invalidArg2〉)
      ).to.be.revertedWithCustomError(contract, "CustomErrorA");
    });

    it("〈methodB〉: should revert with CustomErrorB when condition is not met", async function () {
      const { contract, user3 } = await get〈ContractName〉Context();
      // Set up state where branch condition is not met
      // For example, if methodB requires a flag to be set:
      // await contract.connect(user3).clearFlag();
      await expect(
        contract.connect(user3).〈methodB〉(〈anyArg〉)
      ).to.be.revertedWithCustomError(contract, "CustomErrorB");
    });

    it("should revert with NotInVotePeriod when approveTransaction is called outside voting period", async function () {
      const { contract, user4 } = await get〈ContractName〉Context();
      // Register a transaction with past voting period
      // await contract.connect(user1).registerTransaction(〈pastVoteStart〉, 〈pastVoteEnd〉, …);
      await expect(
        contract.connect(user4).approveTransaction(〈txId〉)
      ).to.be.revertedWithCustomError(contract, "NotInVotePeriod");
    });

    // Test each error case individually to cover all branches
    it("should prevent double approval: revert with AlreadyApproved on second approval", async function () {
      const { contract, user1, user2 } = await get〈ContractName〉Context();
      // Set up: register + approve
      // await contract.connect(user1).registerTransaction(…);
      // await grantRoleUtil(contract, "ROLE_VOTER", user2.address);
      // await tokenMintUtil(contract, user2, user2.address);  // If token holder condition is required
      // await contract.connect(user2).approveTransaction(〈txId〉);

      // Second approval attempt
      await expect(
        contract.connect(user2).approveTransaction(〈txId〉)
      ).to.be.revertedWithCustomError(contract, "AlreadyApproved");
    });

    it("should revert with ThresholdNotReached when execute is called before reaching threshold", async function () {
      const { contract, user1, user2, user3 } = await get〈ContractName〉Context();
      // Register transaction and get only one approval (LEVEL_1: 2/3 required)
      // await contract.connect(user1).registerTransaction(…);
      // await grantRoleUtil(contract, "ROLE_VOTER", user2.address);
      // await tokenMintUtil(contract, user2, user2.address);
      // await contract.connect(user2).approveTransaction(〈txId〉);

      await expect(
        contract.connect(user1).execute(〈txId〉)
      ).to.be.revertedWithCustomError(contract, "ThresholdNotReached");
    });

    it("should revert with NotExecutor when execute is called by non-executor", async function () {
      const { contract, user1, user2, user3 } = await get〈ContractName〉Context();
      // Register transaction and get multiple approvals to meet threshold
      // await contract.connect(user1).registerTransaction(…);
      // await grantRoleUtil(contract, "ROLE_VOTER", user2.address);
      // await tokenMintUtil(contract, user2, user2.address);
      // await contract.connect(user2).approveTransaction(〈txId〉);
      // await grantRoleUtil(contract, "ROLE_VOTER", user3.address);
      // await tokenMintUtil(contract, user3, user3.address);
      // await contract.connect(user3).approveTransaction(〈txId〉);
      // user4 is not an executor yet

      await expect(
        contract.connect(user4).execute(〈txId〉)
      ).to.be.revertedWithCustomError(contract, "NotExecutor");
    });

  });
```

### 3.3 その他分岐・枝分かれを含む追加テスト

```ts
  describe("Additional Tests for Internal Logic Branches", function () {

    // Example: If a function has a different path when "owner == address(0)", test that branch
    it("〈methodC〉: should revert with CustomErrorC when owner is zero address", async function () {
      const { contract, user1 } = await get〈ContractName〉Context();
      // If there's a way to set owner to address(0)
      // await contract.connect(admin).resetOwnerToZero();
      await expect(
        contract.connect(user1).〈methodC〉(〈args〉)
      ).to.be.revertedWithCustomError(contract, "CustomErrorC");
    });

    it("〈methodC〉: should work normally and emit eventC in normal path", async function () {
      const { contract, ownerAccount } = await get〈ContractName〉Context();
      // ownerAccount is the correct owner
      await expect(
        contract.connect(ownerAccount).〈methodC〉(〈validArgs〉)
      )
        .to.emit(contract, "eventC")
        .withArgs(〈expectedArgs〉);
    });

    // Example: Test numerical calculations and boundary checks
    it("〈methodD〉: should revert with CustomErrorD when value exceeds maximum", async function () {
      const { contract, user1 } = await get〈ContractName〉Context();
      const tooLargeValue = ethers.BigNumber.from("2").pow(256).sub(1).add(1);
      await expect(
        contract.connect(user1).〈methodD〉(tooLargeValue)
      ).to.be.revertedWithCustomError(contract, "CustomErrorD");
    });

    it("〈methodD〉: should process normally at boundary value", async function () {
      const { contract, user1 } = await get〈ContractName〉Context();
      const maxValue = ethers.BigNumber.from("2").pow(256).sub(1);
      await expect(
        contract.connect(user1).〈methodD〉(maxValue)
      ).not.to.be.reverted;
      // Verify result if needed
      const ret = await contract.〈viewMethodAfterD〉(maxValue);
      expect(ret).to.equal(〈expectedReturnForMax〉);
    });

    // Test all combinations of multiple input parameters
    it("〈methodE〉: should test all combinations of multiple parameters", async function () {
      const { contract, user1 } = await get〈ContractName〉Context();
      const testCases = [
        { a: 1, b: 1, expected: 2 },
        { a: 0, b: 5, expected: 5 },
        { a: 10, b: 0, expected: 10 },
        // … other combinations
      ];
      for (const tc of testCases) {
        await expect(
          contract.connect(user1).〈methodE〉(tc.a, tc.b)
        ).to.emit(contract, "eventE").withArgs(tc.expected);
      }
    });

  });

});
```

---

## 4. 使い方

1. **`DeployFixture.ts` を準備**

   * `deploy〈ContractName〉Fixture` 関数内で、テスト用に必要なコントラクトをすべてデプロイ＆初期化する。
   * 例：Dictionary→BorderlessAccessControl→SCR→ServiceFactory→SCRInitialize→BorderlessProxy→各サービスを登録。

2. **上記プロンプトを AI（ChatGPT など）に与える**

   * プレースホルダ部分（〈ContractName〉、〈methodA〉、〈eventA〉、〈CustomErrorA〉、引数、return 値など）を置き換えずに一旦生成させる。

3. **生成されたテストファイル内のプレースホルダを実際のコントラクト内容に置き換える**

   * たとえば、`〈methodA〉` → `registerTransaction`、`〈eventA〉` → `TransactionCreated`、`〈CustomErrorA〉` → `InvalidProposalLevel` などに変更。
   * 複雑なロジック（Merkleルート計算、シグネチャ検証など）がある場合は、必要に応じて事前セットアップや mock データを追加。

4. **BorderlessProxy経由で呼ばれるコントラクトのテストについて**

   * すべてのコントラクトは`BorderlessProxy`経由で呼び出される
   * コントラクトのインスタンス化は必ず`proxy.getAddress()`を使用
   * 例：
     ```typescript
     const contract = (await ethers.getContractAt(
       "ContractName",
       await proxy.getAddress()
     )) as ContractName;
     ```

   * ロールと権限について：
     - BorderlessProxyに含まれるコントラクトのロール付与権限は `deployer` のみが持つ
     - `founder` が権限を持つのは以下の場合のみ：
       - `createSmartCompany` の実行時
       - デプロイされたSCProxy内のコントラクト
     - 主要なロール値：
       ```typescript
       const DEFAULT_ADMIN_ROLE = "0x0000000000000000000000000000000000000000000000000000000000000000";
       const FOUNDER_ROLE = "0x7ed687a8f2955bd2ba7ca08227e1e364d132be747f42fb733165f923021b0225";
       ```

5. **テストを実行し、すべての分岐がカバーされていることを確認**

   * `npm run test`（または `yarn test`）でテストを実行し、各 `it(...)` が green になることをチェック。
   * テストカバレッジツールを用いて、関数内の各分岐（`if` 文や revert 条件）がすべてカバーされているか確認するとより確実です。

---

## 5. テストの実行手順

1. **フィクスチャの使用**
   - テストの初期設定には`deployJP_DAO_LLCFullFixture`を使用する
   - サインアカウントは`deployJP_DAO_LLCFullFixture`から取得する
   - `createCompany`は直接実行する（`loadFixture`は使用しない）

2. **アカウントの役割**
   - `deployer`: デプロイと初期設定を行うアカウント
   - `founder`: 会社の創設者
   - `executiveMember`: トレジャリーとして使用
   - `executiveMember2`, `executiveMember3`: テスト用の購入者
   - `tokenMinter`: トークンミント権限を持つアカウント

3. **テストの実行順序**
   - 各テストケースは独立して実行可能である必要がある
   - テストケース間で状態を共有しない
   - 各テストケースの開始時に必要な初期状態を設定する

4. **エラーケースのテスト**
   - 各関数の異常系テストを必ず含める
   - アクセス制御のテスト（権限のないユーザーからの呼び出し）
   - 不正なパラメータでの呼び出し
   - 状態に依存する条件のテスト

5. **イベントの検証**
   - 各関数の実行時に発行されるイベントを検証する
   - イベントのパラメータが期待通りの値であることを確認する

---

## 6. LETSBase と LETSSaleBase の Proxy 関係

LETSBase と LETSSaleBase は同じ Proxy アドレスを使用します。テストファイル内で以下のように記述する必要があります：

```typescript
const letsSale = await ethers.getContractAt("LETSSaleBase", services[2]);
const lets = await ethers.getContractAt("LETSBase", services[2]);
```

注意点：
- 両方のコントラクトは同じ Proxy アドレス（`services[2]`）を使用します
- 異なるサービスアドレスを使用するとエラーが発生します
- これは、LETSBase と LETSSaleBase が同じ Proxy コントラクト内に実装されているためです

---

### （補足）

* すべての「正常系」「異常系」「分岐パターン」を網羅することで、テストファイルのカバレッジが 100％ に近づきます。
* 本プロンプトをベースに、各コントラクトのメソッドシグネチャやエラー名に合わせて `〈…〉` 部分を適切に置き換えてください。
* 複写して使いやすいよう、最初に全体テンプレートを生成させ、その後微調整を行うと効率的です。
* 条件分岐が非常に多いコントラクトでは、ループで複数ケースを回すテストや、helper 関数を用いてコードを DRY に保つことを検討してください。
* コメントとテスト名は英語で記述し、国際的な開発チームでも理解しやすいようにしてください。

┌────────────────────────────────────┬──────────────────────────────────────────────┐
│ Contract                           │ Addresses                                    │
├────────────────────────────────────┼──────────────────────────────────────────────┤
│ BorderlessProxy                    │ '0x36C02dA8a0983159322a80FFE9F24b1acfF8B570' │
│ SC_JP_DAO_LLC                      │ '0x04C89607413713Ec9775E14b954286519d836FEf' |
└────────────────────────────────────┴──────────────────────────────────────────────┘