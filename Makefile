# A11yContractKit — atalhos de desenvolvimento
# Uso: make help

SHELL := /bin/bash
CLI := .build/release/a11y-contract
A11Y_OUT := Examples/UIKitExample/.a11y
REPORT := $(A11Y_OUT)/a11y-report.json
HTML := $(A11Y_OUT)/a11y-report.html
STYLE ?= framework
LANG ?= pt
DESTINATION ?= platform=iOS Simulator,OS=18.6,name=iPhone 16

.PHONY: help build test clean \
	uikit-scan uikit-html uikit-open uikit-demo uikit-patch uikit-verify uikit-reset

help: ## Lista os comandos disponíveis
	@printf "\nA11yContractKit — Makefile\n\n"
	@grep -E '^[a-zA-Z0-9_.-]+:.*##' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*## "}; {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'
	@printf "\nExemplo rápido (UIKitExample):\n"
	@printf "  make uikit-demo     # build + scan + HTML + abrir no navegador\n"
	@printf "  make uikit-patch    # aplicar correções no .swift (estilo: %s)\n" "$(STYLE)"
	@printf "  make uikit-verify   # re-scan para ver se melhorou\n"
	@printf "  make uikit-reset    # volta o example ao estado inicial\n\n"
	@printf "Variáveis: STYLE=uikit|framework|swiftui  LANG=pt|en|es  DESTINATION='...'\n\n"

build: ## Compila a CLI em release
	swift build -c release

test: ## Roda os testes do pacote
	swift test

clean: ## Remove artefatos de build
	rm -rf .build

uikit-scan: build ## Audita o UIKitExample (gera a11y-report.json)
	$(CLI) scan \
		--project . \
		--filter UIKitExample \
		--destination "$(DESTINATION)" \
		--output $(A11Y_OUT)

uikit-html: build ## Gera o relatório HTML interativo
	@test -f "$(REPORT)" || { echo "Rode: make uikit-scan"; exit 1; }
	$(CLI) export-fixes view \
		--report $(REPORT) \
		--output $(A11Y_OUT) \
		--project . \
		--lang $(LANG)

uikit-open: ## Abre o HTML no navegador padrão
	@test -f "$(HTML)" || { echo "Rode: make uikit-html"; exit 1; }
	open "$(HTML)"

uikit-demo: uikit-scan uikit-html uikit-open ## Fluxo completo: scan → HTML → abrir

uikit-patch: build ## Aplica correções nos arquivos Swift (requer scan prévio)
	@test -f "$(REPORT)" || { echo "Rode: make uikit-scan"; exit 1; }
	@ISSUE_IDS=$$(python3 -c "import json; r=json.load(open('$(REPORT)')); print(','.join(i['id'] for i in r['issues'] if i.get('filePath')))"); \
	if [ -z "$$ISSUE_IDS" ]; then echo "Nenhum achado com arquivo de origem no relatório."; exit 1; fi; \
	$(CLI) export-fixes patch \
		--report $(REPORT) \
		--issues "$$ISSUE_IDS" \
		--project . \
		--style $(STYLE) \
		--open

uikit-verify: uikit-scan ## Re-audita e mostra resumo dos achados
	@python3 -c "import json; r=json.load(open('$(REPORT)')); s=r['summary']; print(f\"Achados: {s['totalIssues']} (crítico={s['critical']}, major={s['major']}, info={s['info']})\"); [print(f\"  - {i['componentId']}: {i.get('filePath')}:{i.get('line')}\") for i in r['issues']]"

uikit-reset: ## Restaura o example problemático e regera relatório
	git checkout -- Examples/UIKitExample/Sources/UIKitExample/DeleteButtonProblemsViewController.swift
	$(MAKE) uikit-demo
