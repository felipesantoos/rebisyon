# Tag Editor Components

## Overview

The Tag Editor system (`ts/lib/tag-editor/`) provides components for managing tags on notes with autocomplete, deletion, and editing capabilities.

**Directory**: [`ts/lib/tag-editor/`](/home/felipe/Projects/anki/ts/lib/tag-editor/)  
**Total Files**: 16 files

## Purpose

Tag editor allows users to:
- Add tags to notes
- Remove tags
- Edit existing tags
- Autocomplete from existing tags
- Manage tag options

## Components

### TagEditor

**File**: [`TagEditor.svelte`](/home/felipe/Projects/anki/ts/lib/tag-editor/TagEditor.svelte)

Main tag editor component.

**Props**:
- `tags: Writable<string[]>`: Tags store
- `on:tagsupdate`: Event with updated tags

**Features**:
- Tag input with autocomplete
- Tag display with delete buttons
- Tag editing mode

### TagInput

**File**: [`TagInput.svelte`](/home/felipe/Projects/anki/ts/lib/tag-editor/TagInput.svelte)

Tag input field with autocomplete.

**Features**:
- Autocomplete suggestions
- Tag creation
- Keyboard navigation

### Tag

**File**: [`Tag.svelte`](/home/felipe/Projects/anki/ts/lib/tag-editor/Tag.svelte)

Individual tag display component.

**Props**:
- `tag: string`: Tag text
- `on:delete`: Delete event

### TagDeleteBadge

**File**: [`TagDeleteBadge.svelte`](/home/felipe/Projects/anki/ts/lib/tag-editor/TagDeleteBadge.svelte)

Delete button for tags.

### TagEditMode

**File**: [`TagEditMode.svelte`](/home/felipe/Projects/anki/ts/lib/tag-editor/TagEditMode.svelte)

Tag editing interface.

### TagsRow

**File**: [`TagsRow.svelte`](/home/felipe/Projects/anki/ts/lib/tag-editor/TagsRow.svelte)

Row container for tags.

### TagSpacer

**File**: [`TagSpacer.svelte`](/home/felipe/Projects/anki/ts/lib/tag-editor/TagSpacer.svelte)

Spacer between tags.

### TagWithTooltip

**File**: [`TagWithTooltip.svelte`](/home/felipe/Projects/anki/ts/lib/tag-editor/TagWithTooltip.svelte)

Tag with tooltip display.

### AutocompleteItem

**File**: [`AutocompleteItem.svelte`](/home/felipe/Projects/anki/ts/lib/tag-editor/AutocompleteItem.svelte)

Autocomplete suggestion item.

### WithAutocomplete

**File**: [`WithAutocomplete.svelte`](/home/felipe/Projects/anki/ts/lib/tag-editor/WithAutocomplete.svelte)

Autocomplete wrapper component.

## Tag Options Button

**Directory**: [`tag-options-button/`](/home/felipe/Projects/anki/ts/lib/tag-editor/tag-options-button/)

Tag management buttons.

- **`TagOptionsButton.svelte`**: Main options button
- **`TagAddButton.svelte`**: Add tag button
- **`TagsSelectedButton.svelte`**: Selected tags button

## Utilities

**File**: [`tags.ts`](/home/felipe/Projects/anki/ts/lib/tag-editor/tags.ts)

Tag utility functions:
- Tag parsing
- Tag validation
- Tag filtering

## Key Files Reference

- **Main Editor**: [`TagEditor.svelte`](/home/felipe/Projects/anki/ts/lib/tag-editor/TagEditor.svelte)
- **Input**: [`TagInput.svelte`](/home/felipe/Projects/anki/ts/lib/tag-editor/TagInput.svelte)
- **Tag Display**: [`Tag.svelte`](/home/felipe/Projects/anki/ts/lib/tag-editor/Tag.svelte)
- **Index**: [`index.ts`](/home/felipe/Projects/anki/ts/lib/tag-editor/index.ts)
