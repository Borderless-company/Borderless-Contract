# Borderless

## Compile

```bash
bun run build
```

## Test

```bash
bun run test
```

- specific contract test

```bash
bun run test "test/....test.ts"
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

- deploy contract & create company

```bash
bun run deploy:create-company --network localhost
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

## Project

```bash
bun run deploy:kibotcha --network soneium-minato
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
  --contract "contracts/core/Proxy/interfaces/BorderlessProxyFacade.sol:BorderlessProxyFacade" \
  0x1CaC7D630776c87AA2d250DBf1C6796F322352FB
```



## Contract

<details><summary>Base Sepolia</summary>

- deploy

```bash
┌───────────────────────────┬──────────────────────────────────────────────┐
│ (index)                   │ Values                                       │
├───────────────────────────┼──────────────────────────────────────────────┤
│ proxy                     │ '0x6C59F7C01775BfB88A82e20A3bB9321a9Ac788B2' │
│ dictionary                │ '0x8552e43509041112223a9bB0f54D1A39400A29c8' │
│ sct                       │ '0xD4b2a33F18321Db83332a9C8eBA91e3a26d36628' │
│ sctBeacon                 │ '0xeA3Cc68b61b87D05B35f0252b0bcCC77357aC4ED' │
│ governanceBeacon          │ '0x43727e2D9DDA3272d0b7C20D241CdfC87a0ea478' │
│ lets_jp_llc_exeBeacon     │ '0x33a59762515d59908e394A1A53259A7Bb526B891' │
│ lets_jp_llc_non_exeBeacon │ '0x9Bc014f74c67C45a387A81F7E52ff3712c0b65e9' │
│ lets_jp_llc_saleBeacon    │ '0x9BCE158B8342FBd834DEF07C586D64Eb19F7d465' │
└───────────────────────────┴──────────────────────────────────────────────┘
```

- token mint

```bash
┌───────────────────────────┬──────────────────────────────────────────────┐
│ (index)                   │ Values                                       │
├───────────────────────────┼──────────────────────────────────────────────┤
│ proxy                     │ '0xba31B436ECD3D85CC8d8f58B1e3e57Ec7dAd4664' │
│ dictionary                │ '0xA6CAdC12C56c0032937bC7d63c54F828BC5b6d44' │
│ sct                       │ '0x9Eb049b4C6C7503cfA70c53cB2026C60df7157Bc' │
│ sctBeacon                 │ '0x898031037151AbEe52887aAc19d5D909A7B3ADcb' │
│ governanceBeacon          │ '0x4F31E95a28775a45BaD04e37777AF254a039Be8a' │
│ lets_jp_llc_exeBeacon     │ '0xb5B94a7Fd024b3aB2268E1011ae28f383C9cb5fe' │
│ lets_jp_llc_non_exeBeacon │ '0x3bc725aefd30CeA9932230Cb9477134c3A005192' │
│ lets_jp_llc_saleBeacon    │ '0x03E67D7881D5285cFB530e7D234Fac7C81eFCCAb' │
│ letsExeProxy              │ '0x7af607CB01Ca72039B609b56eb25003F8e4407fB' │
│ letsNonExeProxy           │ '0x22ef5649F71dc8c62AC88403ff1B4881702948Df' │
└───────────────────────────┴──────────────────────────────────────────────┘
```

</details>

<details><summary>Soneium Minato</summary>

- kibotcha

```bash
┌───────────────────────────┬──────────────────────────────────────────────┐
│ (index)                   │ Values                                       │
├───────────────────────────┼──────────────────────────────────────────────┤
│ proxy                     │ '0x41Cc2c71D499795e9C35Dbf105159cDFCcC1de3c' │
│ dictionary                │ '0xDBc7eed10E6335C235a3d4e2Fd01F369B30965E1' │
│ sct                       │ '0x62f177Bf5517C7dE323605E4E783e6DEBb90fd14' │
│ sctBeacon                 │ '0xeb822d51bdf7fDa8B33bA200D77d8E07B5fcce6a' │
│ governanceBeacon          │ '0x1cF6C32b5e6EBcccD3981E890312629A019eED04' │
│ lets_jp_llc_exeBeacon     │ '0x4f6022267464803166A1eF7188f8A2FC4B84eD2C' │
│ lets_jp_llc_non_exeBeacon │ '0xc666aEf64A9D2208e0214cf05F8BeC9a781DB97f' │
│ lets_jp_llc_saleBeacon    │ '0x300d6e3Dd6BAB1FE8D8c2940F56E22De0C075744' │
│ letsExeProxy              │ '0xdbA1E17E8A6f950b9502B9c3A79421CA9a9E3314' │
│ kibotchaLetsNonExeProxy   │ '0x8B40E01A9CD0EE856CD3eB51B1E6AC03F3e3921a' │
└───────────────────────────┴──────────────────────────────────────────────┘
```

</details>