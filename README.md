# Foundry ERC20 Project

[![CI](https://github.com/tohidul3417/foundry-erc20/actions/workflows/test.yml/badge.svg)](https://github.com/tohidul3417/foundry-erc20/actions/workflows/test.yml)

## Table of Contents

- [Foundry ERC20 Project](#foundry-erc20-project)
  - [Table of Contents](#table-of-contents)
  - [About The Project](#about-the-project)
  - [Getting Started](#getting-started)
    - [Prerequisites](#prerequisites)
    - [Installation \& Setup](#installation--setup)
  - [Usage](#usage)
    - [Building](#building)
    - [Testing](#testing)
    - [Deployment](#deployment)
  - [Continuous Integration](#continuous-integration)
  - [Contributing](#contributing)
  - [License](#license)

## About The Project

This project provides a clear and robust implementation of a standard ERC20 token, built using the Foundry development framework. It leverages the industry-standard OpenZeppelin ERC20 contracts to create a simple, fungible token.

This repository was completed as a code-along project for the **Advanced Foundry** course offered by Cyfrin Updraft. It serves as an excellent starting point for anyone looking to learn about token creation on EVM-compatible blockchains or for developers needing a clean boilerplate for a new ERC20 project with Foundry.

## Getting Started

Follow these instructions to get a copy of the project up and running on your local machine for development and testing.

### Prerequisites

You will need to have **Foundry** installed. Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.

-   **Foundry (Forge & Anvil)**
    ```sh
    curl -L [https://foundry.paradigm.xyz](https://foundry.paradigm.xyz) | bash
    ```
    Then, in a new terminal session or after reloading your profile, run `foundryup` to get the latest version.
    ```sh
    foundryup
    ```

### Installation & Setup

1.  Clone the repository:
    ```sh
    git clone [https://github.com/tohidul3417/foundry-erc20.git](https://github.com/tohidul3417/foundry-erc20.git)
    cd foundry-erc20
    ```

2.  Build the project & install dependencies:
    ```sh
    forge build
    ```

## Usage

Foundry's `forge` is the primary tool for interacting with the contracts.

### Building

If you've already run the setup, you can re-compile the smart contracts at any time by running:

```sh
forge build
````

This will compile the contracts and place the artifacts in the `out/` directory, as specified in `foundry.toml`.

### Testing

This project comes with a comprehensive test suite. To run all tests:

```sh
forge test
```

For more detailed test output, you can use the `-vvv` flag for higher verbosity:

```sh
forge test -vvv
```

To generate a gas usage report for the contracts' functions:

```sh
forge snapshot
```

### Deployment

To deploy the contracts, you can use `forge script`. You will need to set up environment variables for your private key and an RPC URL.

1.  **Start a local node (optional, for local testing):**

    ```sh
    anvil
    ```

2.  **Deploy the contract:**
    Create a `.env` file in the root of the project and populate it with your `PRIVATE_KEY` and an `RPC_URL` (e.g., from Infura or Alchemy).

    ```
    PRIVATE_KEY=your_private_key_here
    RPC_URL=your_rpc_url_here
    ```

    Then, run the deployment script (assuming your script is named `DeployOurToken.s.sol` in the `script/` directory):

    ```sh
    forge script script/DeployOurToken.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
    ```

## Continuous Integration

This repository has a Continuous Integration (CI) pipeline configured in `.github/workflows/test.yml`. The workflow is triggered on every `push` and `pull_request` and performs the following checks:

1.  Installs Foundry.
2.  Runs the formatter (`forge fmt --check`).
3.  Builds the project (`forge build`).
4.  Runs the full test suite (`forge test -vvv`).

This ensures that the codebase remains consistent and that all tests pass before merging new changes.

## Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

## License

Distributed under the MIT License. See `LICENSE` for more information.
