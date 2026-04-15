#!/usr/bin/env bash
# Convert each bricks-skills markdown doc into a Claude Code skill with YAML
# frontmatter, installed into the current project at .agents/skills/ with a
# matching symlink under .claude/skills/.
#
# Usage: run from the repo root:
#     bash tools/install-bricks-skills.sh
set -euo pipefail

UPSTREAM_REPO="https://github.com/wpgaurav/bricks-skills.git"
REPO_ROOT="$(git rev-parse --show-toplevel)"
SRC="${BRICKS_SKILLS_SRC:-$(mktemp -d)/bricks-skills}"
DEST_AGENTS="$REPO_ROOT/.agents/skills"
DEST_CLAUDE="$REPO_ROOT/.claude/skills"

if [ ! -d "$SRC/.git" ]; then
  git clone --depth 1 "$UPSTREAM_REPO" "$SRC"
fi
UPSTREAM_COMMIT="$(git -C "$SRC" rev-parse HEAD)"

mkdir -p "$DEST_AGENTS" "$DEST_CLAUDE"

# name|source_file|description
# Descriptions include trigger keywords so Claude Code auto-picks the skill.
ENTRIES=(
'bricks-layouts|bricks-layouts.md|When the user wants to build, paste, or scaffold a Bricks Builder layout, section, or page — hero, grid, cards, pricing table, features, CTA, testimonials, footer, or any landing page structure. Also use when the user mentions "Bricks layout," "Bricks section," "Bricks JSON," "paste into Bricks," "bricksCopiedElements," "Bricks copy/paste format," "responsive grid in Bricks," "mobile-first Bricks section," or shares a design they want rebuilt in Bricks Builder. Generate JSON in the bricksCopiedElements format with unique 6-char element IDs, Core Framework utility classes, and responsive breakpoint suffixes.'
'bricks-elements|bricks-elements.md|When the user wants to build a custom element for Bricks Builder — a PHP class with controls, control groups, and render logic. Also use when the user mentions "custom Bricks element," "register a Bricks element," "new element for Bricks," "add a control to a Bricks element," "Bricks element PHP class," "element.php," "set_controls," "set_control_groups," "Bricks\\Element," "custom widget for Bricks," or asks for a reusable element like a team card, pricing tier, feature box, or counter. Produce PHP that extends Bricks\\Element with proper controls, tag, category, and render() output.'
'bricks-templates|bricks-templates.md|When the user wants to create, import, export, or manage Bricks Builder templates — headers, footers, single post, archives, popups, sections, or full page templates. Also use when the user mentions "Bricks template," "header template," "footer template," "template conditions," "assign template site-wide," "Bricks template type," "bricks_template post type," or wants to generate a Bricks template JSON for import via the Templates system. Generate the full template JSON with id, name, title, type, elements, and global_classes.'
'bricks-hooks|bricks-hooks.md|When the user wants to customize Bricks Builder via WordPress filters or actions. Also use when the user mentions "Bricks filter," "Bricks action," "Bricks hook," "add_filter bricks/," "do_action bricks/," "bricks/elements/*/controls," "bricks/frontend/render_element," "bricks/builder/i18n," "modify a Bricks element," "inject CSS into Bricks," "intercept Bricks output," or asks how to change default behavior of a Bricks element, query, template, or builder screen. Reference the exact hook name and provide a functions.php snippet.'
'bricks-query|bricks-query.md|When the user wants to configure, customize, or extend a Bricks Builder query loop — posts, terms, users, or custom data. Also use when the user mentions "Bricks query loop," "Bricks query," "loop posts in Bricks," "custom query in Bricks," "bricks/posts/query_vars," "Query::is_looping," "loop object," "loop builder," "repeater in Bricks," or wants to filter, sort, or paginate a loop. Produce working PHP filters or JSON settings that drive the loop.'
'bricks-query-filters|bricks-query-filters.md|When the user wants to build faceted/filtered search with Bricks Builder — search, checkbox, radio, range, select, sort, active filters, or pagination tied to a query loop. Also use when the user mentions "Bricks query filter," "filter element," "facet filter," "AJAX filter," "Bricks indexer," "filter-search," "filter-checkbox," "filter-range," "bricks_filter_index," or wants to wire up real-time filtering on a grid of posts, products, or terms.'
'bricks-forms|bricks-forms.md|When the user wants to build, customize, or extend a Bricks Builder form — contact forms, newsletter signups, multi-step forms, custom submit actions, or third-party integrations. Also use when the user mentions "Bricks form," "form element in Bricks," "custom form action," "bricks/form/custom_action," "form validation in Bricks," "redirect after form submit," "Bricks email integration," "Mailchimp in Bricks," or wants to handle form data server-side via PHP hooks.'
'bricks-popups|bricks-popups.md|When the user wants to create or customize a popup in Bricks Builder — modal, lightbox, exit-intent, cookie notice, newsletter signup, or announcement bar. Also use when the user mentions "Bricks popup," "popup template," "popup trigger," "exit intent popup," "open popup on click," "Bricks modal," "bricks-popup-," "popup AJAX load," or wants popup conditions, triggers (time, scroll, click, exit), or a multi-popup flow.'
'bricks-interactions|bricks-interactions.md|When the user wants to add animations, transitions, or interactive behaviors to Bricks Builder elements — on click, hover, scroll, or mouse move. Also use when the user mentions "Bricks interaction," "Bricks animation," "scroll animation," "hover effect in Bricks," "toggle class on click," "bricks interactions JSON," "show/hide on scroll," "parallax in Bricks," "mouse-based interaction," or wants no-code animations wired up via the Interactions panel.'
'bricks-conditions|bricks-conditions.md|When the user wants to conditionally show or hide a Bricks element or template. Also use when the user mentions "Bricks conditions," "conditional display," "show if logged in," "hide for role," "conditional visibility in Bricks," "dynamic data condition," "post meta condition," "ACF condition in Bricks," "device condition," or wants to build compound AND/OR logic for element visibility.'
'bricks-dynamic-data|bricks-dynamic-data.md|When the user wants to use or extend Bricks Builder dynamic data tags — post fields, ACF, meta, user, site, or custom providers. Also use when the user mentions "Bricks dynamic data," "dynamic data tag," "{post_title}," "{acf:field}," "custom dynamic data provider," "bricks/dynamic_data/register_providers," "bricks_render_dynamic_data," or wants to register a new {custom_tag} that outputs data from a plugin, API, or external source.'
'bricks-assets|bricks-assets.md|When the user wants to understand or customize how Bricks Builder generates and loads CSS/JS assets. Also use when the user mentions "Bricks assets," "regenerate CSS in Bricks," "wp bricks regenerate_assets," "inline vs external CSS," "Bricks asset loading mode," "Bricks performance," "unload Bricks CSS," "bricks/assets/load_css_in_footer," or is optimizing page speed for a Bricks-built site.'
'bricks-builder-permissions|bricks-builder-permissions.md|When the user wants to control who can access or edit in the Bricks Builder. Also use when the user mentions "Bricks permissions," "builder access," "restrict Bricks to admins," "builder capabilities," "custom role for Bricks," "bricks_edit_content capability," "lock Bricks elements from client," or wants per-role control over which Bricks features are editable.'
'bricks-woocommerce|bricks-woocommerce.md|When the user wants to build or customize WooCommerce pages, templates, or elements with Bricks Builder — shop, single product, cart, checkout, account, or mini cart. Also use when the user mentions "Bricks WooCommerce," "WooCommerce template in Bricks," "single product template," "Bricks shop page," "product loop in Bricks," "Bricks cart," "Bricks checkout," "add to cart element," or wants dynamic data tags for WooCommerce product fields.'
'bricks-core-framework|core-framework-classes.md|When the user is styling a Bricks Builder layout and needs utility CSS classes — spacing, typography, grid, flex, colors, shadows, borders, or responsive modifiers. Also use when the user mentions "Core Framework," "core-framework.css," "utility class in Bricks," "padding-xl," "grid-cols-3," "flex-row," "font-size-l," "Bricks global classes," "responsive utility," or asks which CSS classes exist in Bricks by default. The full CSS source is in references/core-framework.css.'
)

for entry in "${ENTRIES[@]}"; do
  IFS='|' read -r NAME SRCFILE DESC <<<"$entry"
  SKILL_DIR="$DEST_AGENTS/$NAME"
  mkdir -p "$SKILL_DIR"
  {
    printf -- '---\n'
    printf 'name: %s\n' "$NAME"
    printf 'description: %s\n' "$DESC"
    printf 'metadata:\n'
    printf '  version: 1.0.0\n'
    printf '  source: https://github.com/wpgaurav/bricks-skills\n'
    printf '  source_commit: %s\n' "$UPSTREAM_COMMIT"
    printf -- '---\n\n'
    cat "$SRC/$SRCFILE"
  } > "$SKILL_DIR/SKILL.md"

  # Symlink into Claude Code skills dir (same pattern as marketing skills)
  ln -sfn "../../.agents/skills/$NAME" "$DEST_CLAUDE/$NAME"
done

# Bundle the raw CSS into the core-framework skill as a reference file
mkdir -p "$DEST_AGENTS/bricks-core-framework/references"
cp "$SRC/core-framework.css" "$DEST_AGENTS/bricks-core-framework/references/core-framework.css"

echo "Generated $(ls "$DEST_AGENTS" | grep -c '^bricks-') bricks skills."
