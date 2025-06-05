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
  describe("正常系機能検証", function () {

    it("〈methodA〉: 正常な引数かつ権限ありで呼び出すと eventA が emit される", async function () {
      const { contract, user1 } = await get〈ContractName〉Context();
      // — 必要ならばロール付与
      await grantRoleUtil(contract, "ROLE_A", user1.address);

      // — 呼び出し
      await expect(
        contract.connect(user1).〈methodA〉(〈validArg1〉, 〈validArg2〉)
      )
        .to.emit(contract, "eventA")
        .withArgs(〈expectedArgX〉, 〈expectedArgY〉);

      // — eventA 発生後の状態確認（例: storage が正しく更新されていること）
      const afterValue = await contract.〈viewMethod〉(〈someKey〉);
      expect(afterValue).to.equal(〈expectedValue〉);
    });

    it("〈viewMethod〉: 事前に特定の状態をセットし、想定の戻り値を返すこと", async function () {
      const { contract, user1 } = await get〈ContractName〉Context();
      // — 例: 何か事前セットアップが必要な場合
      await contract.connect(user1).〈methodA〉(…);
      // — view 関数を呼び出し
      const result = await contract.〈viewMethod〉(〈arg〉);
      expect(result).to.equal(〈expectedReturn〉);
    });

    // 関数内に複数分岐がある場合、そのすべてを網羅する正常系シナリオを追加
    it("〈methodB〉: 分岐条件を満たすと特定の動作を行い、eventB を emit する", async function () {
      const { contract, user2 } = await get〈ContractName〉Context();
      // — 例: 分岐を引き起こすための状態設定
      await contract.connect(user2).〈setupMethod〉(〈args〉);

      await expect(
        contract.connect(user2).〈methodB〉(〈branchArg〉)
      )
        .to.emit(contract, "eventB")
        .withArgs(〈expectedArgForBranch〉);

      // — 分岐後の storage 検証
      const storageValue = await contract.〈viewMethod〉(〈key〉);
      expect(storageValue).to.equal(〈branchExpectedValue〉);
    });

  });
```

### 3.2 異常系テストグループ

```ts
  describe("異常系チェック", function () {

    it("権限なしで 〈methodA〉 を呼ぶと CustomErrorNotAuthorized で revert する", async function () {
      const { contract, user2 } = await get〈ContractName〉Context();
      // user2 は権限を持たない状態
      await expect(
        contract.connect(user2).〈methodA〉(〈anyArg1〉, 〈anyArg2〉)
      ).to.be.revertedWithCustomError(contract, "CustomErrorNotAuthorized");
    });

    it("無効な引数で 〈methodA〉 を呼ぶと CustomErrorA で revert する", async function () {
      const { contract, user1 } = await get〈ContractName〉Context();
      await grantRoleUtil(contract, "ROLE_A", user1.address);
      // arg1 が無効 (例: 0 または 範囲外) として呼ぶ
      await expect(
        contract.connect(user1).〈methodA〉(〈invalidArg1〉, 〈invalidArg2〉)
      ).to.be.revertedWithCustomError(contract, "CustomErrorA");
    });

    it("〈methodB〉: 条件を満たさないと revert (CustomErrorB)", async function () {
      const { contract, user3 } = await get〈ContractName〉Context();
      // 事前に分岐条件を満たさない状態を作る
      // たとえば、methodB は「あるフラグが立っていないとエラー」とする場合
      // await contract.connect(user3).clearFlag();
      await expect(
        contract.connect(user3).〈methodB〉(〈anyArg〉)
      ).to.be.revertedWithCustomError(contract, "CustomErrorB");
    });

    it("投票期間外に approveTransaction を呼ぶと NotInVotePeriod で revert する", async function () {
      const { contract, user4 } = await get〈ContractName〉Context();
      // 事前に投票期間が過ぎたトランザクションを登録しておく
      // await contract.connect(user1).registerTransaction(〈pastVoteStart〉, 〈pastVoteEnd〉, …);
      await expect(
        contract.connect(user4).approveTransaction(〈txId〉)
      ).to.be.revertedWithCustomError(contract, "NotInVotePeriod");
    });

    // メソッド内の複数分岐を網羅するために、各エラーケースを個別にテスト
    it("ダブル承認を防ぐ: すでに承認済みで 2 回目を呼ぶと AlreadyApproved で revert", async function () {
      const { contract, user1, user2 } = await get〈ContractName〉Context();
      // register + approve を事前に行う
      // await contract.connect(user1).registerTransaction(…);
      // await grantRoleUtil(contract, "ROLE_VOTER", user2.address);
      // await tokenMintUtil(contract, user2, user2.address);  // トークンホルダー条件を満たす場合
      // await contract.connect(user2).approveTransaction(〈txId〉);

      // 2 回目の approve
      await expect(
        contract.connect(user2).approveTransaction(〈txId〉)
      ).to.be.revertedWithCustomError(contract, "AlreadyApproved");
    });

    it("閾値未満で execute を呼ぶと ThresholdNotReached で revert する", async function () {
      const { contract, user1, user2, user3 } = await get〈ContractName〉Context();
      // registerTransaction を行い、1 人だけ承認（LEVEL_1: 2/3 必須）
      // await contract.connect(user1).registerTransaction(…);
      // await grantRoleUtil(contract, "ROLE_VOTER", user2.address);
      // await tokenMintUtil(contract, user2, user2.address);
      // await contract.connect(user2).approveTransaction(〈txId〉);

      await expect(
        contract.connect(user1).execute(〈txId〉)
      ).to.be.revertedWithCustomError(contract, "ThresholdNotReached");
    });

    it("非実行者が execute を呼ぶと NotExecutor で revert する", async function () {
      const { contract, user1, user2, user3 } = await get〈ContractName〉Context();
      // registerTransaction を行い、複数承認して閾値を満たす
      // await contract.connect(user1).registerTransaction(…);
      // await grantRoleUtil(contract, "ROLE_VOTER", user2.address);
      // await tokenMintUtil(contract, user2, user2.address);
      // await contract.connect(user2).approveTransaction(〈txId〉);
      // await grantRoleUtil(contract, "ROLE_VOTER", user3.address);
      // await tokenMintUtil(contract, user3, user3.address);
      // await contract.connect(user3).approveTransaction(〈txId〉);
      // まだ user4 は実行者ではない

      await expect(
        contract.connect(user4).execute(〈txId〉)
      ).to.be.revertedWithCustomError(contract, "NotExecutor");
    });

  });
