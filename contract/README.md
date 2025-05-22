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
bun run deploy:create-company --network localhost
```

## Deploy Base Sepolia

```bash
```bash
bun run deploy --network base-sepolia
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
│ proxy                     │ '0x669f5e400Ea2FE4A352eD8E20EfD032f7d54CB26' │
│ scProxy                   │ '0xbFFf5C2aB3873490578b4da18d3cb48Bad3e3673' │
│ scrProxy                  │ '0xa8e2325031b0701D894d1FEA90B0C0087FAD318B' │
│ dictionary                │ '0x63bf4c793e32453053f3c4befdC86a83667056f9' │
│ sct                       │ '0x28b1Fa13bd017E7Fd57a4bE5188B0e71951Ea038' │
│ sctBeacon                 │ '0x6BDb0FFD1aa4a3E68ea93d23A2F39D231BE8CF7E' │
│ governanceBeacon          │ '0xCbFdb59302761532974D04aC46836aCd45cf7A27' │
│ lets_jp_llc_exeBeacon     │ '0x2a20f5FdAFcded0741E79728a6c04B993e2949e4' │
│ lets_jp_llc_non_exeBeacon │ '0x1c0Eb7851b765bddA54d942DA358c7F8779e5AeC' │
│ lets_jp_llc_saleBeacon    │ '0xb17f4fEb61f0674E6e96A45122dE6ca0b5BD72c9' │
└───────────────────────────┴──────────────────────────────────────────────┘
```