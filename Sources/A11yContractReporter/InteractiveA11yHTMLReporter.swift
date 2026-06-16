import Foundation
import A11yContractCore

public struct InteractiveA11yHTMLReporter {
    public static let outputFileName = "a11y-report.html"

    public init() {}

    public func renderHTML(
        report: A11yReport,
        language: InteractiveHTMLLanguage? = nil,
        reportPath: String? = nil,
        projectRoot: String? = nil,
        selectionOutputPath: String? = nil
    ) -> String {
        let payload = InteractiveHTMLPayload.build(
            from: report,
            language: language,
            reportPath: reportPath,
            projectRoot: projectRoot,
            selectionOutputPath: selectionOutputPath
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let jsonData = (try? encoder.encode(payload)) ?? Data("{}".utf8)
        let jsonString = String(data: jsonData, encoding: .utf8) ?? "{}"
        let lang = payload.defaultLanguage

        return """
        <!DOCTYPE html>
        <html lang="\(lang)">
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <title id="page-title">A11y Fix Picker</title>
          <style>
            :root {
              color-scheme: light dark;
              --bg: #f4f6fb;
              --card: #ffffff;
              --text: #1c2333;
              --muted: #5c667a;
              --border: #d8deea;
              --accent: #4f46e5;
              --success: #059669;
              --critical: #dc2626;
              --major: #ea580c;
              --minor: #ca8a04;
              --info: #2563eb;
            }
            @media (prefers-color-scheme: dark) {
              :root {
                --bg: #0f1420;
                --card: #171e2e;
                --text: #eef2ff;
                --muted: #9aa6bf;
                --border: #2a3550;
                --accent: #818cf8;
                --success: #34d399;
              }
            }
            * { box-sizing: border-box; }
            body {
              margin: 0;
              font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
              background: var(--bg);
              color: var(--text);
              line-height: 1.5;
            }
            header, main, footer { max-width: 960px; margin: 0 auto; padding: 1.25rem; }
            header { padding-top: 2rem; }
            .header-row { display: flex; flex-wrap: wrap; justify-content: space-between; align-items: flex-start; gap: 1rem; }
            h1 { margin: 0 0 0.25rem; font-size: 1.75rem; }
            .subtitle { color: var(--muted); margin: 0 0 1rem; }
            .lang-group {
              display: inline-flex;
              border: 1px solid var(--border);
              border-radius: 8px;
              overflow: hidden;
            }
            .lang-group button {
              border: 0;
              background: transparent;
              padding: 0.4rem 0.7rem;
              cursor: pointer;
              color: var(--text);
              font-weight: 600;
              font-size: 0.85rem;
            }
            .lang-group button.active { background: var(--accent); color: #fff; }
            .badges { display: flex; flex-wrap: wrap; gap: 0.5rem; margin-bottom: 1rem; }
            .badge {
              padding: 0.35rem 0.7rem;
              border-radius: 999px;
              font-size: 0.8rem;
              font-weight: 600;
              background: var(--card);
              border: 1px solid var(--border);
            }
            .badge.critical { color: var(--critical); }
            .badge.major { color: var(--major); }
            .badge.minor { color: var(--minor); }
            .badge.info { color: var(--info); }
            .toolbar {
              display: flex;
              flex-wrap: wrap;
              gap: 0.75rem;
              align-items: center;
              background: var(--card);
              border: 1px solid var(--border);
              border-radius: 12px;
              padding: 1rem;
              margin-bottom: 1rem;
            }
            .toolbar label { font-size: 0.9rem; color: var(--muted); }
            .style-group {
              display: inline-flex;
              border: 1px solid var(--border);
              border-radius: 8px;
              overflow: hidden;
            }
            .style-group button {
              border: 0;
              background: transparent;
              padding: 0.5rem 0.85rem;
              cursor: pointer;
              color: var(--text);
              font-weight: 600;
            }
            .style-group button.active { background: var(--accent); color: #fff; }
            .issue-card {
              background: var(--card);
              border: 1px solid var(--border);
              border-radius: 12px;
              padding: 1rem;
              margin-bottom: 0.75rem;
            }
            .issue-card.selected { border-color: var(--accent); box-shadow: 0 0 0 1px var(--accent); }
            .issue-card.fixed { border-color: var(--success); opacity: 0.85; }
            .issue-head { display: flex; gap: 0.75rem; align-items: flex-start; }
            .issue-head input { margin-top: 0.35rem; width: 1.1rem; height: 1.1rem; }
            .issue-title { font-weight: 700; margin: 0; }
            .issue-meta { color: var(--muted); font-size: 0.85rem; margin: 0.25rem 0 0.35rem; }
            .issue-location {
              font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
              font-size: 0.82rem;
              color: var(--accent);
              margin: 0 0 0.5rem;
              word-break: break-all;
            }
            .issue-location.missing { color: var(--muted); font-style: italic; font-family: inherit; }
            .file-group {
              background: var(--card);
              border: 1px solid var(--border);
              border-radius: 12px;
              margin-bottom: 1rem;
              overflow: hidden;
            }
            .file-group summary {
              cursor: pointer;
              list-style: none;
              display: flex;
              flex-wrap: wrap;
              align-items: center;
              gap: 0.5rem 1rem;
              padding: 0.85rem 1rem;
              font-weight: 700;
              border-bottom: 1px solid transparent;
            }
            .file-group[open] summary { border-bottom-color: var(--border); }
            .file-group summary::-webkit-details-marker { display: none; }
            .file-group-path {
              font-family: ui-monospace, SFMono-Regular, Menlo, monospace;
              font-size: 0.85rem;
              color: var(--accent);
              word-break: break-all;
              flex: 1 1 100%;
            }
            .file-group-count {
              font-size: 0.8rem;
              font-weight: 600;
              color: var(--muted);
            }
            .file-group-issues { padding: 0.75rem; }
            .file-group-issues .issue-card {
              margin-bottom: 0.75rem;
            }
            .file-group-issues .issue-card:last-child { margin-bottom: 0; }
            .unknown-location-hint {
              margin: 0 0 0.75rem;
              font-size: 0.88rem;
            }
            .severity {
              display: inline-block;
              font-size: 0.75rem;
              font-weight: 700;
              text-transform: uppercase;
              letter-spacing: 0.04em;
              margin-right: 0.5rem;
            }
            .severity.critical { color: var(--critical); }
            .severity.major { color: var(--major); }
            .severity.minor { color: var(--minor); }
            .severity.info { color: var(--info); }
            .fixed-badge {
              display: inline-block;
              font-size: 0.75rem;
              font-weight: 700;
              color: var(--success);
              margin-left: 0.5rem;
            }
            pre {
              background: #0b1020;
              color: #e2e8f0;
              border-radius: 8px;
              padding: 0.85rem;
              overflow-x: auto;
              font-size: 0.82rem;
              margin: 0.5rem 0 0;
            }
            .actions { display: flex; flex-wrap: wrap; gap: 0.5rem; margin-top: 0.5rem; }
            button.primary, button.secondary, button.success {
              border-radius: 8px;
              padding: 0.65rem 1rem;
              font-weight: 600;
              cursor: pointer;
              border: 1px solid var(--border);
            }
            button.primary { background: var(--accent); color: #fff; border-color: var(--accent); }
            button.success { background: var(--success); color: #fff; border-color: var(--success); }
            button.secondary { background: var(--card); color: var(--text); }
            .notice {
              background: var(--card);
              border: 1px dashed var(--border);
              border-radius: 10px;
              padding: 0.85rem 1rem;
              color: var(--muted);
              font-size: 0.9rem;
            }
            #export-preview { margin-top: 1rem; }
            .hidden { display: none; }
            .toast {
              position: fixed;
              bottom: 1rem;
              right: 1rem;
              background: #111827;
              color: #fff;
              padding: 0.75rem 1rem;
              border-radius: 8px;
              opacity: 0;
              transition: opacity 0.2s;
              pointer-events: none;
              max-width: 320px;
            }
            .toast.show { opacity: 1; }
          </style>
        </head>
        <body>
          <header>
            <div class="header-row">
              <div>
                <h1 id="title"></h1>
                <p class="subtitle" id="subtitle">\(escapeHTML(report.projectName))</p>
              </div>
              <div class="lang-group" id="lang-group" role="group" aria-label="Language"></div>
            </div>
            <div class="badges" id="summary-badges"></div>
            <p class="notice" id="notice"></p>
          </header>
          <main>
            <div class="toolbar">
              <div>
                <label id="style-label"></label><br>
                <div class="style-group" id="style-group" role="group"></div>
              </div>
              <div>
                <label><input type="checkbox" id="group-by-component" checked> <span id="group-label"></span></label>
              </div>
              <div class="actions">
                <button type="button" class="secondary" id="select-all"></button>
                <button type="button" class="secondary" id="select-none"></button>
                <button type="button" class="secondary" id="copy-fixes"></button>
                <button type="button" class="success" id="apply-fixes"></button>
              </div>
            </div>
            <section id="issue-list"></section>
            <section id="export-preview" class="hidden">
              <h2 id="preview-title"></h2>
              <pre id="export-code"></pre>
            </section>
          </main>
          <footer>
            <p class="notice" id="footer-notice"></p>
          </footer>
          <div class="toast" id="toast" role="status"></div>
          <script id="report-data" type="application/json">\(jsonString)</script>
          <script>
        \(embeddedJavaScript)
          </script>
        </body>
        </html>
        """
    }

    private func escapeHTML(_ value: String) -> String {
        value
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
    }

    private var embeddedJavaScript: String {
        """
        const data = JSON.parse(document.getElementById('report-data').textContent);
        let currentLang = data.defaultLanguage;
        let currentStyle = data.defaultStyle;
        let groupByComponent = true;

        function t(key) {
          return (data.i18n[currentLang] && data.i18n[currentLang][key]) || data.i18n.en[key] || key;
        }

        function severityLabel(severity) {
          return t('severity_' + severity) || severity;
        }

        function showToast(message) {
          const toast = document.getElementById('toast');
          toast.textContent = message;
          toast.classList.add('show');
          setTimeout(() => toast.classList.remove('show'), 2800);
        }

        function formatDate(iso) {
          const date = new Date(iso);
          const locale = currentLang === 'pt' ? 'pt-BR' : currentLang === 'es' ? 'es' : 'en';
          return date.toLocaleString(locale, { dateStyle: 'medium', timeStyle: 'short' });
        }

        function renderChrome() {
          document.documentElement.lang = currentLang;
          document.getElementById('page-title').textContent = t('title') + ' — ' + data.projectName;
          document.getElementById('title').textContent = t('title');
          document.getElementById('subtitle').textContent = data.projectName + ' · ' + formatDate(data.generatedAt);
          document.getElementById('notice').innerHTML = t('notice');
          document.getElementById('style-label').textContent = t('fix_style');
          document.getElementById('group-label').textContent = t('group_by_component');
          document.getElementById('select-all').textContent = t('select_all');
          document.getElementById('select-none').textContent = t('clear');
          document.getElementById('copy-fixes').textContent = t('copy_fixes');
          document.getElementById('apply-fixes').textContent = t('apply_fixes');
          document.getElementById('preview-title').textContent = t('export_preview');
          document.getElementById('footer-notice').textContent = t('footer');
          document.getElementById('issue-list').setAttribute('aria-label', t('issues_aria'));

          const langGroup = document.getElementById('lang-group');
          langGroup.innerHTML = data.languages.map(lang => `
            <button type="button" data-lang="${lang.id}" class="${lang.id === currentLang ? 'active' : ''}">${lang.label}</button>
          `).join('');
          langGroup.querySelectorAll('button').forEach(button => {
            button.addEventListener('click', () => {
              currentLang = button.dataset.lang;
              renderChrome();
              renderSummary();
              renderStyleButtons();
              renderIssues();
            });
          });
        }

        function renderSummary() {
          const container = document.getElementById('summary-badges');
          const summary = data.summary;
          const items = [
            ['critical', summary.critical],
            ['major', summary.major],
            ['minor', summary.minor],
            ['info', summary.info],
          ];
          container.innerHTML = items
            .filter(([, count]) => count > 0)
            .map(([severity, count]) => `<span class="badge ${severity}">${severityLabel(severity)}: ${count}</span>`)
            .join('');
        }

        function renderStyleButtons() {
          const group = document.getElementById('style-group');
          group.setAttribute('aria-label', t('fix_style'));
          group.innerHTML = data.styles.map(style => `
            <button type="button" data-style="${style.id}" class="${style.id === currentStyle ? 'active' : ''}">
              ${t('style_' + style.id) || style.label}
            </button>
          `).join('');
          group.querySelectorAll('button').forEach(button => {
            button.addEventListener('click', () => {
              currentStyle = button.dataset.style;
              renderStyleButtons();
              renderIssues();
            });
          });
        }

        function localizedMessage(item) {
          return item.localizedMessages[currentLang] || item.message;
        }

        function locationLabel(item) {
          if (item.location) return item.location;
          return t('location_unknown');
        }

        function fileGroupKey(item) {
          return item.filePath || '__unknown__';
        }

        function fileGroupLabel(filePath) {
          if (filePath === '__unknown__') return t('unknown_files_group');
          const parts = filePath.split('/');
          return parts[parts.length - 1] || filePath;
        }

        function lineLabel(item) {
          if (item.line) return t('line') + ' ' + item.line;
          if (item.location) return item.location;
          return t('location_unknown');
        }

        function groupItemsByFile(items) {
          const groups = new Map();
          items.forEach(item => {
            const key = fileGroupKey(item);
            if (!groups.has(key)) groups.set(key, []);
            groups.get(key).push(item);
          });
          return [...groups.entries()].sort((a, b) => {
            if (a[0] === '__unknown__') return 1;
            if (b[0] === '__unknown__') return -1;
            return a[0].localeCompare(b[0]);
          });
        }

        function renderIssueCard(item, options) {
          const showFullPath = options.showFullPath;
          const snippet = snippetFor(item);
          const checked = item.selected ? 'checked' : '';
          const selectedClass = item.selected ? 'selected' : '';
          const fixedClass = item.fixed ? 'fixed' : '';
          const fixedBadge = item.fixed ? `<span class="fixed-badge">${t('accepted')}</span>` : '';
          const title = localizedMessage(item);
          const locationClass = (showFullPath ? item.location : item.line) ? 'issue-location' : 'issue-location missing';
          const locationText = showFullPath ? locationLabel(item) : lineLabel(item);
          return `
            <article class="issue-card ${selectedClass} ${fixedClass}" data-id="${item.id}">
              <div class="issue-head">
                <input type="checkbox" id="issue-${item.id}" data-id="${item.id}" ${checked} aria-label="${t('select_issue')} ${title}">
                <div style="flex:1">
                  <p class="issue-title">
                    <span class="severity ${item.severity}">${severityLabel(item.severity)}</span>
                    ${title}${fixedBadge}
                  </p>
                  <p class="${locationClass}" title="${t('file')}">${locationText}</p>
                  <p class="issue-meta">${item.ruleId}${item.componentId ? ' · ' + item.componentId : ''}</p>
                  <pre><code>${escapeHtml(snippet)}</code></pre>
                </div>
              </div>
            </article>
          `;
        }

        function bindIssueCheckboxes() {
          document.getElementById('issue-list').querySelectorAll('input[type=checkbox]').forEach(input => {
            input.addEventListener('change', () => {
              const item = data.items.find(entry => entry.id === input.dataset.id);
              if (item) {
                item.selected = input.checked;
                if (!item.selected) item.fixed = false;
              }
              renderIssues();
            });
          });
        }

        function renderIssues() {
          const list = document.getElementById('issue-list');
          const fileGroups = groupItemsByFile(data.items);
          list.innerHTML = fileGroups.map(([filePath, items]) => {
            const label = fileGroupLabel(filePath);
            const countLabel = items.length === 1
              ? t('issues_count_one')
              : t('issues_count_many').replace('{count}', items.length);
            const pathLine = filePath === '__unknown__'
              ? `<span class="file-group-path">${t('unknown_files_group')}</span>`
              : `<span class="file-group-path" title="${escapeHtml(filePath)}">${escapeHtml(filePath)}</span>`;
            const unknownHint = filePath === '__unknown__'
              ? `<p class="notice unknown-location-hint">${t('unknown_location_hint')}</p>`
              : '';
            const cards = items.map(item => renderIssueCard(item, { showFullPath: filePath === '__unknown__' })).join('');
            return `
              <details class="file-group" open>
                <summary>
                  <span>${escapeHtml(label)}</span>
                  <span class="file-group-count">${countLabel}</span>
                  ${pathLine}
                </summary>
                <div class="file-group-issues">${unknownHint}${cards}</div>
              </details>
            `;
          }).join('');
          bindIssueCheckboxes();
        }

        function escapeHtml(value) {
          return value
            .replaceAll('&', '&amp;')
            .replaceAll('<', '&lt;')
            .replaceAll('>', '&gt;');
        }

        function snippetFor(item) {
          const snippets = groupByComponent ? item.groupedSnippets : item.snippets;
          return snippets[currentStyle] || item.suggestedFix || '';
        }

        function exportBlockForItem(item) {
          const title = localizedMessage(item);
          const header = [
            '// ' + title,
            item.location ? '// ' + t('file') + ': ' + item.location : '',
            item.componentId ? '// ' + t('component') + ': ' + item.componentId : '',
            '// ' + t('rules') + ': ' + item.ruleIds.join(', '),
            '',
          ].filter(Boolean).join('\\n');
          return header + snippetFor(item);
        }

        function exportBlocksForFile(items) {
          if (!groupByComponent) {
            return items.map(exportBlockForItem).join('\\n\\n');
          }

          const byComponent = new Map();
          items.forEach(item => {
            const key = item.componentId || item.id;
            if (!byComponent.has(key)) byComponent.set(key, []);
            byComponent.get(key).push(item);
          });

          return [...byComponent.values()].map(componentItems => {
            const primary = componentItems[0];
            const titles = componentItems.map(localizedMessage).join(' · ');
            const ruleIds = [...new Set(componentItems.flatMap(item => item.ruleIds))];
            const header = [
              '// ' + titles,
              primary.location ? '// ' + t('file') + ': ' + primary.location : '',
              primary.componentId ? '// ' + t('component') + ': ' + primary.componentId : '',
              '// ' + t('rules') + ': ' + ruleIds.join(', '),
              '',
            ].filter(Boolean).join('\\n');
            return header + snippetFor(primary);
          }).join('\\n\\n');
        }

        function buildExport() {
          const selected = data.items.filter(item => item.selected);
          if (selected.length === 0) return '';

          return groupItemsByFile(selected).map(([filePath, items]) => {
            const fileLabel = filePath === '__unknown__' ? t('unknown_files_group') : filePath;
            const countLabel = items.length === 1
              ? t('issues_count_one')
              : t('issues_count_many').replace('{count}', items.length);
            const fileHeader = [
              '// ' + '─'.repeat(48),
              '// ' + t('file') + ': ' + fileLabel,
              '// ' + countLabel,
              '// ' + '─'.repeat(48),
              '',
            ].join('\\n');
            return fileHeader + exportBlocksForFile(items);
          }).join('\\n\\n');
        }

        function buildSelectionManifest() {
          return {
            style: currentStyle,
            groupByComponent: groupByComponent,
            issues: data.items.map(item => ({
              id: item.id,
              ruleId: item.ruleId,
              componentId: item.componentId,
              severity: item.severity,
              selected: item.selected
            }))
          };
        }

        function downloadJSON(filename, obj) {
          const blob = new Blob([JSON.stringify(obj, null, 2)], { type: 'application/json' });
          const url = URL.createObjectURL(blob);
          const link = document.createElement('a');
          link.href = url;
          link.download = filename;
          link.click();
          URL.revokeObjectURL(url);
        }

        const HANDLE_DB = 'a11y-contract-kit';
        const HANDLE_STORE = 'handles';
        const OUTPUT_DIR_KEY = 'output-dir';

        function openHandleDB() {
          return new Promise((resolve, reject) => {
            const request = indexedDB.open(HANDLE_DB, 1);
            request.onerror = () => reject(request.error);
            request.onsuccess = () => resolve(request.result);
            request.onupgradeneeded = (event) => {
              event.target.result.createObjectStore(HANDLE_STORE);
            };
          });
        }

        async function getStoredDirectoryHandle() {
          if (!('indexedDB' in window)) return null;
          try {
            const db = await openHandleDB();
            return await new Promise((resolve, reject) => {
              const tx = db.transaction(HANDLE_STORE, 'readonly');
              const req = tx.objectStore(HANDLE_STORE).get(OUTPUT_DIR_KEY);
              req.onsuccess = () => resolve(req.result || null);
              req.onerror = () => reject(req.error);
            });
          } catch (_) {
            return null;
          }
        }

        async function storeDirectoryHandle(handle) {
          const db = await openHandleDB();
          await new Promise((resolve, reject) => {
            const tx = db.transaction(HANDLE_STORE, 'readwrite');
            tx.objectStore(HANDLE_STORE).put(handle, OUTPUT_DIR_KEY);
            tx.oncomplete = () => resolve();
            tx.onerror = () => reject(tx.error);
          });
        }

        async function writeManifestToDirectory(dirHandle, manifest) {
          const fileName = 'a11y-fix-selection.json';
          const fileHandle = await dirHandle.getFileHandle(fileName, { create: true });
          const writable = await fileHandle.createWritable();
          await writable.write(JSON.stringify(manifest, null, 2));
          await writable.close();
        }

        function selectionOutputLabel() {
          return data.selectionOutputPath || '.a11y/a11y-fix-selection.json';
        }

        async function saveSelectionToDisk(manifest) {
          if (window.showDirectoryPicker && window.isSecureContext) {
            try {
              let dirHandle = await getStoredDirectoryHandle();
              if (dirHandle) {
                const permission = await dirHandle.requestPermission({ mode: 'readwrite' });
                if (permission !== 'granted') dirHandle = null;
              }
              if (!dirHandle) {
                dirHandle = await window.showDirectoryPicker();
                await storeDirectoryHandle(dirHandle);
              }
              await writeManifestToDirectory(dirHandle, manifest);
              return 'disk';
            } catch (error) {
              if (error && error.name === 'AbortError') return 'cancelled';
            }
          }

          downloadJSON('a11y-fix-selection.json', manifest);
          return 'download';
        }

        function patchMakeTargetName() {
          if (data.reportPath && data.reportPath.includes('UIKitExample')) {
            return 'make uikit-patch';
          }
          return 'make patch-all';
        }

        async function copyText(text) {
          try {
            await navigator.clipboard.writeText(text);
            return true;
          } catch (error) {
            return false;
          }
        }

        document.getElementById('group-by-component').addEventListener('change', (event) => {
          groupByComponent = event.target.checked;
          renderIssues();
        });

        document.getElementById('select-all').addEventListener('click', () => {
          data.items.forEach(item => { item.selected = true; item.fixed = false; });
          renderIssues();
        });

        document.getElementById('select-none').addEventListener('click', () => {
          data.items.forEach(item => { item.selected = false; item.fixed = false; });
          renderIssues();
        });

        document.getElementById('copy-fixes').addEventListener('click', async () => {
          const exportText = buildExport();
          if (!exportText.trim()) {
            showToast(t('toast_select_one'));
            return;
          }
          document.getElementById('export-preview').classList.remove('hidden');
          document.getElementById('export-code').textContent = exportText;
          const copied = await copyText(exportText);
          showToast(copied ? t('toast_copied') : t('toast_copy_manual'));
        });

        document.getElementById('apply-fixes').addEventListener('click', async () => {
          const selected = data.items.filter(item => item.selected);
          if (selected.length === 0) {
            showToast(t('toast_select_one'));
            return;
          }

          const manifest = buildSelectionManifest();
          const exportText = buildExport();
          document.getElementById('export-preview').classList.remove('hidden');
          document.getElementById('export-code').textContent = exportText;

          const saved = await saveSelectionToDisk(manifest);
          if (saved === 'cancelled') return;

          selected.forEach(item => { item.fixed = true; });
          renderIssues();

          const command = patchMakeTargetName();
          const outputPath = selectionOutputLabel();
          if (saved === 'disk') {
            showToast(t('toast_selection_saved').replace('{command}', command));
          } else {
            showToast(
              t('toast_selection_downloaded')
                .replace('{path}', outputPath)
                .replace('{command}', command)
            );
          }
        });

        renderChrome();
        renderSummary();
        renderStyleButtons();
        renderIssues();
        """
    }
}

// MARK: - Language

public enum InteractiveHTMLLanguage: String, CaseIterable, Sendable {
    case en
    case pt
    case es

