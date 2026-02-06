# Shared Component Library

## Overview

The shared component library (`ts/lib/components/`) provides 53 reusable UI primitives used throughout Anki's web interface. These components follow consistent patterns and use Svelte's reactivity system.

**Location**: [`ts/lib/components/`](/home/felipe/Projects/anki/ts/lib/components/)  
**Types**: [`types.ts`](/home/felipe/Projects/anki/ts/lib/components/types.ts)  
**Icons**: [`icons.ts`](/home/felipe/Projects/anki/ts/lib/components/icons.ts)

## Component Categories

### Layout Components

#### Container

**File**: [`Container.svelte`](/home/felipe/Projects/anki/ts/lib/components/Container.svelte)

Responsive container with breakpoint support.

**Props**:
- `breakpoint: Breakpoint | "fluid"`: Max width breakpoint
- `id?: string`: HTML id
- `class?: string`: CSS classes

**Breakpoints**: `xs`, `sm`, `md`, `lg`, `xl`, `xxl`, `fluid`

**CSS Variables**:
- `--gutter-inline`: Horizontal padding
- `--gutter-block`: Vertical padding
- `--container-direction`: Flex direction

#### Row

**File**: [`Row.svelte`](/home/felipe/Projects/anki/ts/lib/components/Row.svelte)

Flexbox row container for columns.

**Props**:
- `--cols?: number`: Number of columns (default: 12)
- Standard HTML attributes

#### Col

**File**: [`Col.svelte`](/home/felipe/Projects/anki/ts/lib/components/Col.svelte)

Flexbox column within a Row.

**Props**:
- `--col?: Size`: Column width (1-12)
- `--col-justify?: string`: Justify content
- Standard HTML attributes

#### Spacer

**File**: [`Spacer.svelte`](/home/felipe/Projects/anki/ts/lib/components/Spacer.svelte)

Flexible spacer for layout.

**Props**: None (uses flex-grow)

#### Absolute

**File**: [`Absolute.svelte`](/home/felipe/Projects/anki/ts/lib/components/Absolute.svelte)

Absolutely positioned container.

**Props**:
- `top`, `right`, `bottom`, `left`: Position
- `--margin`: Margin offset

### Form Controls

#### CheckBox

**File**: [`CheckBox.svelte`](/home/felipe/Projects/anki/ts/lib/components/CheckBox.svelte)

Styled checkbox input.

**Props**:
- `checked: boolean`: Checked state
- `disabled?: boolean`: Disabled state
- `indeterminate?: boolean`: Indeterminate state

#### Switch

**File**: [`Switch.svelte`](/home/felipe/Projects/anki/ts/lib/components/Switch.svelte)

Toggle switch control.

**Props**:
- `checked: boolean`: Checked state
- `disabled?: boolean`: Disabled state

#### SwitchRow

**File**: [`SwitchRow.svelte`](/home/felipe/Projects/anki/ts/lib/components/SwitchRow.svelte)

Switch with label row.

**Props**:
- `value: Writable<boolean>`: Two-way bound value
- `defaultValue: boolean`: Default value
- Slot: Label content

#### SpinBox

**File**: [`SpinBox.svelte`](/home/felipe/Projects/anki/ts/lib/components/SpinBox.svelte)

Number input with increment/decrement buttons.

**Props**:
- `value: Writable<number>`: Two-way bound value
- `min?: number`: Minimum value
- `max?: number`: Maximum value
- `step?: number`: Step increment
- `disabled?: boolean`: Disabled state

#### Select

**File**: [`Select.svelte`](/home/felipe/Projects/anki/ts/lib/components/Select.svelte)

Custom select dropdown.

**Props**:
- `value: Writable<T>`: Selected value
- `list: T[]`: Options list
- `parser: (item: T) => { content: string, value: V }`: Parse items
- `label?: string`: Display label
- `disabled?: boolean`: Disabled state

#### SelectOption

**File**: [`SelectOption.svelte`](/home/felipe/Projects/anki/ts/lib/components/SelectOption.svelte)

Option within Select component.

#### EnumSelectorRow

**File**: [`EnumSelectorRow.svelte`](/home/felipe/Projects/anki/ts/lib/components/EnumSelectorRow.svelte)

Enum selector with label row.

