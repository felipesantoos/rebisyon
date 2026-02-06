# Qt Dialogs

## Overview

Anki uses Qt Designer UI files (`.ui`) and Python controllers for various dialogs throughout the application.

**Directory**: [`qt/aqt/forms/`](/home/felipe/Projects/anki/qt/aqt/forms/)  
**Total Files**: 42 `.ui` files + 43 Python controllers

## Dialog Categories

### Card Management

- **`addcards.ui`**: Add cards dialog
- **`editcurrent.ui`**: Edit current card dialog
- **`emptycards.ui`**: Empty cards dialog

### Note Type Management

- **`addmodel.ui`**: Add note type dialog
- **`changemodel.ui`**: Change note type dialog
- **`modelopts.ui`**: Note type options
- **`models.ui`**: Manage note types dialog
- **`template.ui`**: Template editor

### Deck Management

- **`dconf.ui`**: Deck configuration
- **`deckoptions.ui`**: Deck options (legacy)
- **`filtered_deck.ui`**: Filtered deck dialog
- **`studydeck.ui`**: Study deck selector

### Import/Export

- **`importing.ui`**: Import dialog
- **`exporting.ui`**: Export dialog

### Preferences and Settings

- **`preferences.ui`**: Preferences dialog
- **`setlang.ui`**: Language selection
- **`setgroup.ui`**: Group settings

### Browser Dialogs

- **`browser.ui`**: Browser main window
- **`browserdisp.ui`**: Browser display options
- **`browseropts.ui`**: Browser options
- **`finddupes.ui`**: Find duplicates
- **`findreplace.ui`**: Find and replace
- **`preview.ui`**: Card preview

### Statistics

- **`stats.ui`**: Statistics dialog

### Add-ons

- **`addons.ui`**: Add-ons manager
- **`addonconf.ui`**: Add-on configuration
- **`getaddons.ui`**: Get add-ons dialog

### Other Dialogs

- **`about.ui`**: About dialog
- **`clayout_top.ui`**: Card layout top
- **`customstudy.ui`**: Custom study
- **`debug.ui`**: Debug console
- **`edithtml.ui`**: Edit HTML
- **`fields.ui`**: Fields editor
- **`forget.ui`**: Forget cards
- **`progress.ui`**: Progress dialog
- **`profiles.ui`**: Profile manager
- **`reposition.ui`**: Reposition cards
- **`setlang.ui`**: Set language
- **`synclog.ui`**: Sync log
- **`taglimit.ui`**: Tag limit

## Common Patterns

### UI File Structure

Qt Designer UI files define:
- Window/widget structure
- Layouts
- Widgets and properties
- Menu bars
- Actions and shortcuts

### Python Controllers

Each `.ui` file has a corresponding Python file:
- Loads UI file
- Connects signals/slots
- Implements logic
- Manages dialog lifecycle

### Dialog Lifecycle

1. Create dialog instance
2. Load UI file
3. Setup connections
4. Show dialog (`exec()` or `show()`)
5. Process user input
6. Return result

## Key Files Reference

- **Forms Directory**: [`forms/`](/home/felipe/Projects/anki/qt/aqt/forms/)
- **Add Cards**: [`addcards.py`](/home/felipe/Projects/anki/qt/aqt/addcards.py), [`addcards.ui`](/home/felipe/Projects/anki/qt/aqt/forms/addcards.ui)
- **Preferences**: [`preferences.py`](/home/felipe/Projects/anki/qt/aqt/preferences.py), [`preferences.ui`](/home/felipe/Projects/anki/qt/aqt/forms/preferences.ui)
- **Browser**: [`browser/browser.py`](/home/felipe/Projects/anki/qt/aqt/browser/browser.py), [`browser.ui`](/home/felipe/Projects/anki/qt/aqt/forms/browser.ui)
