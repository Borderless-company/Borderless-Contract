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
bun run deploy --network localhost
```

## Deploy Base Sepolia

```bash
```bash
bun run deploy --network base-sepolia
```

## Verify contract


```bash
hardhat ignition verify chain-{chainId} --include-unrelated-contracts
```

- 例

```bash
hardhat ignition verify chain-84532 --include-unrelated-contracts
```

## Contract

```bash
│ (index)                   │ Values                                       │
├───────────────────────────┼──────────────────────────────────────────────┤
│ proxy                     │ '0x900DD5Fc08eb610Bd54A157D3107273DE012E7E1' │
│ dictionary                │ '0x94bB86136Dc8059572f8A18d49e52E1c3c3C32E6' │
│ sct                       │ '0xaDd6aD437580959ef4C9dc05398a57085e1A4715' │
│ sctBeacon                 │ '0x5017b05025A6Fb3c0EFB788ea7a40EA86078Caa8' │
│ governanceBeacon          │ '0x014D4dcb8EC83Be08d0C7A393d31fCbD18d8c32E' │
│ lets_jp_llc_exeBeacon     │ '0x798CbA8427C799963e604490292d892446326AA1' │
│ lets_jp_llc_non_exeBeacon │ '0x0f1402300456900581093A577BB3c7eD0e457FF1' │
│ lets_jp_llc_saleBeacon    │ '0x208F26af5ad959dd672350dd757939DA7C8bE197' │
└───────────────────────────┴──────────────────────────────────────────────┘
```