**Props**:
- `value: Writable<number>`: Selected enum value
- `defaultValue: number`: Default value
- `choices: Array<{ label: string, value: number }>`: Options
- `breakpoint?: Breakpoint`: Responsive breakpoint
- Slot: Label content

#### ConfigInput

**File**: [`ConfigInput.svelte`](/home/felipe/Projects/anki/ts/lib/components/ConfigInput.svelte)

Configuration input wrapper.

### Buttons

#### IconButton

**File**: [`IconButton.svelte`](/home/felipe/Projects/anki/ts/lib/components/IconButton.svelte)

Button with icon.

**Props**:
- `icon: IconData`: Icon to display
- `iconSize?: number`: Icon size (default: 100)
- `tooltip?: string`: Tooltip text
- `disabled?: boolean`: Disabled state
- `active?: boolean`: Active state
- Standard button attributes

#### LabelButton

**File**: [`LabelButton.svelte`](/home/felipe/Projects/anki/ts/lib/components/LabelButton.svelte)

Button with text label.

**Props**:
- `primary?: boolean`: Primary button style
- `tooltip?: string`: Tooltip text
- Standard button attributes

#### ButtonGroup

**File**: [`ButtonGroup.svelte`](/home/felipe/Projects/anki/ts/lib/components/ButtonGroup.svelte)

Container for grouped buttons.

#### ButtonGroupItem

**File**: [`ButtonGroupItem.svelte`](/home/felipe/Projects/anki/ts/lib/components/ButtonGroupItem.svelte)

Item within ButtonGroup.

#### ButtonToolbar

**File**: [`ButtonToolbar.svelte`](/home/felipe/Projects/anki/ts/lib/components/ButtonToolbar.svelte)

Toolbar container for buttons.

#### RevertButton

**File**: [`RevertButton.svelte`](/home/felipe/Projects/anki/ts/lib/components/RevertButton.svelte)

Button to revert changes.

**Props**:
- `onRevert: () => void`: Revert handler

### Overlays and Modals

#### Popover

**File**: [`Popover.svelte`](/home/felipe/Projects/anki/ts/lib/components/Popover.svelte)

Floating popover container.

**Props**:
- `id?: string`: HTML id
- `scrollable?: boolean`: Enable scrolling

**Features**:
- Uses Floating UI for positioning
- Animated appearance
- Responsive placement

#### WithFloating

**File**: [`WithFloating.svelte`](/home/felipe/Projects/anki/ts/lib/components/WithFloating.svelte)

Wrapper for floating elements.

**Props**:
- `show: boolean`: Visibility
- `closeOnInsideClick?: boolean`: Close on click
- `inline?: boolean`: Inline positioning
- Slots: `reference`, `floating`

#### WithOverlay

**File**: [`WithOverlay.svelte`](/home/felipe/Projects/anki/ts/lib/components/WithOverlay.svelte)

Wrapper for overlay elements.

**Props**:
- `show: boolean`: Visibility
- `closeOnClick?: boolean`: Close on click
- Slots: `reference`, `overlay`

#### WithTooltip

**File**: [`WithTooltip.svelte`](/home/felipe/Projects/anki/ts/lib/components/WithTooltip.svelte)

Wrapper for tooltips.

**Props**:
- `tooltip: string`: Tooltip text
- `placement?: Placement`: Tooltip placement
- Slot: Reference element

#### FloatingArrow

**File**: [`FloatingArrow.svelte`](/home/felipe/Projects/anki/ts/lib/components/FloatingArrow.svelte)

Arrow for floating elements.

#### HelpModal

**File**: [`HelpModal.svelte`](/home/felipe/Projects/anki/ts/lib/components/HelpModal.svelte)

Modal with help content.

**Props**:
- `title: string`: Modal title
- `url: string`: Help page URL
- `helpSections: HelpItem[]`: Help sections
- `fsrs?: boolean`: FSRS-specific help

**Events**:
- `mount`: Fired with modal and carousel instances

#### ErrorPage

**File**: [`ErrorPage.svelte`](/home/felipe/Projects/anki/ts/lib/components/ErrorPage.svelte)

Error display page.

**Props**:
- `error: Error`: Error to display

### Display Components

#### Badge

**File**: [`Badge.svelte`](/home/felipe/Projects/anki/ts/lib/components/Badge.svelte)

Badge indicator.

**Props**:
- `--badge-color?: string`: Badge color
- `--icon-align?: string`: Icon alignment

#### Icon

