include .env

# foundry cli
.PHONY: run-localchain
run-localchain:
	anvil

# sample test script
.PHONY: dss-test
dss-test:
	forge test --match-path test/unittest/dss/Vat/CDP/VatCDP.t.sol --mt test_Success_Vat_CDP_frob_ByAdmin -vvvvv

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
