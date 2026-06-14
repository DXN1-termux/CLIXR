# Contributing to clixr

Thanks for your interest in contributing!

## Getting Started

1. Fork the repo and clone locally
2. Create a branch: `git checkout -b feat/my-feature`
3. Make your changes
4. Test on at least one platform (Termux, macOS, Linux, or WSL)
5. Push and open a Pull Request

## Guidelines

- Keep scripts POSIX-compatible where possible (use `#!/bin/sh` unless bash-specific features are needed)
- No unnecessary dependencies — if `curl` or `awk` can do it, don't pull in a package
- Each tool/plugin should work standalone
- Add a brief comment at the top of new scripts explaining what they do

## Code Style

- Use `snake_case` for function and variable names
- Quote your variables: `"$var"` not `$var`
- Use `set -euo pipefail` in bash scripts

## Reporting Issues

Open an issue with:
- Platform and shell version
- Steps to reproduce
- Expected vs actual behavior

## Pull Requests

- Keep PRs focused — one feature or fix per PR
- Reference any related issues
- Update the README if you add a new command or plugin
