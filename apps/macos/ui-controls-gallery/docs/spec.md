# UI Controls Gallery

**Complexity:** 3/7
**Key features exercised:** All standard AppKit controls, visual regression baseline, layout, diverse property types

## Purpose

A scrollable window showcasing all major AppKit UI controls. Serves as a visual regression baseline: any change to bindings that affects property types, enum values, or method signatures will produce visible differences when this app is screenshot-tested.

## Window Layout

- **Window:**
  - Title: "UI Controls Gallery"
  - Size: 500 x 600 points
  - Position: centered on screen
  - Style: titled, closable, miniaturizable, resizable
  - Minimum size: 400 x 400

- **Content:** Vertical stack of labeled control sections inside an `NSScrollView`. Each section has a header label (bold, 14pt) followed by the control(s).

### Sections

1. **Text Fields**
   - `NSTextField` (editable) with placeholder "Type here..."
   - `NSSecureTextField` with placeholder "Password"

2. **Buttons**
   - `NSButton` (push button): "Click Me"
   - `NSButton` (checkbox): "Enable Feature"
   - `NSButton` (radio buttons): "Option A", "Option B", "Option C" (mutually exclusive)

3. **Sliders**
   - `NSSlider` (horizontal): range 0-100, initial value 50
   - Value label showing current slider value, updated live

4. **Popup & Combo**
   - `NSPopUpButton` with items: "Small", "Medium", "Large"
   - `NSComboBox` with items: "Red", "Green", "Blue" (editable)

5. **Date Picker**
   - `NSDatePicker` showing current date and time
   - Style: textual with stepper

6. **Progress Indicators**
   - `NSProgressIndicator` (determinate bar): value 65%
   - `NSProgressIndicator` (indeterminate spinner): animating

7. **Stepper**
   - `NSStepper` with range 0-10, initial value 5
   - Value label showing current stepper value

8. **Color & Image**
   - `NSColorWell` with initial color: system blue
   - `NSImageView` displaying `NSImage.imageNamed:` with system symbol "star.fill"

## Behavior

1. All controls render correctly and are interactive
2. Slider value label updates in real-time as slider is dragged
3. Stepper value label updates on increment/decrement
4. Radio buttons are mutually exclusive
5. Checkbox toggles independently
6. Popup shows all three options
7. Progress bar shows at 65%, spinner animates
8. Scrolling works when content exceeds window height

## API Surface

| API | Usage |
|-----|-------|
| `NSScrollView` | Scrollable container |
| `NSStackView` | Vertical layout of sections |
| `NSTextField`, `NSSecureTextField` | Text input |
| `NSButton` (various types) | Push, checkbox, radio |
| `NSSlider` | Continuous value control |
| `NSPopUpButton` | Dropdown selection |
| `NSComboBox` | Editable dropdown |
| `NSDatePicker` | Date/time selection |
| `NSProgressIndicator` | Determinate/indeterminate progress |
| `NSStepper` | Increment/decrement control |
| `NSColorWell` | Color picker |
| `NSImageView` | Image display |
| `NSFont.boldSystemFontOfSize:` | Section headers |

## Patterns Exercised

- **Diverse property types:** Bool, integer, float, string, color, date, enum values
- **Enum constants:** Button types, bezel styles, progress indicator styles, date picker styles
- **Container views:** ScrollView, StackView, nested view hierarchy
- **Live value updates:** Target-action on slider/stepper updating labels
- **System resources:** Named images, system colors

## Success Criteria

- All 8 sections visible (scrolling if needed)
- Each control type renders correctly with expected appearance
- Interactive controls respond to user input
- Value labels update live for slider and stepper
- No layout clipping or overlap between sections
