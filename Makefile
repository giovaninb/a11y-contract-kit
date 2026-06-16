# A11yContractKit — atalhos de desenvolvimento
# Uso: make help

SHELL := /bin/bash
CLI := .build/release/a11y-contract
A11Y_OUT ?= .a11y
REPORT := $(A11Y_OUT)/a11y-report.json
HTML := $(A11Y_OUT)/a11y-report.html
STYLE ?= framework
LANG ?= pt
FILTER ?= A11y
DESTINATION ?= platform=iOS Simulator,OS=18.6,name=iPhone 16

# UIKitExample paths (tutorial)
UIKIT_A11Y_OUT := Examples/UIKitExample/.a11y
UIKIT_REPORT := $(UIKIT_A11Y_OUT)/a11y-report.json
UIKIT_HTML := $(UIKIT_A11Y_OUT)/a11y-report.html

.PHONY: help build test clean \
	scan html open demo patch-all fix verify summary \
	uikit-scan uikit-html uikit-open uikit-demo uikit-patch uikit-verify uikit-reset

help: ## Lista os comandos disponíveis
	@printf "\nA11yContractKit — Makefile\n\n"
	@grep -E '^[a-zA-Z0-9_.-]+:.*##' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*## "}; {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'
	@printf "\nProjeto inteiro (59+ arquivos):\n"
	@printf "  make scan          # audita (demora — xcodebuild)\n"
	@printf "  make html          # relatório visual para revisar\n"
	@printf "  make patch-all     # corrige TODOS os achados com arquivo (rápido)\n"
	@printf "  make fix           # scan + patch-all + verify\n\n"
	@printf "Tutorial UIKitExample:\n"
	@printf "  make uikit-demo    # scan + HTML + abrir\n"
	@printf "  make uikit-patch   # patch-all no example\n"
	@printf "  make uikit-reset   # recomeçar exercício\n\n"
	@printf "Variáveis: A11Y_OUT=.a11y  FILTER=A11y  STYLE=framework  LANG=pt\n\n"

build: ## Compila a CLI em release
	swift build -c release

test: ## Roda os testes do pacote
	swift test

clean: ## Remove artefatos de build
	rm -rf .build

scan: build ## Audita o projeto (gera $(REPORT))
	$(CLI) scan \
		--project . \
		--filter $(FILTER) \
		--destination "$(DESTINATION)" \
		--output $(A11Y_OUT)

html: build ## Gera relatório HTML (revisão visual — opcional)
	@test -f "$(REPORT)" || { echo "Rode: make scan"; exit 1; }
	$(CLI) export-fixes view \
		--report $(REPORT) \
		--output $(A11Y_OUT) \
		--project . \
		--lang $(LANG)

open: ## Abre o HTML no navegador
	@test -f "$(HTML)" || { echo "Rode: make html"; exit 1; }
	open "$(HTML)"

demo: scan html open ## Scan + HTML + abrir (só revisão)

patch-all: build ## Aplica correções em TODOS os arquivos do relatório
	@test -f "$(REPORT)" || { echo "Rode: make scan"; exit 1; }
	$(CLI) export-fixes patch \
		--report $(REPORT) \
		--all \
		--project . \
		--style $(STYLE)

fix: scan patch-all verify ## Pipeline completo: auditar → corrigir tudo → re-auditar

verify: scan ## Re-audita e mostra resumo
	@$(MAKE) summary

summary: ## Resumo do último relatório (arquivos e achados)
	@test -f "$(REPORT)" || { echo "Rode: make scan"; exit 1; }
	@python3 -c "import json; from collections import Counter; r=json.load(open('$(REPORT)')); s=r['summary']; files=sorted({i['filePath'] for i in r['issues'] if i.get('filePath')}); print(f\"Achados: {s['totalIssues']} em {len(files)} arquivo(s)\"); print(f\"  crítico={s['critical']} major={s['major']} info={s['info']}\"); [print(f'  - {f} ({c})') for f,c in sorted(Counter(i['filePath'] for i in r['issues'] if i.get('filePath')).items())]"

uikit-scan: build ## [Example] Audita UIKitExample
	$(CLI) scan \
		--project . \
		--filter UIKitExample \
		--destination "$(DESTINATION)" \
		--output $(UIKIT_A11Y_OUT)

uikit-html: build ## [Example] Gera HTML do UIKitExample
	@test -f "$(UIKIT_REPORT)" || { echo "Rode: make uikit-scan"; exit 1; }
	$(CLI) export-fixes view \
		--report $(UIKIT_REPORT) \
		--output $(UIKIT_A11Y_OUT) \
		--project . \
		--lang $(LANG)

uikit-open: ## [Example] Abre HTML do UIKitExample
	@test -f "$(UIKIT_HTML)" || { echo "Rode: make uikit-html"; exit 1; }
	open "$(UIKIT_HTML)"

uikit-demo: uikit-scan uikit-html uikit-open ## [Example] Scan + HTML + abrir

uikit-patch: build ## [Example] Patch-all no UIKitExample
	@test -f "$(UIKIT_REPORT)" || { echo "Rode: make uikit-scan"; exit 1; }
	$(CLI) export-fixes patch \
		--report $(UIKIT_REPORT) \
		--all \
		--project . \
		--style $(STYLE)

uikit-verify: uikit-scan ## [Example] Re-audita UIKitExample
	@python3 -c "import json; r=json.load(open('$(UIKIT_REPORT)')); s=r['summary']; print(f\"Achados: {s['totalIssues']} (crítico={s['critical']}, major={s['major']}, info={s['info']})\")"

uikit-reset: ## [Example] Restaura estado inicial e reabre HTML
	git checkout -- Examples/UIKitExample/Sources/UIKitExample/DeleteButtonProblemsViewController.swift
	$(MAKE) uikit-demo
