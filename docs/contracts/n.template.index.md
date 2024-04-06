---
title: template contract
---

## Overview

- XX するコントラクトのドキュメントです。

1. `Diagrams` シーケンス図など記載をします
2. `Issue` 課題について記載をします
3. `Others` その他の内容を記載します

---

## Diagrams

---

### 1. Data structure

---

### 2. Class

---

### 3. Sequences

---

## Issue

---

## Others

- Mermaid の SVG 変換

```

docker pull minlag/mermaid-cli:latest
docker run -it --rm -u "${UID}:${GID}" -v ${PWD}:/data minlag/mermaid-cli:latest -i /data/<file番号>.<file名>.index.md

```
