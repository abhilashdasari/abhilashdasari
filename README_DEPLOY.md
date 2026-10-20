Deployment instructions
-----------------------

1. Ensure your built site exists in `static_site/`. If you use Jekyll, run `jekyll build` to generate it.

2. Make the script executable:

```bash
chmod +x deploy.sh
```

3. Run full deploy (rsync to IITD + push to GitHub Pages branch `gh-pages`):

```bash
./deploy.sh
```

4. Run only IITD upload (skip GitHub push):

```bash
./deploy.sh --no-git
```

5. To change defaults, set environment variables, for example:

```bash
IITD_USER=bez208510 IITD_HOST=ssh1.iitd.ac.in GIT_BRANCH=gh-pages ./deploy.sh
```

Notes
- The script copies `static_site/` into `docs/` and commits it, then pushes to the remote branch `gh-pages`.
- Ensure you have push access to the remote branch and git is configured locally.
- The script will set recommended permissions on the IITD server after upload.
