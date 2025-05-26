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

<details><summary>Base Sepolia</summary>

```bash
┌───────────────────────────┬──────────────────────────────────────────────┐
│ (index)                   │ Values                                       │
├───────────────────────────┼──────────────────────────────────────────────┤
│ proxy                     │ '0x94C3115c90ff05c48A8B6C1dA9541de2642a0851' │
│ dictionary                │ '0xAf1b5fC1634d566A6f8a2c851826F52b6ad140c7' │
│ sct                       │ '0x816e6013CB995393eCd9d8e4b2bDd940Ccb6d8d4' │
│ sctBeacon                 │ '0x50ffBce7B0972F225dce2D214A2cC9B8998B1D57' │
│ governanceBeacon          │ '0x6B08F0E7A3aE6fecf701F77e6C9aaca0Ee02E35B' │
│ lets_jp_llc_exeBeacon     │ '0x305A2B6540E5d558ecf8E9177D2D65e632001119' │
│ lets_jp_llc_non_exeBeacon │ '0x926f5Bad437def884010f42584453E180E355FD5' │
│ lets_jp_llc_saleBeacon    │ '0x8Fab5c8EB34E4D33e88494e7700D694681e77791' │
│ letsExeProxy              │ '0x788c9C95adf9588A4ae10ca57e55CA7064F7F0A4' │
│ letsNonExeProxy           │ '0x296d77188Cc53625D968a41d1bD36193C5B130EC' │
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