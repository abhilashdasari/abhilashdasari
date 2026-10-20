#!/usr/bin/env bash
set -euo pipefail

# Deploy script: sync built static site to IITD server and push to GitHub Pages
# Defaults (override with environment variables):
IITD_USER="${IITD_USER:-bez208510}"
IITD_HOST="${IITD_HOST:-ssh1.iitd.ac.in}"
LOCAL_BUILD_DIR="static_site"
# If you cannot build locally, set GH_PAGES_URL to pull the built site from GitHub Pages
GH_PAGES_URL="${GH_PAGES_URL:-https://abhilashdasari.github.io/abhilashdasari/}"
DOCS_DIR="docs"
GIT_REMOTE="${GIT_REMOTE:-origin}"
GIT_BRANCH="${GIT_BRANCH:-gh-pages}"

function usage() {
  cat <<EOF
Usage: ./deploy.sh [--no-git]

Environment variables:
  IITD_USER  (default: ${IITD_USER})
  IITD_HOST  (default: ${IITD_HOST})
  GIT_REMOTE (default: ${GIT_REMOTE})
  GIT_BRANCH (default: ${GIT_BRANCH})

Options:
  --no-git    Skip GitHub Pages push (only rsync to IITD)
EOF
}

NO_GIT=0
if [[ ${1:-} == "--no-git" ]]; then
  NO_GIT=1
fi

# If the build dir doesn't exist, try fetching from GitHub Pages (fallback)
if [[ ! -d "$LOCAL_BUILD_DIR" ]]; then
  echo "Build directory '$LOCAL_BUILD_DIR' not found. Attempting to fetch built site from $GH_PAGES_URL"
  if command -v wget >/dev/null 2>&1; then
    TMPDIR="_static_site_tmp"
    rm -rf "$TMPDIR"
    mkdir -p "$TMPDIR"
    echo "Using wget to mirror $GH_PAGES_URL into $TMPDIR (this may take a while)..."
    wget --mirror --convert-links --adjust-extension --page-requisites --no-parent -e robots=off "$GH_PAGES_URL" -P "$TMPDIR"
    # Move fetched files into expected build dir
    # wget creates a directory like tmpdir/hostname/..., find index.html under it
    FETCHED_ROOT=$(find "$TMPDIR" -maxdepth 2 -type f -name 'index.html' -print -quit || true)
    if [[ -z "$FETCHED_ROOT" ]]; then
      echo "Failed to fetch site from $GH_PAGES_URL. Please build locally or provide the build in $LOCAL_BUILD_DIR."
      rm -rf "$TMPDIR"
      exit 1
    fi
    # derive fetched base dir
    FETCHED_BASE=$(dirname "$FETCHED_ROOT")
    rm -rf "$LOCAL_BUILD_DIR"
    mkdir -p "$LOCAL_BUILD_DIR"
    rsync -a "$FETCHED_BASE"/ "$LOCAL_BUILD_DIR/"
    rm -rf "$TMPDIR"
    echo "Fetched built site into $LOCAL_BUILD_DIR"
  else
    echo "wget not installed. To fetch from GitHub Pages automatically, install wget (brew install wget) or build locally with Jekyll."
    echo "If you prefer, run 'jekyll build -d $LOCAL_BUILD_DIR' locally then rerun this script."
    exit 1
  fi
fi

echo "Ensuring static assets are present in '$LOCAL_BUILD_DIR'..."
# Copy top-level static assets and attached_assets into the build directory if they exist
if [[ -d "static" ]]; then
  rsync -a --delete static/ "$LOCAL_BUILD_DIR/static/"
fi
if [[ -d "attached_assets" ]]; then
  rsync -a --delete attached_assets/ "$LOCAL_BUILD_DIR/attached_assets/"
fi

echo "Syncing '$LOCAL_BUILD_DIR' --> ${IITD_USER}@${IITD_HOST}:~/public_html/"
rsync -avz --delete "$LOCAL_BUILD_DIR"/ "${IITD_USER}@${IITD_HOST}:~/public_html/"

echo "Setting recommended permissions on server..."
ssh "${IITD_USER}@${IITD_HOST}" \
  "chmod o+x \$HOME; chmod uo+x \$HOME/public_html; find \$HOME/public_html -type d -exec chmod 701 {} \\; && find \$HOME/public_html -type f -exec chmod 644 {} \\;"

if [[ $NO_GIT -eq 1 ]]; then
  echo "Skipped GitHub push (--no-git). Done."
  exit 0
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Not a git repository — skipping GitHub Pages deployment."
  exit 0
fi

echo "Preparing '$DOCS_DIR' for GitHub Pages (push to branch: $GIT_BRANCH)..."
rm -rf "$DOCS_DIR"
mkdir -p "$DOCS_DIR"
cp -a "$LOCAL_BUILD_DIR"/. "$DOCS_DIR"/

git add "$DOCS_DIR"
if git diff --cached --quiet; then
  echo "No changes to publish to GitHub Pages."
else
  git commit -m "Deploy site: $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
fi

echo "Pushing to remote ${GIT_REMOTE} (branch ${GIT_BRANCH})..."
git push "${GIT_REMOTE}" "HEAD:${GIT_BRANCH}"

echo "Deployment complete."
