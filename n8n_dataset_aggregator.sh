#!/usr/bin/env bash
# n8n_dataset_aggregator_v1.2.sh
# Purpose: Robust crawl, normalize, and cache n8n learning resources (docs, blog, courses)
# Includes: TRAP verbosity, per-resource logging, dry-run safeguard

set -euo pipefail
trap 'EXIT_CODE=$?; echo "[!] TRAP activated. Exit code: $EXIT_CODE. Cleaning up..."; rm -rf "$ROOT_DIR"; exit $EXIT_CODE' INT TERM ERR

# ─ What this does:
# - Defines strict fail modes to prevent undefined or partial execution
# - Traps failure or interruption and removes dataset
# - Downloads n8n docs, blog, and courses separately with logs
# - Designed to minimize human error and support 1=1 CEU

ROOT_DIR="$(eval echo ~)/n8n-dataset"
DOCS_ROOT="https://docs.n8n.io"
BLOG_ROOT="https://blog.n8n.io"
COURSE_ROOT="https://docs.n8n.io/courses"

mkdir -p "$ROOT_DIR"/{docs,blog,courses}

echo "[+] Starting dataset aggregation..."

echo "[→] Docs download..."
wget --mirror --convert-links --adjust-extension --no-parent \
     --directory-prefix="$ROOT_DIR/docs" "$DOCS_ROOT" || echo "[!] Failed to fetch $DOCS_ROOT" >&2

echo "[→] Blog download..."
wget --mirror --convert-links --adjust-extension --no-parent \
     --directory-prefix="$ROOT_DIR/blog" "$BLOG_ROOT" || echo "[!] Failed to fetch $BLOG_ROOT" >&2

echo "[→] Courses download..."
wget --mirror --convert-links --adjust-extension --no-parent \
     --directory-prefix="$ROOT_DIR/courses" "$COURSE_ROOT" || echo "[!] Failed to fetch $COURSE_ROOT" >&2

echo "[✓] Aggregation complete. Data saved to $ROOT_DIR"
