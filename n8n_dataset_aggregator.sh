#!/usr/bin/env bash
# ============================================
# Dataset Aggregator for n8n Instructor Mode
# Author: Alejandro Gutierrez (with ChatGPT)
# Description: Builds a local structured dataset from
#              official n8n resources for AI training use.
# ============================================

set -euo pipefail

# ─── Setup Directories ─────────────────────────────────────────────
ROOT_DIR="${HOME}/n8n-dataset"
DOCS_DIR="${ROOT_DIR}/docs"
FORUM_DIR="${ROOT_DIR}/forum"
GITHUB_DIR="${ROOT_DIR}/github"

mkdir -p "$DOCS_DIR" "$FORUM_DIR" "$GITHUB_DIR"

# ─── Clone GitHub Repo ─────────────────────────────────────────────
echo "[+] Cloning n8n core GitHub repo..."
git clone --depth=1 https://github.com/n8n-io/n8n.git "$GITHUB_DIR/core" || echo "[!] Repo already exists, skipping."

# ─── Download Core Docs ────────────────────────────────────────────
echo "[+] Pulling documentation pages..."
declare -a DOC_PAGES=(
  "https://docs.n8n.io/workflows/"
  "https://docs.n8n.io/integrations/"
  "https://docs.n8n.io/hosting/"
  "https://docs.n8n.io/platform/"
)

for url in "${DOC_PAGES[@]}"; do
  wget --recursive --no-clobber --page-requisites --html-extension --convert-links --no-parent --directory-prefix="$DOCS_DIR" "$url"
done

# ─── Crawl Forum Topics ────────────────────────────────────────────
echo "[+] Scraping community.n8n.io for tagged topics..."
curl "https://community.n8n.io/tag/nodes.json" -s > "${FORUM_DIR}/nodes_tag.json" || echo "[!] Forum pull failed"

# ─── Completion ────────────────────────────────────────────────────
echo "[✓] Dataset aggregation complete."
echo "→ Review directory: $ROOT_DIR"
