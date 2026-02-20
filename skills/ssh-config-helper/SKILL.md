---
name: ssh-config-helper
description: Generate a complete SSH setup guide for connecting to private or personal GitHub repositories when the user provides machine name and target repo/account. Use for multi-account GitHub setups, per-repo SSH host aliases, key generation, remote URL setup, and quick verification commands.
---

# ssh-config-helper

Create a fast, copy/paste-ready setup when the user gives:
- machine name
- GitHub account/owner
- target repository

## Input contract (ask once if missing)
Collect these values:
1. `machine_name` (e.g. `macbook-tobi`)
2. `github_owner` (e.g. `HerbyHam`)
3. `repo_name` (e.g. `claude-skills`)
4. `host_alias` (default: `github-<owner-lower>`)
5. Optional commit identity:
   - `git_user_name`
   - `git_user_email`

If commit identity is missing, provide placeholders and note they are per-repo.

## Output format (strict)
Return exactly these sections in order:

1. **Key generation**
2. **SSH config entry**
3. **Add key to GitHub**
4. **Test connection**
5. **Set repo remote**
6. **Set per-repo git identity**
7. **One-shot verify checklist**

Always provide shell commands fully populated with user values.

## Command template

### 1) Key generation
```bash
ssh-keygen -t ed25519 -C "<github_owner>-<machine_name>" -f ~/.ssh/id_ed25519_<owner_lower>_<machine_slug>
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519_<owner_lower>_<machine_slug>
```

### 2) SSH config entry
Append to `~/.ssh/config`:

```sshconfig
Host <host_alias>
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_<owner_lower>_<machine_slug>
  IdentitiesOnly yes
```

### 3) Add key to GitHub
```bash
cat ~/.ssh/id_ed25519_<owner_lower>_<machine_slug>.pub
```
Then: GitHub -> Settings -> SSH and GPG keys -> New SSH key.

### 4) Test connection
```bash
ssh -T git@<host_alias>
```
Expected: `Hi <github_owner>! You've successfully authenticated...`

### 5) Set repo remote
Inside local repo:
```bash
git remote set-url origin git@<host_alias>:<github_owner>/<repo_name>.git
git remote -v
```

### 6) Set per-repo git identity
```bash
git config user.name "<git_user_name>"
git config user.email "<git_user_email>"
```

### 7) One-shot verify checklist
Use this compact sequence:
```bash
ssh -T git@<host_alias>
git remote -v
git config user.name
git config user.email
git push --dry-run
```

## Multi-account guardrail
When multiple GitHub accounts are present:
- never use plain `github.com` host in remote URLs for account-specific repos
- always use account-specific aliases (`github-herby`, `github-rogue`, etc.)
- set identity per repo (`git config`, not global)

## Example mapping
Given:
- machine_name: `macbook-air`
- github_owner: `HerbyHam`
- repo_name: `rogue_robots_bp`
- host_alias: `github-herby`

Use:
- key file: `~/.ssh/id_ed25519_herbyham_macbook_air`
- remote: `git@github-herby:HerbyHam/rogue_robots_bp.git`
