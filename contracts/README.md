# Borderless

## Compile

```bash
bun run build
```

## Deploy

- run local node

```bash
bun run localhost
```

- deploy contract

```bash
# bun run deploy ./ignition/modules/SCR.ts --network localhost
```

- deploy localhost

```bash
bun run deploy ./scripts/deploy.ts --network localhost
```

## Delete cache

```bash
rm -rf ignition/deployments cache
```
