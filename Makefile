# Copyright 2024 justin
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     https://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

-include .env

.PHONY: all test clean deploy fund help install snapshot format anvil 

DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

all: clean remove install update build

# Clean the repo
clean  :; forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

install:; forge install foundry-rs/forge-std --no-commit && forge install OpenZeppelin/openzeppelin-contracts --no-commit

# Update Dependencies
update:; forge update

build:; forge build

test: test-pietrzak test-wesolowski test-prime

test-pietrzak:; forge test --mp test/Pietrzak.t.sol --gas-limit 9999999999999999999 --isolate -vv

test-wesolowski:; forge test --mt testWesolowskiAllTestCases --gas-limit 9999999999999999999 --isolate -vv

test-prime:; forge test --mp test/Prime.t.sol --gas-limit 9999999999999999999 --gas-report