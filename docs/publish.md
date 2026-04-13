# Publish Guide

## Goal

Publish this project from your personal GitHub account without mixing it with a company-managed account.

## Personal GitHub separation

Use a dedicated SSH key for your personal GitHub account.

Example `~/.ssh/config` entry:

```sshconfig
Host github-personal
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_personal
  IdentitiesOnly yes
```

In this repo, set your personal identity locally:

```bash
git config user.name "Your Name"
git config user.email "your-personal-email@example.com"
```

Then add the remote with your SSH alias:

```bash
git remote add origin git@github-personal:yourusername/ai-resume-analyzer.git
```

## GitHub Pages deployment

This repo includes a GitHub Actions workflow that builds and deploys Flutter Web to GitHub Pages.

After pushing to your personal repo:

1. Open repository `Settings`
2. Open `Pages`
3. Set `Source` to `GitHub Actions`
4. Push to `main` or run the workflow manually

The workflow auto-detects whether the repo is a project page or a user page and sets the Flutter `--base-href` accordingly.

## SPA fallback

The workflow copies `index.html` to `404.html` after build so refreshes on deep links are more resilient on static hosting.

## Suggested publish checklist

- Confirm the repo is public
- Add 3-5 screenshots or a short GIF to the README
- Verify the demo route works on GitHub Pages
- Verify upload, analysis, job match, AI Assist, and export flows in Chrome
- Add your personal repo URL to the README once published
