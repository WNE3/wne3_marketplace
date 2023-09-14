# WNE3 Marketplace

### About the project
We are a budding Web3 e-commerce startup, aiming to expand the web3 ecosystem by building an open marketplace for NFT utilities, as well as a brand of physical NFTs and a one-of-a-kind blockchain merchandise store.

*For more info visit [WNE3](https://www.wne3.com/) ⭐*


# Getting Started

## Requirements

- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
  - Install git and run `git --version` and you see a response like `git version x.x.x`
- [foundry](https://getfoundry.sh/)
  - forge install and run `forge --version` and you see a response like `forge 0.2.0 (816e00b 2023-03-16T00:05:26.396218Z)`


### Quickstart
Clone this repository
```
git clone https://github.com/WNE3/wne3_marketplace.git
```

### Install dependencies
```
forge install
```
If the above command doesn't install the openzeppelin contracts use this.
```
forge install OpenZeppelin/openzeppelin-contracts --no-commit
```

# Usage

## Start a local node

```
make anvil
```

### Deploy

```shell
$ forge script script/DeployToken.s.sol --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Testing
```
$ forge test
```

or 

```
forge test --fork-url $SEPOLIA_RPC_URL
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Cast

```shell
$ cast <subcommand>
```

### Help
```
forge help
```