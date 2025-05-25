# Borderless

## Compile

```bash
bun run build
```

## Test

```bash
bun run test
```

## Deploy

- run local node

```bash
bun run localhost
```

- deploy contract

```bash
# bun run deploy:module --network localhost
```

```bash
bun run deploy:create-company-local --network localhost
```

## Deploy Base Sepolia

- deploy

```bash
bun run deploy --network base-sepolia
```

- deploy & token mint


```bash
bun run deploy:create-company --network base-sepolia
```

## Verify contract


```bash
npx hardhat ignition verify chain-{chainId} --include-unrelated-contracts
```

- 例

```bash
npx hardhat ignition verify chain-84532 --include-unrelated-contracts
```

- 単体コントラクトVerify

```bash
npx hardhat verify --network base-sepolia \
  --contract "contracts/core/Dictionary/Dictionary.sol:Dictionary" \
  0x7134A5f0EbE54ef1b5966CB54Ab72ACc24193590
```

```bash
npx hardhat verify --network base-sepolia "0xA960bD38Dcfa44c6e13832bFeC92462cAC3b3326" "0x"  \
  --contract "contracts/core/Proxy/interfaces/SCRProxy.sol:SCRProxy" \
  0x1CaC7D630776c87AA2d250DBf1C6796F322352FB
```



## Contract

```bash
┌───────────────────────────┬──────────────────────────────────────────────┐
│ (index)                   │ Values                                       │
├───────────────────────────┼──────────────────────────────────────────────┤
│ proxy                     │ '0xFc316D98c9A0595D5c0857917a2E95584C6A6774' │
│ dictionary                │ '0x0C336b4d3CF2a2Ceef6e3C05Dff2cDFeF403bF82' │
│ sct                       │ '0x617A36c036237d62ddc9003886488e29D1a981e5' │
│ sctBeacon                 │ '0xF8b2172C066F3598dbfaD0BeE1698f622440B2E1' │
│ governanceBeacon          │ '0x2d19a9A912212b170E3c0FC6720920e94d3804Bf' │
│ lets_jp_llc_exeBeacon     │ '0x07bB137D7cEd02C1eEeF5540D9091e518Db8C96b' │
│ lets_jp_llc_non_exeBeacon │ '0x129146d21f420E579b78a02F0b9F1E434691B0a3' │
│ lets_jp_llc_saleBeacon    │ '0x8F78F20B71f13ab46EAdFeDB1B9258Db3CE422F8' │
│ letsExeProxy              │ '0xeAfA7e28490eB18eD5A57a2c088113c2e9E20FEE' │
│ letsNonExeProxy           │ '0xEA7b114A504661357a6Fbdca0b2749Bd68f9846B' │
└───────────────────────────┴──────────────────────────────────────────────┘
```