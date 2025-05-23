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
│ proxy                     │ '0x0b5387D9C4dd4B744A8D91611110D059473aa40b' │
│ dictionary                │ '0x441654379cE71d33B262559A2fCC1ECC5D5C867c' │
│ sct                       │ '0x0d4D35E48B928Cd2CE8086E01293bCfAC338A785' │
│ sctBeacon                 │ '0xC7792AD972C3c552Db3fc9bD8c93cF6C8d422464' │
│ governanceBeacon          │ '0x253dAD70252fAcA6AAcbC178427b317b69138fD7' │
│ lets_jp_llc_exeBeacon     │ '0xaC98d1c73afb972646be6E2788872550705c39E3' │
│ lets_jp_llc_non_exeBeacon │ '0x35B01CF5Ab802f851B7d62AcdD6088570974990d' │
│ lets_jp_llc_saleBeacon    │ '0x92e06f438d11DD49cE850F61025217fe3Ad51f85' │
│ letsExeProxy              │ '0x35cEFea97A15f9927898Ee70164E3F16Cd580c46' │
│ letsNonExeProxy           │ '0xd54f5C53977bC9dB4Daa77551AEF880750c03729' │
└───────────────────────────┴──────────────────────────────────────────────┘
```