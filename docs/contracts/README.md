---
title: Overlay Borderless.company smart contracts document
---

## Overview

- Overlay Borderless.company のスマートコントラクトの開発ドキュメント用のディレクトリです。

---

## Summary

1. Actors `想定されるアクター`
2. Process `サービスプロセス`
3. Contracts `スマートコントラクトの一覧`

---

### Actors

| No  | Actor                | Overview                                      |
| --- | -------------------- | --------------------------------------------- |
| 1   | Executive member     | Manager of Tokenize Company(DAO-LLC)          |
| 2   | Non-executive member | Member of Tokenize Company(DAO-LLC)           |
| 3   | Producer             | Producer of Tokenize Company(DAO-LLC)         |
| 4   | Customer             | Customer of Tokenize Company(DAO-LLC)         |
| 5   | Partner              | Business partner of Tokenize Company(DAO-LLC) |
| 6   | Investor             | Investor of Tokenize Company(DAO-LLC)         |

---

### Process

- STEP

1. Create a Electronic Articles of Incorporation `articles of incorporation`
2. Create a Tokenize Company `Operating Agreement`
3. Use Tokenize Company Dash-board `management company`
4. Token generation event `TGE`

- Assignment

1. STEP-1 We need to conduct consultations for onboarding our customers ourselves.
2. STEP-3 We need to assess the necessity of financial management functions regarding each dividend.`Treasury management`
3. STEP-4 The need for identity verification of token purchasers exists.`KYC management for TGE eventer`

---

## Smart Contract

- Contract list

  1. RegisterBorderlessCompany(Regsit and Factoty contract)
  2. BorderlessCompany(New BorderlessCompany)
  3. Governance
  4. Treasury
  5. Token
     1. Fungible Token(Capital and Governance token and other token)
     2. non-Fungible Token (Membership token and other token)
     3. TGE
  6. Utility
     1. Access Control

## Documents

- 開発資料（Diagram etc）

1. `./1.RegisterTokenyzeCompany.index.md` for RegisterBorderlessCompany contract

- [Overlay Notion ドキュメント（DAO-LLC-JP 開発・検討のためのドキュメント）](https://www.notion.so/overlay-swiss/PoC-DAO-0a1bde6fc64a4d1e919b8e981adbc1bf)
- 開発のための他サンプル（参考）プロジェクト
  - [CompanyDAO github](https://github.com/CompanyDAO/protocol-contracts)
