# Deploy script

## Overview

- `Borderless.company`スマートコントラクトのデプロイ用のディレクトリです

---

## STEP

- Script によるデプロイの手順

※注：必ずテストをパスしたソースコードで、デプロイをすること

1. deploy script の作成をする
2. `/.env`ファイルへ、作成した script ファイルを指定する
3. `make`cli で、スマートコントラクトのデプロイ
   1. `Local-net`でデプロイ・動作テスト
   2. `Test-net`でデプロイ・動作テスト ※(1)を pass してデプロイする
   3. `Main-net`でデプロイ・動作テスト ※(2)を pass してデプロイする

---

## Others

- `./Samples`に試行用のサンプルスクリプトを設置しています。
