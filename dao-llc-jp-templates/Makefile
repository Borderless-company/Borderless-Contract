include .env

# foundry cli
.PHONY: run-localchain
run-localchain:
	anvil

.PHONY: run-abi
run-abi:
	forge inspect ${CONTRACT_FILE} abi

# sample test script
.PHONY: test
test:
	forge test --match-path test/Services/BorderlessCompany.t.sol --mt test_Success_BorderlessCompany_createBorderlessCompany_byExManaer -vvvvv

# deploy scripts

## LOCAL-NET

.PHONY: deploy-localnet
deploy-localnet:
	forge script script/${DEPLOY} --fork-url ${LOCAL_RPC_URL} --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast -vvvv

## TEST-NET

.PHONY: deploy-testnet-sepolia
deploy-testnet-sepolia: 
	forge script script/${DEPLOY} --fork-url $(ETH_SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast -vvvv

.PHONY: deploy-testnet-sepolia-vf
deploy-testnet-sepolia-vf: 
	forge script script/${TEST_DEPLOY} --fork-url $(ETH_SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --etherscan-api-key $(DEV_ETHERSCAN_API_KEY) --verify -vvvv

.PHONY: deploy-testnet-mumbai
deploy-testnet-mumbai: 
	forge script script/${DEPLOY} --fork-url $(POLY_AMOY_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast -vvvv

.PHONY: deploy-testnet-mumbai-vf
deploy-testnet-mumbai-vf: 
	forge script script/${TEST_DEPLOY} --fork-url $(POLY_AMOY_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --etherscan-api-key $(DEV_POLYGONSCAN_API_KEY) --verify -vvvv

## Forking test

.PHONY: fork-localnet
fork-localnet:
	forge test --fork-url ${LOCAL_RPC_URL} --match-path test/fork/proxy/DSRManager/ForkDSRManager.t.sol --mt test_Success_initializeAndUpdateIlk_byAdmin -vvvvv --evm-version shanghai --no-storage-caching

## Foundry cli cast and call
## Localnet
## 0x5FbDB2315678afecb367f032d93F642f64180aa3 is Whitelist contract address (Local)
## 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 is RegisterBorderlessCompany contract address (Local)

.PHONY: cast-call-localnet
cast-call-localnet:
	cast call 0xe7f1725e7734ce288f8367e1bb143e90bb3f0512 "callAdmin()(bool)" --rpc-url $(LOCAL_RPC_URL) --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

.PHONY: cast-send-localnet-reserve
cast-send-localnet-reserve:
	cast send 0x5FbDB2315678afecb367f032d93F642f64180aa3 "reservation(address)(bool)" "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266" --rpc-url $(LOCAL_RPC_URL) --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

.PHONY: cast-send-localnet-regist
cast-send-localnet-regist:
	cast send 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 "createBorderlessCompany(bytes, bytes, bool)(bool, address)" 0x61 0x61 true --rpc-url $(LOCAL_RPC_URL) --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

## 2024/5/9
## 0x5E3AfCabC38dE9e54F5A1C489FD861178d64cE7E is Reserve contract address (ETH Sepolia)
## Admin
## 0x5afB48E2D7d16F7f2Bf4644738794324b66b0E90
.PHONY: cast-send-testnet-sepolia-reserve-admin
cast-send-testnet-sepolia-reserve-admin:
	cast send 0x5E3AfCabC38dE9e54F5A1C489FD861178d64cE7E "addAdmin(address)(bool)" "0x5afB48E2D7d16F7f2Bf4644738794324b66b0E90" --rpc-url $(ETH_SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY)

## 0x09FaFD544F9dc6656743A5C828FB7491E18bC41D is Whitelist contract address (ETH Sepolia)
## 2024/4/19
## 0xaFD8e809a7f7d7C6bcb67866938F721ff0D345C4 is Whitelist contract address (ETH Sepolia)
## 2024/4/21
## 0x15F8f9FEF076dE5EB7211E9a11c346B6bB957Cd7 is Whitelist contract address (ETH Sepolia)
## Coffee
## 0x3b76BE0a32446b22d50d42524796DD90B25487FD
## 2024/5/9
## 0x5E3AfCabC38dE9e54F5A1C489FD861178d64cE7E is Reserve contract address (ETH Sepolia)
.PHONY: cast-send-testnet-sepolia-reserve
cast-send-testnet-sepolia-reserve:
	cast send 0x5E3AfCabC38dE9e54F5A1C489FD861178d64cE7E "reservation(address)(bool)" "0x3b76BE0a32446b22d50d42524796DD90B25487FD" --rpc-url $(ETH_SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY)

## 0xaFD8e809a7f7d7C6bcb67866938F721ff0D345C4 is Whitelist contract address (Polygon Amoy)
.PHONY: cast-send-testnet-amoy-reserve
cast-send-testnet-amoy-reserve:
	cast send 0xaFD8e809a7f7d7C6bcb67866938F721ff0D345C4 "reservation(address)(bool)" "0x3b76BE0a32446b22d50d42524796DD90B25487FD" --rpc-url $(POLY_AMOY_RPC_URL) --private-key $(PRIVATE_KEY)
