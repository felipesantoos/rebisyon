# Main Window

## Overview

The main window is the primary Qt application window that hosts all other dialogs and web views.

**File**: [`qt/aqt/main.py`](/home/felipe/Projects/anki/qt/aqt/main.py) - `AnkiQt` class  
**UI File**: [`qt/aqt/forms/main.ui`](/home/felipe/Projects/anki/qt/aqt/forms/main.ui)

## Purpose

The main window provides:
- Application menu bar
- Central widget area for web views
- Window management
- Menu actions for all major features

## Structure

### Menu Bar

**Menus**:
- **File**: Profile switching, import/export, backup, exit
- **Edit**: Undo/redo
- **View**: Full screen, zoom controls
- **Tools**: Study deck, filtered deck, database check, add-ons, note types, preferences
- **Help**: Documentation, donate, about

### Central Widget

The central widget is a `QWidget` that hosts:
- Deck browser web view
- Reviewer web view
- Other web views as needed

### Key Actions

- **Exit**: `Ctrl+Q`
- **Preferences**: `Ctrl+P`
- **Switch Profile**: `Ctrl+Shift+P`
- **Import**: `Ctrl+Shift+I`
- **Export**: `Ctrl+E`
- **Study Deck**: `/`
- **Create Filtered Deck**: `F`
- **Note Types**: `Ctrl+Shift+N`
- **Add-ons**: `Ctrl+Shift+A`

## Web View Integration

The main window uses `AnkiWebView` to display:
- Deck browser
- Reviewer
- Statistics
- Other SvelteKit pages

## Key Files Reference

- **Main Class**: [`main.py`](/home/felipe/Projects/anki/qt/aqt/main.py)
- **UI File**: [`forms/main.ui`](/home/felipe/Projects/anki/qt/aqt/forms/main.ui)
