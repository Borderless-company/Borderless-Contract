---
title: Dev Documents
---

## Dev Documents

- Overlay の Borderless.company（プロダクト）
- 日本における合同会社型 DAO（DAO-LLC）テンプレート開発のためのドキュメントです。

1. `Dev Rule` 開発に関するルールを記載しています。**必ず読んでください。**
2. `Documents` 開発に関するドキュメントの一覧を記載しています。

---

### Sample Project

- 今回、参考としている他プロジェクト
  - [CompanyDAO github](https://github.com/CompanyDAO/protocol-contracts)

---

## 1. Dev Rule

### 1. ドキュメント作成に関するルール

1. ナレッジはもちろん、`シーケンス図`はじめ Diagram 図など、各種ドキュメントを必ず作成すること **注**
2. 必ず`ドキュメント・レビュー`をすること

**注:** ドキュメントの作成は、`./contracts/n.template.index.md`（テンプレート）を利用ください。

---

#### 2. コーディング・ルール（規定）

1. `ドキュメント作成に関するルール`により作成した設計をもとに開発をすること
2. SOLID 原則を基本とすること
3. TDD 開発を基本とすること
4. 必ず`コードレビュー`をすること
5. Solidity の記法は[公式のスタイルガイド](https://docs.soliditylang.org/en/v0.8.24/style-guide.html)に準拠する（以下、サンプル）
6. Solidity は最新の Version を利用し、`=0.8.x`のように指定すること

- サンプルのスタイルガイド

```solidity

// 6. サンプル（参考）

//-- variables --//
uint256 _index // 先頭にアンダーバーを記す

//-- call back variables --//
uint256 index_ // 末尾にアンダーバーを記す

//-- internal function name --//
function _callIndex() internal returns(uint256){}// 先頭にアンダーバーを記す

//-- external & public function name --//
function callIndex() external returns(uint256){}// アンダーバーなど付さない

```

---

## 2. Documents

1. `./contracts` Borderless.company(DAO-LLC-JPN) のコントラクト群のドキュメント