**File**: [`Icon.svelte`](/home/felipe/Projects/anki/ts/lib/components/Icon.svelte)

Icon display component.

**Props**:
- `icon: IconData`: Icon to display
- `iconSize?: number`: Icon size

#### Item

**File**: [`Item.svelte`](/home/felipe/Projects/anki/ts/lib/components/Item.svelte)

List item container.

#### Label

**File**: [`Label.svelte`](/home/felipe/Projects/anki/ts/lib/components/Label.svelte)

Form label.

#### SettingTitle

**File**: [`SettingTitle.svelte`](/home/felipe/Projects/anki/ts/lib/components/SettingTitle.svelte)

Setting title with click handler.

**Props**:
- `on:click`: Click event

#### TitledContainer

**File**: [`TitledContainer.svelte`](/home/felipe/Projects/anki/ts/lib/components/TitledContainer.svelte)

Container with title.

**Props**:
- `title: string`: Title text
- Slot `tooltip`: Tooltip content

### Dropdown Components

#### DropdownItem

**File**: [`DropdownItem.svelte`](/home/felipe/Projects/anki/ts/lib/components/DropdownItem.svelte)

Item in dropdown menu.

**Props**:
- `active?: boolean`: Active state
- `on:click`: Click handler

#### DropdownDivider

**File**: [`DropdownDivider.svelte`](/home/felipe/Projects/anki/ts/lib/components/DropdownDivider.svelte)

Divider in dropdown menu.

### Collapsible Components

#### Collapsible

**File**: [`Collapsible.svelte`](/home/felipe/Projects/anki/ts/lib/components/Collapsible.svelte)

Collapsible content container.

**Props**:
- `collapse: boolean`: Collapsed state
- `toggleDisplay?: boolean`: Toggle display vs height
- `let:collapsed`: Slot prop for collapsed state

### Sticky Components

#### StickyContainer

**File**: [`StickyContainer.svelte`](/home/felipe/Projects/anki/ts/lib/components/StickyContainer.svelte)

Sticky positioned container.

**Props**:
- `breakpoint?: Breakpoint`: Responsive breakpoint
- `--sticky-borders?: string`: Border styles
- Standard container props

### Scroll Components

#### ScrollArea

**File**: [`ScrollArea.svelte`](/home/felipe/Projects/anki/ts/lib/components/ScrollArea.svelte)

Scrollable area container.

### Table Components

#### VirtualTable

**File**: [`VirtualTable.svelte`](/home/felipe/Projects/anki/ts/lib/components/VirtualTable.svelte)

Virtualized table for large datasets.

**Props**:
- `items: T[]`: Data items
- `rowHeight?: number`: Row height
- `renderRow: (item: T) => Component`: Row renderer

### Utility Components

#### Portal

**File**: [`Portal.svelte`](/home/felipe/Projects/anki/ts/lib/components/Portal.svelte)

Portal to render content elsewhere in DOM.

**Props**:
- `target?: HTMLElement`: Target element

#### Shortcut

**File**: [`Shortcut.svelte`](/home/felipe/Projects/anki/ts/lib/components/Shortcut.svelte)

Keyboard shortcut handler.

**Props**:
- `keyCombination: string`: Key combination (e.g., "Ctrl+Enter")
- `on:action`: Action event

#### BackendProgressIndicator

**File**: [`BackendProgressIndicator.svelte`](/home/felipe/Projects/anki/ts/lib/components/BackendProgressIndicator.svelte)

Progress indicator for backend operations.

**Props**:
- `task: () => Promise<T>`: Async task
- `bind:result`: Task result
- `bind:error`: Task error

#### DynamicallySlottable

**File**: [`DynamicallySlottable.svelte`](/home/felipe/Projects/anki/ts/lib/components/DynamicallySlottable.svelte)

Dynamic slot host for add-ons.

**Props**:
- `slotHost: Component`: Host component
- `api: Record<string, unknown>`: API object

#### RenderChildren

**File**: [`RenderChildren.svelte`](/home/felipe/Projects/anki/ts/lib/components/RenderChildren.svelte)

Render children dynamically.

#### WithContext

**File**: [`WithContext.svelte`](/home/felipe/Projects/anki/ts/lib/components/WithContext.svelte)

Context provider wrapper.

#### WithState

**File**: [`WithState.svelte`](/home/felipe/Projects/anki/ts/lib/components/WithState.svelte)

