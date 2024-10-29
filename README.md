# scaffold

This repository provides an automated tool for creating a standardized structure for any code repository. The tool ensures that the repository adheres to collaborative repository standards and includes features like the ability to be easily linked to a portfolio. It also provides language-specific configurations and creates CI/CD pipelines.

## Features

- **Standardization for Collaborative Repositories**: Automatically creates and initializes key files such as `LICENSE`, `CODE_OF_CONDUCT`, and more to ensure the repository adheres to industry best practices for collaboration.
- **Portfolio Integration**: Provides the option to self-append the repository to your developer portfolio.
- **Language Standards Support**: Currently supports C and C++, and follows GNU industry standards for these languages. More languages may be added in the future.
- **CI/CD Pipelines**: Sets up a pair of Continuous Integration/Continuous Deployment (CI/CD) pipelines to streamline development and deployment processes.

## How to Use

Follow the steps below to create a new repository with this tool:

1. Create a **new, empty repository** on GitHub.
2. In the local directory where you want to set up the new repository, execute the following command:
    ```bash
    bash <(curl -s https://raw.githubusercontent.com/israellopezdeveloper/scaffold/refs/heads/main/create_repo)
    ```
3. Follow the on-screen instructions to complete the setup process.

## Requirements

- An active GitHub account.
- Git and other standard development tools should be installed on your machine.

## Supported Languages

- **C**
- **C++**

Both languages follow the GNU industry standards.

- Docker
- Python

## Future Improvements

- Support for additional programming languages.
- Enhanced portfolio integration.
- Additional CI/CD configurations for more complex workflows.

