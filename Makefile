# A11yContractKit — atalhos de desenvolvimento
# Uso: make help

SHELL := /bin/bash
CLI := .build/release/a11y-contract
A11Y_OUT ?= .a11y
REPORT := $(A11Y_OUT)/a11y-report.json
HTML := $(A11Y_OUT)/a11y-report.html
STYLE ?= framework
UIKIT_STYLE ?= uikit
LANG ?= pt
FILTER ?= A11y
DESTINATION ?= platform=iOS Simulator,OS=18.6,name=iPhone 16

# UIKitExample paths (tutorial)
UIKIT_A11Y_OUT := Examples/UIKitExample/.a11y
UIKIT_REPORT := $(UIKIT_A11Y_OUT)/a11y-report.json
UIKIT_HTML := $(UIKIT_A11Y_OUT)/a11y-report.html

UIKIT_SELECTION := $(UIKIT_A11Y_OUT)/a11y-fix-selection.json
SELECTION := $(A11Y_OUT)/a11y-fix-selection.json

.PHONY: help build test clean \
	scan html open demo patch-all fix verify summary import-selection \
	uikit-scan uikit-html uikit-open uikit-demo uikit-patch uikit-verify uikit-reset uikit-import-selection

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
	@printf "  make uikit-patch   # usa a11y-fix-selection.json salvo no HTML\n"
	@printf "  make uikit-import-selection  # fallback: copia JSON de ~/Downloads\n"
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

open: ## Abre o HTML via localhost (permite salvar seleção em .a11y)
	@test -f "$(HTML)" || { echo "Rode: make html"; exit 1; }
	@$(MAKE) _serve-html PORT=8787 DIR="$(A11Y_OUT)" FILE=a11y-report.html

demo: scan html open ## Scan + HTML + abrir (só revisão)

patch-all: build ## Aplica correções (usa seleção do HTML se existir)
	@test -f "$(REPORT)" || { echo "Rode: make scan"; exit 1; }
	$(CLI) export-fixes patch \
		--report $(REPORT) \
		--project . \
		--style $(STYLE)

fix: scan patch-all verify ## Pipeline completo: auditar → corrigir tudo → re-auditar

verify: scan ## Re-audita e mostra resumo
	@$(MAKE) summary

summary: ## Resumo do último relatório (arquivos e achados)
	@test -f "$(REPORT)" || { echo "Rode: make scan"; exit 1; }
	@python3 -c "import json; from collections import Counter; r=json.load(open('$(REPORT)')); s=r['summary']; files=sorted({i['filePath'] for i in r['issues'] if i.get('filePath')}); print(f\"Achados: {s['totalIssues']} em {len(files)} arquivo(s)\"); print(f\"  crítico={s['critical']} major={s['major']} info={s['info']}\"); [print(f'  - {f} ({c})') for f,c in sorted(Counter(i['filePath'] for i in r['issues'] if i.get('filePath')).items())]"

import-selection: ## Copia a11y-fix-selection.json de ~/Downloads para .a11y
	@test -f "$(HOME)/Downloads/a11y-fix-selection.json" || { echo "Não há ~/Downloads/a11y-fix-selection.json"; exit 1; }
	@cp "$(HOME)/Downloads/a11y-fix-selection.json" "$(SELECTION)"
	@echo "Copiado para $(SELECTION) — rode: make patch-all"

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

uikit-open: ## [Example] Abre HTML via localhost
	@test -f "$(UIKIT_HTML)" || { echo "Rode: make uikit-html"; exit 1; }
	@$(MAKE) _serve-html PORT=8788 DIR="$(UIKIT_A11Y_OUT)" FILE=a11y-report.html

.PHONY: _serve-html
_serve-html:
	@lsof -ti:$(PORT) 2>/dev/null | xargs kill -9 2>/dev/null || true
	@cd "$(DIR)" && python3 -m http.server $(PORT) >/dev/null 2>&1 & \
		echo $$! > .http-server.pid; \
		sleep 0.8; \
		open "http://localhost:$(PORT)/$(FILE)"; \
		printf "HTML em http://localhost:$(PORT)/$(FILE)\n"; \
		printf "Salvar seleção → escolha esta pasta: %s\n" "$(DIR)"

uikit-demo: uikit-scan uikit-html uikit-open ## [Example] Scan + HTML + abrir

uikit-patch: build ## [Example] Patch (usa a11y-fix-selection.json do HTML)
	@test -f "$(UIKIT_REPORT)" || { echo "Rode: make uikit-scan"; exit 1; }
	$(CLI) export-fixes patch \
		--report $(UIKIT_REPORT) \
		--project . \
		--style $(UIKIT_STYLE)

uikit-import-selection: ## [Example] Copia seleção de ~/Downloads para UIKitExample/.a11y
	@test -f "$(HOME)/Downloads/a11y-fix-selection.json" || { echo "Não há ~/Downloads/a11y-fix-selection.json"; exit 1; }
	@cp "$(HOME)/Downloads/a11y-fix-selection.json" "$(UIKIT_SELECTION)"
	@echo "Copiado para $(UIKIT_SELECTION) — rode: make uikit-patch"

uikit-verify: uikit-scan ## [Example] Re-audita UIKitExample
	@python3 -c "import json; r=json.load(open('$(UIKIT_REPORT)')); s=r['summary']; print(f\"Achados: {s['totalIssues']} (crítico={s['critical']}, major={s['major']}, info={s['info']})\")"

uikit-reset: ## [Example] Restaura estado inicial e reabre HTML
	git checkout -- Examples/UIKitExample/Sources/UIKitExample/DeleteButtonProblemsViewController.swift
	$(MAKE) uikit-demo
