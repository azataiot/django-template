# Contributing to Django Template

First of all, thank you for considering contributing to Django Template! It's people like you that make Django Template
such a great tool.

## Code of Conduct

By participating in this project, you are expected to uphold
our [Code of Conduct](https://github.com/azataiot/django-template/blob/main/CODE_OF_CONDUCT.md).

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing list
of [issues](https://github.com/azataiot/django-template/issues) to see if the problem has already been reported. If it
hasn't, please create a new issue and provide as much information as possible to help the maintainers understand the
problem.

### Suggesting Enhancements

If you have an idea for a new feature or an enhancement to an existing one, please create a new issue in
the [issues](https://github.com/azataiot/django-template/issues) section, providing as much detail as possible about
your suggestion.

### Pull Requests

Please follow these steps to submit a pull request:

1. Fork the repository and create your branch from `main`.
2. If you've added code that should be tested, add tests.
3. If you've changed APIs, update the documentation.
4. Ensure the test suite passes.
5. Make sure your code lints.
6. Issue that pull request!

## Setting up Your Development Environment

1. Fork and clone the repository.
2. Install the required dependencies:
    ```
    poetry install
    ```
3. Make your changes in a new git branch:
    ```
    git checkout -b my-fix-branch main
    ```
4. Test your changes:
    ```
    make test
    ```
5. Commit your changes:
    ```
    git commit -a -m "Your detailed description of your changes."
    ```
6. Push your branch to GitHub:
    ```
    git push origin my-fix-branch
    ```

## Style Guide

Please follow the coding conventions defined in the [PEP 8](https://www.python.org/dev/peps/pep-0008/) style guide for
Python code (and we use black to enforce this).

## License

By contributing to Django Template, you agree that your contributions will be licensed under
its [MIT license](https://github.com/azataiot/django-template/blob/main/LICENSE).
