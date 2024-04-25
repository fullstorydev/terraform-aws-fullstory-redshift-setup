# Welcome to Fullstory's Terraform contributing guide

Thanks for your time in contributing to this project! Please read all the information below to properly
contribute with our workflow.

## Issues

- Make sure you test against the latest tagged version with the expected terraform version
- Re-run the `init-repo.sh` to ensure your local is the expected setup
- Provide a reprducible (or show) case. If you cannot accurately show the issue, it'll be difficult to fix

## Setting up your workspace for dev

- Run the `init-repo.sh` to ensure your dev workspace is correct with all tooling

## Generating the README

You can generate the README with HCL examples using `terraform-docs`. You can install `terraform-docs` by following [this guide](https://terraform-docs.io/user-guide/installation/).

```
terraform-docs markdown .
```

## Commit Messages

This repo follows the [conventional commit](https://www.conventionalcommits.org/en/v1.0.0/#summary) message style. This is strictly enforced by git hooks (which should have been activated by the `init-repo.sh`) and by CI. A small example is below:

```
feat: allow customization of cloudfront headers that are forwarded to origin
```

## Opening a PR

Thanks for contributing! When you're ready to open a PR, you will need to fork this repo, push changes to your fork, and then open a PR here. Note: See [Working with forks](https://help.github.com/articles/working-with-forks/) for a better way to use git push.