    public var htmlLang: String {
        switch self {
        case .en: return "en"
        case .pt: return "pt-BR"
        case .es: return "es"
        }
    }

    public var displayLabel: String {
        switch self {
        case .en: return "EN"
        case .pt: return "PT"
        case .es: return "ES"
        }
    }
}

// MARK: - Payload

private struct InteractiveHTMLPayload: Encodable {
    let projectName: String
    let generatedAt: Date
    let summary: A11ySummary
    let defaultLanguage: String
    let defaultStyle: String
    let reportPath: String?
    let projectRoot: String?
    let selectionOutputPath: String?
    let languages: [InteractiveHTMLLanguageOption]
    let i18n: [String: [String: String]]
    let styles: [InteractiveHTMLStyle]
    let items: [InteractiveHTMLItem]

    static func build(
        from report: A11yReport,
        language: InteractiveHTMLLanguage?,
        reportPath: String? = nil,
        projectRoot: String? = nil,
        selectionOutputPath: String? = nil
    ) -> InteractiveHTMLPayload {
        let generator = A11yFixSnippetGenerator()
        let lang = language ?? .pt

        let items = report.issues.sorted { lhs, rhs in
            if lhs.severity != rhs.severity { return lhs.severity > rhs.severity }
            return (lhs.componentId ?? "") < (rhs.componentId ?? "")
        }.map { issue -> InteractiveHTMLItem in
            let perStyleSnippets = A11yFixStyle.allCases.reduce(into: [String: String]()) { result, style in
                let selection = A11yFixSelection(style: style, issueIds: [issue.id], groupByComponent: false)
                let snippets = generator.generateSnippets(report: report, selection: selection)
                result[style.rawValue] = snippets.first?.code ?? issue.suggestedFix ?? ""
            }

            let groupedSnippets = A11yFixStyle.allCases.reduce(into: [String: String]()) { result, style in
                let selection = A11yFixSelection(style: style, issueIds: [issue.id], groupByComponent: true)
                let snippets = generator.generateSnippets(report: report, selection: selection)
                let fallback = style == .framework ? (issue.suggestedFix ?? "") : perStyleSnippets[style.rawValue]
                result[style.rawValue] = snippets.first?.code ?? fallback ?? ""
            }

            let defaultSelected = issue.componentId != nil && issue.componentId != "unknown_component"

            return InteractiveHTMLItem(
                id: issue.id,
                message: issue.message,
                ruleId: issue.ruleId,
                componentId: issue.componentId,
                filePath: issue.filePath,
                line: issue.line,
                location: locationText(filePath: issue.filePath, line: issue.line),
                severity: issue.severity.rawValue,
                suggestedFix: issue.suggestedFix,
                ruleIds: [issue.ruleId],
                selected: defaultSelected,
                fixed: false,
                localizedMessages: InteractiveHTMLTranslations.messages(for: issue),
                snippets: perStyleSnippets,
                groupedSnippets: groupedSnippets
            )
        }

        return InteractiveHTMLPayload(
            projectName: report.projectName,
            generatedAt: report.generatedAt,
            summary: report.summary,
            defaultLanguage: lang.rawValue,
            defaultStyle: defaultFixStyle(for: report),
            reportPath: reportPath,
            projectRoot: projectRoot,
            selectionOutputPath: selectionOutputPath,
            languages: InteractiveHTMLLanguage.allCases.map {
                InteractiveHTMLLanguageOption(id: $0.rawValue, label: $0.displayLabel)
            },
            i18n: InteractiveHTMLTranslations.uiStrings(),
            styles: A11yFixStyle.allCases.map {
                InteractiveHTMLStyle(id: $0.rawValue, label: $0.displayName)
            },
            items: items
        )
    }

