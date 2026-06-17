# Contributing

Thanks for considering contributing to **postgresql-docker**!

## How to contribute
1. **Open an issue**: Use the bug/feature templates to describe what you want to change.
2. **Fork and branch**: Create a feature branch.
3. **Implement**: Keep changes small and focused.
4. **Test**: Run the verification script locally (see below).
5. **Submit a PR**: Ensure CI is green.

## Development workflow
### Local prerequisites
- Docker + Docker Compose

### Run verification
```bash
./setup.sh
./verify-setup.sh
```

### Tear down (optional)
```bash
docker-compose down -v || docker compose down -v
```

## Code style and checks
- Keep shell scripts POSIX-friendly where possible.
- Prefer `set -euo pipefail` style for bash scripts.
- No secrets in commits.

CI will run:
- shellcheck
- integration verification via `verify-setup.sh`

## Pull request checklist
- [ ] Description of change and motivation
- [ ] Tests run and results included
- [ ] Documentation updated (README/customization instructions)
- [ ] No secrets committed

## License
By contributing, you agree that your contributions will be licensed under the project license.

