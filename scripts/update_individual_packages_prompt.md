# Reusable AI Prompt: Update Individual Sub-Package Projects After s_packages Version Bump

Use this prompt whenever `s_packages` has been bumped to a new version and the individual sub-package git projects need to be updated accordingly.

---

## How to Use

1. Bump `s_packages` version and write its CHANGELOG.md with all sub-package changes
2. Copy the prompt below into a new AI chat session
3. Fill in the `[PLACEHOLDERS]` with the actual values
4. Run the prompt

---

## The Prompt

```
I have a Flutter monorepo called `s_packages` at:
  /Users/christophechanteur/Development/Flutter_projects/s_packages/

It contains the source code for 40 sub-packages that are also published individually as separate git projects at:
  /Users/christophechanteur/Development/Flutter_projects/s_packages - with individual git/

Each individual project only depends on s_packages (re-exports its content). Their pubspec.yaml has:
  s_packages: ^X.Y.Z

I have just bumped s_packages to version [NEW_VERSION] (was [OLD_VERSION]).

### Task

Update ALL 40 individual sub-package projects to reflect this s_packages version bump. For each project, update:

1. **pubspec.yaml** — bump the package version AND update `s_packages` dependency to `^[NEW_VERSION]`
2. **CHANGELOG.md** — prepend a new version entry
3. **README.md** — update the version reference in the installation `pubspec.yaml` code block AND update content to reflect any new/changed/removed APIs

### The 40 individual packages are:
bubble_label, indexscroll_listview_builder, keystroke_listener, pop_overlay, pop_this, post_frame, s_animated_tabs, s_banner, s_bounceable, s_button, s_client, s_connectivity, s_context_menu, s_disabled, s_dropdown, s_error_widget, s_expendable_menu, s_future_button, s_glow, s_gridview, s_ink_button, s_liquid_pull_to_refresh, s_maintenance_button, s_modal, s_offstage, s_screenshot, s_sidebar, s_standby, s_time, s_toggle, s_webview, s_widgets, settings_item, shaker, signals_watch, soundsliced_dart_extensions, soundsliced_tween_animation_builder, states_rebuilder_extended, ticker_free_circular_progress_indicator, week_calendar

### Versioning Rules

Determine each package's new version by reading the s_packages CHANGELOG.md entry for [NEW_VERSION]:

- **BREAKING changes for the sub-package** → bump MAJOR version (e.g. 2.0.0 → 3.0.0)
- **Non-breaking feature additions for the sub-package** → bump MINOR version (e.g. 2.0.0 → 2.1.0)
- **No changes relevant to the sub-package** → bump PATCH version (e.g. 2.0.0 → 2.0.1)

### CHANGELOG.md Format

For packages WITH relevant changes, prepend:
```
## [NEW_PACKAGE_VERSION]
- `s_packages` dependency upgraded to ^[NEW_VERSION]
- [list each relevant change from s_packages CHANGELOG, preserving the exact wording]
```

For packages WITHOUT relevant changes, prepend:
```
## [NEW_PACKAGE_VERSION]
- `s_packages` package dependency upgraded
```

IMPORTANT: Match the existing CHANGELOG format of each package. Some have headers like "# Changelog" with "All notable changes..." preamble, others just start with `## X.Y.Z`. Preserve each package's existing format.

### README.md Updates

1. Update the version in the installation code block: `package_name: ^[NEW_PACKAGE_VERSION]`
2. For packages with NEW features: add new parameters to API tables, add usage examples for new APIs
3. For packages with BREAKING changes: add a breaking changes notice, update/remove references to removed APIs, update renamed parameter names in examples
4. For packages with only internal improvements: optionally add a "What's New in vX.Y.Z" section

### Process

1. First, read the s_packages CHANGELOG.md for the [NEW_VERSION] entry
2. Read each individual package's current pubspec.yaml to get its current version and s_packages dependency
3. Determine which packages have changes (and what type) vs no changes
4. Update all files accordingly
5. Verify a few packages by reading the updated files

### s_packages CHANGELOG.md for [NEW_VERSION]

[PASTE THE FULL CHANGELOG ENTRY FOR THE NEW VERSION HERE]
```

---

## Notes

- The s_packages CHANGELOG.md organizes changes by sub-package using the format: `**\`package_name\` sub-package improvements**:`
- BREAKING changes are marked with `**BREAKING:**` prefix in the changelog entries
- The individual packages live at `/Users/christophechanteur/Development/Flutter_projects/s_packages - with individual git/[package_name]/`
- Each package has: `pubspec.yaml`, `CHANGELOG.md`, `README.md`, `lib/`, `example/`, `test/`