    private static func defaultFixStyle(for report: A11yReport) -> String {
        if report.projectName == "UIKitExample" {
            return A11yFixStyle.uikit.rawValue
        }
        return A11yFixStyle.framework.rawValue
    }

    private static func locationText(filePath: String?, line: Int?) -> String? {
        guard let filePath else { return nil }
        guard let line else { return filePath }
        return "\(filePath):\(line)"
    }
}

private struct InteractiveHTMLLanguageOption: Encodable {
    let id: String
    let label: String
}

private struct InteractiveHTMLStyle: Encodable {
    let id: String
    let label: String
}

private struct InteractiveHTMLItem: Encodable {
    let id: String
    let message: String
    let ruleId: String
    let componentId: String?
    let filePath: String?
    let line: Int?
    let location: String?
    let severity: String
    let suggestedFix: String?
    let ruleIds: [String]
    var selected: Bool
    var fixed: Bool
    let localizedMessages: [String: String]
    let snippets: [String: String]
    let groupedSnippets: [String: String]
}

private enum InteractiveHTMLTranslations {
    static func uiStrings() -> [String: [String: String]] {
        [
            "en": [
                "title": "A11y Fix Picker",
                "notice": "Choose a fix style and issues, then click <strong>Save selection</strong> and pick your project <code>.a11y</code> folder. Run <strong>make patch-all</strong> in the terminal — the patch uses exactly what you selected.",
                "fix_style": "Fix style",
                "group_by_component": "Group by component",
                "select_all": "Select all",
                "clear": "Clear",
                "copy_fixes": "Copy selected",
                "apply_fixes": "Save selection",
                "export_preview": "Export preview",
                "footer": "Generated by A11yContractKit · Accessibility fix selector",
                "issues_aria": "Accessibility issues",
                "select_issue": "Select fix for",
                "accepted": "Accepted",
                "component": "Component",
                "file": "File",
                "line": "Line",
                "location_unknown": "File location unknown",
                "unknown_files_group": "No source file linked",
                "unknown_location_hint": "These findings come from views without <code>accessibilityIdentifier</code> (or source metadata) in your project. The scanner cannot map them to a Swift file. Add an identifier in code or register the source with <code>A11yContractRegistry.registerSource(...)</code>.",
                "issues_count_one": "1 issue",
                "issues_count_many": "{count} issues",
                "rules": "Rules",
                "severity_critical": "Critical",
                "severity_major": "Major",
                "severity_minor": "Minor",
                "severity_info": "Info",
                "style_uikit": "UIKit",
                "style_framework": "Framework",
                "style_swiftui": "SwiftUI",
                "toast_select_one": "Select at least one issue.",
                "toast_copied": "Copied selected fixes to clipboard.",
                "toast_copy_manual": "Preview ready — copy manually from the box below.",
                "toast_applied": "Fixes accepted: snippets copied and selection saved as a11y-fix-selection.json.",
                "toast_applied_manual": "Fixes accepted: a11y-fix-selection.json downloaded. Copy snippets from the preview.",
                "toast_selection_saved": "Selection saved to .a11y. Run {command} in the terminal.",
                "toast_selection_downloaded": "Saved to Downloads (file:// cannot write to the project). Move to {path}, then run {command}. Or use make uikit-open and save again.",
            ],
            "pt": [
                "title": "Seletor de correções A11y",
                "notice": "Escolha estilo e achados, clique em <strong>Salvar seleção</strong> e selecione a pasta <code>.a11y</code> do projeto. Depois rode <strong>make uikit-patch</strong> — o patch usa exatamente o que você selecionou.",
                "fix_style": "Estilo de correção",
                "group_by_component": "Agrupar por componente",
                "select_all": "Selecionar todos",
                "clear": "Limpar",
                "copy_fixes": "Copiar selecionados",
                "apply_fixes": "Salvar seleção",
                "export_preview": "Prévia da exportação",
                "footer": "Gerado por A11yContractKit · Seletor de correções de acessibilidade",
                "issues_aria": "Achados de acessibilidade",
                "select_issue": "Selecionar correção para",
                "accepted": "Aceito",
                "component": "Componente",
                "file": "Arquivo",
                "line": "Linha",
                "location_unknown": "Localização do arquivo desconhecida",
                "unknown_files_group": "Sem arquivo de origem",
                "unknown_location_hint": "Estes achados vêm de views sem <code>accessibilityIdentifier</code> (ou metadados de origem) no projeto. O scanner não consegue apontar o arquivo Swift. Adicione um identifier no código ou registre a origem com <code>A11yContractRegistry.registerSource(...)</code>.",
                "issues_count_one": "1 achado",
                "issues_count_many": "{count} achados",
                "rules": "Regras",
                "severity_critical": "Crítico",
                "severity_major": "Major",
                "severity_minor": "Menor",
                "severity_info": "Info",
                "style_uikit": "UIKit",
                "style_framework": "Framework",
                "style_swiftui": "SwiftUI",
                "toast_select_one": "Selecione pelo menos um achado.",
                "toast_copied": "Correções selecionadas copiadas para a área de transferência.",
                "toast_copy_manual": "Prévia pronta — copie manualmente na caixa abaixo.",
                "toast_applied": "Correções aceitas: snippets copiados e seleção salva em a11y-fix-selection.json.",
                "toast_applied_manual": "Correções aceitas: a11y-fix-selection.json baixado. Copie os snippets na prévia.",
                "toast_selection_saved": "Seleção gravada em .a11y. Rode {command} no terminal.",
                "toast_selection_downloaded": "Foi para Downloads (file:// não grava no projeto). Mova para {path} e rode {command}. Ou use make uikit-open e salve de novo.",
            ],
            "es": [
                "title": "Selector de correcciones A11y",
                "notice": "Elija estilo y hallazgos, pulse <strong>Guardar selección</strong> y elija la carpeta <code>.a11y</code> del proyecto. Luego ejecute <strong>make patch-all</strong> — el parche usa exactamente lo seleccionado.",
                "fix_style": "Estilo de corrección",
                "group_by_component": "Agrupar por componente",
                "select_all": "Seleccionar todos",
                "clear": "Limpiar",
                "copy_fixes": "Copiar seleccionados",
                "apply_fixes": "Guardar selección",
                "export_preview": "Vista previa de exportación",
                "footer": "Generado por A11yContractKit · Selector de correcciones de accesibilidad",
                "issues_aria": "Hallazgos de accesibilidad",
                "select_issue": "Seleccionar corrección para",
                "accepted": "Aceptado",
                "component": "Componente",
                "file": "Archivo",
                "line": "Línea",
                "location_unknown": "Ubicación del archivo desconocida",
                "unknown_files_group": "Sin archivo de origen",
                "unknown_location_hint": "Estos hallazgos provienen de vistas sin <code>accessibilityIdentifier</code> (o metadatos de origen) en el proyecto. El escáner no puede asociarlos a un archivo Swift. Añada un identifier en el código o registre el origen con <code>A11yContractRegistry.registerSource(...)</code>.",
                "issues_count_one": "1 hallazgo",
                "issues_count_many": "{count} hallazgos",
                "rules": "Reglas",
                "severity_critical": "Crítico",
                "severity_major": "Mayor",
                "severity_minor": "Menor",
                "severity_info": "Info",
                "style_uikit": "UIKit",
                "style_framework": "Framework",
                "style_swiftui": "SwiftUI",
                "toast_select_one": "Seleccione al menos un hallazgo.",
                "toast_copied": "Correcciones seleccionadas copiadas al portapapeles.",
                "toast_copy_manual": "Vista previa lista — copie manualmente en el cuadro inferior.",
                "toast_applied": "Correcciones aceptadas: snippets copiados y selección guardada en a11y-fix-selection.json.",
                "toast_applied_manual": "Correcciones aceptadas: a11y-fix-selection.json descargado. Copie los snippets en la vista previa.",
                "toast_selection_saved": "Selección guardada en .a11y. Ejecute {command} en la terminal.",
                "toast_selection_downloaded": "Guardado en Descargas (file:// no escribe en el proyecto). Mueva a {path} y ejecute {command}.",
            ],
        ]
    }

