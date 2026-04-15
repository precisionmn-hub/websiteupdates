# Installing Agent Skills Plugins

This guide covers installing two Claude Code skill packages into this repo:

1. [**Marketing Skills**](https://github.com/coreyhaines31/marketingskills) — 35 skills for CRO, SEO, content, paid ads, email, and sales enablement.
2. [**Bricks Builder Skills**](https://github.com/wpgaurav/bricks-skills) — 15 skills for generating Bricks Builder layouts, custom elements, templates, hooks, queries, forms, popups, and more.

Both install into the same `.agents/skills/` tree (with `.claude/skills/` symlinks) so Claude Code auto-discovers every skill.

---

## Marketing Skills plugin

The Marketing Skills plugin is a collection of Claude Code "skills" — markdown files that give AI agents specialized knowledge and workflows for marketing tasks (conversion optimization, SEO, content, paid advertising, sales enablement, and more).

## Prerequisites

- [Claude Code](https://claude.com/claude-code) installed and configured, **or** another agent that supports the Agent Skills specification (Cursor, Windsurf, OpenAI Codex, etc.).
- `git` available on your PATH.
- Node.js / `npx` (only required for the CLI-based install methods).

## Option 1 — Install as a Claude Code plugin (recommended)

From inside an active Claude Code session, run the following two slash commands:

```
/plugin marketplace add coreyhaines31/marketingskills
/plugin install marketing-skills
```

The first command registers the GitHub repository as a plugin marketplace. The second command installs the `marketing-skills` plugin from that marketplace into your Claude Code environment. After it finishes, the skills become available to Claude automatically.

## Option 2 — CLI install with `npx skills`

If you prefer to install the skills into a project directory (so they ship with your repo), run:

```bash
# Install every skill in the collection
npx skills add coreyhaines31/marketingskills

# Install only specific skills
npx skills add coreyhaines31/marketingskills --skill page-cro copywriting

# List available skills before installing
npx skills add coreyhaines31/marketingskills --list
```

Skills are written to the `.agents/skills/` directory at the root of the current project.

## Option 3 — Git submodule

To track the plugin as a dependency of your own repository and keep it pinned to a specific commit:

```bash
git submodule add https://github.com/coreyhaines31/marketingskills.git .agents/marketingskills
git commit -m "Add marketing skills submodule"
```

Update later with `git submodule update --remote`.

## Option 4 — Clone & copy

For a one-off, read-only copy:

```bash
git clone https://github.com/coreyhaines31/marketingskills.git
mkdir -p .agents/skills
cp -r marketingskills/skills/* .agents/skills/
```

## Option 5 — Fork & customize

If you plan to edit the skills, fork `coreyhaines31/marketingskills` on GitHub, then use Option 2 or 3 against your fork's URL. This keeps your customizations isolated from upstream updates.

## Option 6 — SkillKit (multi-agent)

`skillkit` installs the same skills for agents beyond Claude Code (Cursor, Windsurf, Codex, etc.):

```bash
npx skillkit install coreyhaines31/marketingskills
npx skillkit install coreyhaines31/marketingskills --skill page-cro copywriting
```

## Verifying the installation

- **Claude Code plugin install:** run `/plugin list` — `marketing-skills` should appear as installed.
- **Filesystem installs:** confirm that the skill files live under `.agents/skills/` (newer versions) or `.claude/skills/` (legacy). If you are upgrading from an older version, move any existing skill files from `.claude/` to `.agents/`.
- Start a new Claude Code session and ask Claude to use a marketing skill (for example, "use the page-cro skill to review this landing page") to confirm it is loaded.

## Troubleshooting

- **`/plugin` command not recognized:** update Claude Code to the latest version — plugin marketplaces require a recent release.
- **Skills not picked up after a filesystem install:** restart your agent session so it rescans the `.agents/` directory.
- **`npx skills` command not found:** ensure Node.js is installed and reachable; `npx` ships with Node.js 8.2+.

## Bricks Builder Skills (second plugin)

The [Bricks Builder Skills repo](https://github.com/wpgaurav/bricks-skills) by `wpgaurav` is distributed as plain markdown reference docs rather than as an Agent Skills package, so `npx skills add` cannot pull it directly. We vendor it manually into the same `.agents/skills/` tree so Claude Code can auto-load the skills.

Source files → installed skill names:

| Upstream file | Skill name |
|---|---|
| `bricks-layouts.md` | `bricks-layouts` |
| `bricks-elements.md` | `bricks-elements` |
| `bricks-templates.md` | `bricks-templates` |
| `bricks-hooks.md` | `bricks-hooks` |
| `bricks-query.md` | `bricks-query` |
| `bricks-query-filters.md` | `bricks-query-filters` |
| `bricks-forms.md` | `bricks-forms` |
| `bricks-popups.md` | `bricks-popups` |
| `bricks-interactions.md` | `bricks-interactions` |
| `bricks-conditions.md` | `bricks-conditions` |
| `bricks-dynamic-data.md` | `bricks-dynamic-data` |
| `bricks-assets.md` | `bricks-assets` |
| `bricks-builder-permissions.md` | `bricks-builder-permissions` |
| `bricks-woocommerce.md` | `bricks-woocommerce` |
| `core-framework-classes.md` + `core-framework.css` | `bricks-core-framework` |

Each SKILL.md is generated by prepending a YAML frontmatter block (`name`, `description` with trigger phrases, `metadata.source`, `metadata.source_commit`) to the upstream markdown. Symlinks under `.claude/skills/` mirror the marketing-skills pattern.

### Reinstalling / updating the Bricks skills

```bash
git clone https://github.com/wpgaurav/bricks-skills.git /tmp/bricks-skills
bash /tmp/bricks-skills/generate.sh   # script committed to this branch only during initial install
```

If the upstream repo gains or renames files, re-run the install and update the table above. The `metadata.source_commit` inside each SKILL.md records the exact upstream commit at install time.

## References

- Marketing Skills repo: https://github.com/coreyhaines31/marketingskills
- Bricks Builder Skills repo: https://github.com/wpgaurav/bricks-skills
- Claude Code documentation: https://docs.claude.com/claude-code
