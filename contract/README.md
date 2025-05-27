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
bun run deploy --network localhost
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

<details><summary>Base Sepolia</summary>

```bash
┌───────────────────────────┬──────────────────────────────────────────────┐
│ (index)                   │ Values                                       │
├───────────────────────────┼──────────────────────────────────────────────┤
│ proxy                     │ '0x0eFAB975d9A08bB38eDEBadbA3E82F2d6F57C82f' │
│ dictionary                │ '0xc955c9EaC8D8f4f568f83b1D575B820f27cB8e2E' │
│ sct                       │ '0xBF2377cBBAbF6b87E682C796663A2470Bc696C39' │
│ sctBeacon                 │ '0xD4C13637BA0E26fD14e9e28e17EaBb4c1a542a02' │
│ governanceBeacon          │ '0x2941553244B4c77f67e01213f8B99dAB0E0bEbfC' │
│ lets_jp_llc_exeBeacon     │ '0x38658A4c12160878bA94fA8b7dBC569c30B52008' │
│ lets_jp_llc_non_exeBeacon │ '0x4108AEB58A5a94dda39b7771EfeA99AA6123a0a0' │
│ lets_jp_llc_saleBeacon    │ '0xF7EFAdc56e8ccc6d09b4B186D9aF8Cb9a6CBDca8' │
└───────────────────────────┴──────────────────────────────────────────────┘
```

</details>

<details><summary>Soneium Minato</summary>

```bash
┌───────────────────────────┬──────────────────────────────────────────────┐
│ (index)                   │ Values                                       │
├───────────────────────────┼──────────────────────────────────────────────┤
│ proxy                     │ '0x3784213D4D5057AF218dA4ee8149B5d35fca8e06' │
│ dictionary                │ '0xaE7637761A24916061d5e20683f6Da91E86A0D33' │
│ sct                       │ '0x345aDC40394f4866804172eff1e8773FE4CAD85a' │
│ sctBeacon                 │ '0x0C998FAe13E904F0Af25A32983A893D4ED42e986' │
│ governanceBeacon          │ '0xCC55E1ade3b7EbB340E2e032F13c33a0204C584A' │
│ lets_jp_llc_exeBeacon     │ '0x29E6863556D5320957399283dFe6cd80DDc29168' │
│ lets_jp_llc_non_exeBeacon │ '0x9A675eb7e15beD039d0E28609228a422c5200611' │
│ lets_jp_llc_saleBeacon    │ '0xd829B1b1F7B674272Eed58CF92827e82F8ba087A' │
│ letsExeProxy              │ '0x923e0713d141d3d016D8F82867B8De4A1d112Fcc' │
│ letsNonExeProxy           │ '0x217f6DfefB72aD0D3206b579B69C6A10d29ef3a2' │
└───────────────────────────┴──────────────────────────────────────────────┘
```

</details>