    static func messages(for issue: A11yIssue) -> [String: String] {
        let translations: [String: [String: String]] = [
            "ios-a11y-missing-label": [
                "en": "Interactive component without accessible label.",
                "pt": "Componente interativo sem rótulo acessível.",
                "es": "Componente interactivo sin etiqueta accesible.",
            ],
            "ios-a11y-missing-role": [
                "en": "Interactive component without appropriate accessibility role/trait.",
                "pt": "Componente interativo sem papel/trait de acessibilidade adequado.",
                "es": "Componente interactivo sin rol/trait de accesibilidad adecuado.",
            ],
            "ios-a11y-touch-target-hig": [
                "en": "Touch target below Apple HIG minimum (44×44 pt).",
                "pt": "Alvo de toque abaixo do mínimo Apple HIG (44×44 pt).",
                "es": "Objetivo táctil por debajo del mínimo Apple HIG (44×44 pt).",
            ],
            "ios-a11y-touch-target": [
                "en": "Touch target below WCAG minimum size.",
                "pt": "Alvo de toque abaixo do tamanho mínimo WCAG.",
                "es": "Objetivo táctil por debajo del tamaño mínimo WCAG.",
            ],
            "ios-a11y-low-contrast": [
                "en": "Insufficient color contrast.",
                "pt": "Contraste de cores insuficiente.",
                "es": "Contraste de color insuficiente.",
            ],
            "ios-a11y-fixed-font": [
                "en": "Fixed font size without Dynamic Type support.",
                "pt": "Fonte fixa sem suporte a Dynamic Type.",
                "es": "Tamaño de fuente fijo sin soporte Dynamic Type.",
            ],
        ]

        if let ruleMessages = translations[issue.ruleId] {
            return ruleMessages
        }
        return [
            "en": issue.message,
            "pt": issue.message,
            "es": issue.message,
        ]
    }
}

extension InteractiveA11yHTMLReporter: A11yReporter {
    public var outputFileName: String { Self.outputFileName }

    public func generate(report: A11yReport) throws -> String {
        renderHTML(report: report)
    }
}
