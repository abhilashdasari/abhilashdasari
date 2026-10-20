#!/usr/bin/env bash
# Deploy the portfolio site.
#
# Two targets:
#   1. IITD server  : rsync static_site/  ->  ~/public_html/   (needs SSH credentials)
#   2. GitHub Pages : commit repo + push HEAD to the gh-pages branch
#                     (Pages serves the *repo root* of gh-pages via Jekyll)
#
# A failure on one target no longer prevents the other from running.
#
# Usage:
#   ./deploy.sh              # IITD upload + GitHub Pages push
#   ./deploy.sh --no-iitd    # GitHub Pages only (no SSH needed)
#   ./deploy.sh --no-git     # IITD upload only
#
# Overridable environment variables:
#   IITD_USER, IITD_HOST, GIT_REMOTE, GIT_BRANCH

# NOTE: intentionally no `-e`, so a failing IITD rsync does not abort the git deploy.
set -uo pipefail

IITD_USER="${IITD_USER:-bez208510}"
IITD_HOST="${IITD_HOST:-ssh1.iitd.ac.in}"
LOCAL_BUILD_DIR="${LOCAL_BUILD_DIR:-static_site}"
GIT_REMOTE="${GIT_REMOTE:-origin}"
GIT_BRANCH="${GIT_BRANCH:-gh-pages}"

DO_GIT=1
DO_IITD=1

case "${1:-}" in
  --no-git)  DO_GIT=0 ;;
  --no-iitd) DO_IITD=0 ;;
  "" ) : ;;
  -h|--help)
    sed -n '2,20p' "$0"; exit 0 ;;
  *) echo "Unknown option: $1" >&2; exit 2 ;;
esac

# ---------------------------------------------------------------------------
# Sync source assets into the build directory used for the IITD upload
# ---------------------------------------------------------------------------
if [[ -d "$LOCAL_BUILD_DIR" ]]; then
  if [[ -d static ]]; then
    rsync -a --delete static/ "$LOCAL_BUILD_DIR/static/"
  fi
  if [[ -d attached_assets ]]; then
    rsync -a --delete --exclude '*_old.pdf' attached_assets/ "$LOCAL_BUILD_DIR/attached_assets/"
  fi
fi

# ---------------------------------------------------------------------------
# 1. IITD upload
# ---------------------------------------------------------------------------
IITD_RC=0
if [[ "$DO_IITD" -eq 1 ]]; then
  if [[ ! -d "$LOCAL_BUILD_DIR" ]]; then
    echo "!! Build directory '$LOCAL_BUILD_DIR' not found; skipping IITD upload."
    IITD_RC=1
  else
    echo "==> Uploading '$LOCAL_BUILD_DIR' -> ${IITD_USER}@${IITD_HOST}:~/public_html/"
    if rsync -avz --delete "$LOCAL_BUILD_DIR"/ "${IITD_USER}@${IITD_HOST}:~/public_html/"; then
      ssh "${IITD_USER}@${IITD_HOST}" \
        "chmod o+x \$HOME; chmod uo+x \$HOME/public_html; \
         find \$HOME/public_html -type d -exec chmod 701 {} \; ; \
         find \$HOME/public_html -type f -exec chmod 644 {} \;" \
        || echo "!! Warning: could not set permissions on the server."
    else
      IITD_RC=1
      echo "!! IITD upload failed (check SSH key/password for ${IITD_USER}@${IITD_HOST})."
      echo "!! Continuing with the GitHub Pages deployment."
    fi
  fi
else
  echo "==> Skipping IITD upload (--no-iitd)."
fi

# ---------------------------------------------------------------------------
# 2. GitHub Pages push
# ---------------------------------------------------------------------------
if [[ "$DO_GIT" -eq 0 ]]; then
  echo "==> Skipping GitHub push (--no-git). Done."
  exit "$IITD_RC"
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "!! Not a git repository - cannot deploy to GitHub Pages."
  exit "$IITD_RC"
fi

echo "==> Committing site content for GitHub Pages (branch: $GIT_BRANCH)"
git add index.html _layouts templates blog static static_site attached_assets \
        main.py _config.yml deploy.sh README_DEPLOY.md DEPLOYMENT.md 2>/dev/null || true

if git diff --cached --quiet; then
  echo "==> No staged changes to publish."
else
  git commit -m "Deploy site: $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
fi

echo "==> Pushing to ${GIT_REMOTE} (${GIT_BRANCH})"
if git push "${GIT_REMOTE}" "HEAD:${GIT_BRANCH}"; then
  echo "==> Deployment complete."
else
  echo "!! GitHub push failed (check credentials/network)."
  exit 1
fi

exit "$IITD_RC"
