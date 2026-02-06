# Card Browser

## Overview

The card browser provides a searchable, filterable interface for viewing and managing cards.

**Main File**: [`qt/aqt/browser/browser.py`](/home/felipe/Projects/anki/qt/aqt/browser/browser.py)  
**UI File**: [`qt/aqt/forms/browser.ui`](/home/felipe/Projects/anki/qt/aqt/forms/browser.ui)

## Purpose

The browser allows users to:
- Search and filter cards
- View card details
- Edit cards
- Delete cards
- Change note types
- Flag cards
- Export cards

## Components

### Browser Window

**Class**: `Browser` in `browser.py`

**Features**:
- Search bar
- Filter sidebar
- Card table
- Preview pane
- Toolbar with actions

### Sidebar

**Directory**: [`qt/aqt/browser/sidebar/`](/home/felipe/Projects/anki/qt/aqt/browser/sidebar/)

- **Tree**: Deck hierarchy
- **Search Bar**: Search input
- **Toolbar**: Filter actions
- **Model**: Sidebar data model

### Table

**Directory**: [`qt/aqt/browser/table/`](/home/felipe/Projects/anki/qt/aqt/browser/table/)

Card display table with columns:
- Question
- Answer
- Deck
- Due date
- Interval
- Ease
- And more...

### Previewer

**File**: [`qt/aqt/browser/previewer.py`](/home/felipe/Projects/anki/qt/aqt/browser/previewer.py)

Card preview dialog showing card front and back.

## Key Files Reference

- **Browser**: [`browser/browser.py`](/home/felipe/Projects/anki/qt/aqt/browser/browser.py)
- **UI File**: [`forms/browser.ui`](/home/felipe/Projects/anki/qt/aqt/forms/browser.ui)
- **Sidebar**: [`browser/sidebar/`](/home/felipe/Projects/anki/qt/aqt/browser/sidebar/)
- **Table**: [`browser/table/`](/home/felipe/Projects/anki/qt/aqt/browser/table/)
