.PHONY: help check validate sync evals

help:
	@echo "make check     claude-setup check, the format validator, and the shared-reference drift check"
	@echo "make validate  Validate every skill against the Agent Skills specification"
	@echo "make sync      Copy shared/ into every skill that carries the file"
	@echo "make evals     Run the eval suite (costs tokens, takes minutes)"

# Needs the checker: uv tool install git+https://github.com/TechTechWizard/claude-setup-kit
check: validate
	@claude-setup check .
	@./scripts/sync-shared.sh --check

validate:
	@for s in */SKILL.md; do npx -y skills-ref validate "$$(dirname $$s)"; done

sync:
	@./scripts/sync-shared.sh

evals:
	@claude plugin eval . --runs 1 --trust-plugin --allow-tools Bash Edit Write --no-publish