```

### 3.3 その他分岐・枝分かれを含む追加テスト

```ts
  describe("内部ロジックの枝分かれを網羅する追加テスト", function () {

    // 例: ある関数が "owner == address(0)" の場合に別ルートを通るなら、その分岐をテスト
    it("〈methodC〉: owner がゼロアドレスの場合、CustomErrorC を revert する", async function () {
      const { contract, user1 } = await get〈ContractName〉Context();
      // 事前に owner を address(0) に設定する方法がある場合
      // await contract.connect(admin).resetOwnerToZero();
      await expect(
        contract.connect(user1).〈methodC〉(〈args〉)
      ).to.be.revertedWithCustomError(contract, "CustomErrorC");
    });

    it("〈methodC〉: 通常ルートでは正常に動作し、eventC が emit される", async function () {
      const { contract, ownerAccount } = await get〈ContractName〉Context();
      // ownerAccount は正しい所有者
      await expect(
        contract.connect(ownerAccount).〈methodC〉(〈validArgs〉)
      )
        .to.emit(contract, "eventC")
        .withArgs(〈expectedArgs〉);
    });

    // 例: 数値計算や境界値チェックがある場合のテスト
    it("〈methodD〉: 数値が最大値を超えたときに CustomErrorD で revert する", async function () {
      const { contract, user1 } = await get〈ContractName〉Context();
      const tooLargeValue = ethers.BigNumber.from("2").pow(256).sub(1).add(1);
      await expect(
        contract.connect(user1).〈methodD〉(tooLargeValue)
      ).to.be.revertedWithCustomError(contract, "CustomErrorD");
    });

    it("〈methodD〉: 辺境値ギリギリの値では正常に処理される", async function () {
      const { contract, user1 } = await get〈ContractName〉Context();
      const maxValue = ethers.BigNumber.from("2").pow(256).sub(1);
      await expect(
        contract.connect(user1).〈methodD〉(maxValue)
      ).not.to.be.reverted;
      // 必要なら結果を検証
      const ret = await contract.〈viewMethodAfterD〉(maxValue);
      expect(ret).to.equal(〈expectedReturnForMax〉);
    });

    // 複数の入力パラメータを組み合わせたパターンをすべて検証
    it("〈methodE〉: 複数引数の組み合わせに対してすべて網羅的にテスト", async function () {
      const { contract, user1 } = await get〈ContractName〉Context();
      const testCases = [
        { a: 1, b: 1, expected: 2 },
        { a: 0, b: 5, expected: 5 },
        { a: 10, b: 0, expected: 10 },
        // … 他の組み合わせ
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

### （補足）

* すべての「正常系」「異常系」「分岐パターン」を網羅することで、テストファイルのカバレッジが 100％ に近づきます。
* 本プロンプトをベースに、各コントラクトのメソッドシグネチャやエラー名に合わせて `〈…〉` 部分を適切に置き換えてください。
* 複写して使いやすいよう、最初に全体テンプレートを生成させ、その後微調整を行うと効率的です。
* 条件分岐が非常に多いコントラクトでは、ループで複数ケースを回すテストや、helper 関数を用いてコードを DRY に保つことを検討してください。