State management wrapper.

#### IconConstrain

**File**: [`IconConstrain.svelte`](/home/felipe/Projects/anki/ts/lib/components/IconConstrain.svelte)

Icon size constraint wrapper.

#### HelpSection

**File**: [`HelpSection.svelte`](/home/felipe/Projects/anki/ts/lib/components/HelpSection.svelte)

Help section content.

## Context Keys

**File**: [`context-keys.ts`](/home/felipe/Projects/anki/ts/lib/components/context-keys.ts)

Symbol keys for Svelte context:

- `touchDeviceKey`: Touch device detection
- `sectionKey`: Section context
- `buttonGroupKey`: Button group context
- `dropdownKey`: Dropdown context
- `modalsKey`: Modals registry
- `floatingKey`: Floating UI placement
- `overlayKey`: Overlay context
- `selectKey`: Select context
- `showKey`: Show state
- `focusIdKey`: Focus ID

## Icons

**File**: [`icons.ts`](/home/felipe/Projects/anki/ts/lib/components/icons.ts)

Icon registry with 80+ icons. Each icon exports:
- `url`: SVG URL
- `component`: Svelte component

**Icon Categories**:
- Navigation: `chevronDown`, `chevronUp`, `arrowLeft`, `arrowRight`
- Actions: `plusIcon`, `minusIcon`, `deleteIcon`, `updateIcon`
- Editor: `boldIcon`, `italicIcon`, `underlineIcon`
- Image Occlusion: `mdiRectangleOutline`, `mdiEllipseOutline`, `mdiVectorPolygonVariant`
- And many more...

## Helpers

**File**: [`helpers.ts`](/home/felipe/Projects/anki/ts/lib/components/helpers.ts)

Utility functions:
- `mergeTooltipAndShortcut()`: Combine tooltip and shortcut text
- `withButton()`: Button event handler wrapper
- `withSpan()`: Span event handler wrapper

## Resizable

**File**: [`resizable.ts`](/home/felipe/Projects/anki/ts/lib/components/resizable.ts)

Resizable element action:

```typescript
export function resizable(
    node: HTMLElement,
    options: ResizerOptions
): Resizer
```

**Options**:
- `direction: "horizontal" | "vertical"`: Resize direction
- `onResize?: (size: number) => void`: Resize callback

## Type Definitions

**File**: [`types.ts`](/home/felipe/Projects/anki/ts/lib/components/types.ts)

- `Size`: 1-12 grid size
- `Breakpoint`: Responsive breakpoint names
- `HelpItem`: Help item structure
- `HelpItemScheduler`: SM2 vs FSRS
- `IconData`: Icon data structure

## Usage Patterns

### Form Control with Label

```svelte
<SwitchRow bind:value={$enabled} defaultValue={false}>
    <SettingTitle on:click={openHelp}>
        Enable Feature
    </SettingTitle>
</SwitchRow>
```

### Container with Responsive Layout

```svelte
<Container breakpoint="md" --gutter-inline="1rem">
    <Row --cols={2}>
        <Col --col={6}>
            <!-- Left column -->
        </Col>
        <Col --col={6}>
            <!-- Right column -->
        </Col>
    </Row>
</Container>
```

### Popover with Reference

```svelte
<WithFloating show={showPopover} closeOnInsideClick>
    <IconButton slot="reference" on:click={() => showPopover = true}>
        <Icon icon={infoIcon} />
    </IconButton>
    <Popover slot="floating">
        <DropdownItem>Option 1</DropdownItem>
        <DropdownItem>Option 2</DropdownItem>
    </Popover>
</WithFloating>
```

### Keyboard Shortcut

```svelte
<Shortcut
    keyCombination="Ctrl+Enter"
    on:action={save}
/>
```

## Key Files Reference

- **Types**: [`types.ts`](/home/felipe/Projects/anki/ts/lib/components/types.ts)
- **Icons**: [`icons.ts`](/home/felipe/Projects/anki/ts/lib/components/icons.ts)
- **Context Keys**: [`context-keys.ts`](/home/felipe/Projects/anki/ts/lib/components/context-keys.ts)
- **Helpers**: [`helpers.ts`](/home/felipe/Projects/anki/ts/lib/components/helpers.ts)
- **Resizable**: [`resizable.ts`](/home/felipe/Projects/anki/ts/lib/components/resizable.ts)
