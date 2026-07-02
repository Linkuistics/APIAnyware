# UI Controls Gallery

*Reverse-generated (LLM) from the four existing VM-verified implementations (racket,
chez, gerbil, sbcl) on 2026-07-02, then human-validated by git review (ADR-0050,
ADR-0052): this prose is the target-independent source of truth; the four
implementations are its projections.*

## 1. Structural facts

- **app-kind:** `gui-app` (the bundled, windowed Cocoa app — `platforms/macos/app-kinds/gui-app/`)
- **display name:** UI Controls Gallery *(the bundlers read this from the first H1 above)*
- **complexity:** 2/7 (the portfolio's second rung — the broad-surface widget-regression suite)
- **API frameworks:** AppKit (with Foundation for strings, geometry value types, and `NSDate`)
- **pattern-kinds exercised:** `target-action` · `parent-child` (view containment) ·
  object-lifecycle · property-configuration · class-method-factory ·
  value-type-geometry · option-set bitmask · enum-constant configuration ·
  view-composition · menu object-graph construction · run-loop entry
- **native units:** none beyond the platform frameworks (pure AppKit/Foundation ObjC
  surface; no Swift-native residual, no custom drawing, no app-specific native code)

## 2. Purpose & intent

A single-window gallery presenting a broad roster of standard AppKit controls, each
constructed and configured through the generated bindings. It is the **visual-regression
baseline / broad-surface exercise** for a target's AppKit binding: any change to property
types, enum values, or method signatures in the bindings shows up as a visible difference
in this window. There is no document, no persistence, and no application logic beyond the
controls' own interactivity — the app's job is to *construct, configure, and display* a
wide slice of the control surface, then run the standard event loop until quit.

## 3. Application kind & lifecycle

A regular, dock-visible, single-window AppKit application (`gui-app`). Launch is
deterministic:

1. **Acquire the application singleton** — the process-wide shared `NSApplication`.
2. **Become a regular app** — activation policy *Regular*
   (`NSApplicationActivationPolicyRegular` = 0): Dock icon and menu bar.
3. **Install the application menu** (§8).
4. **Build the window (§4) and the control gallery (§5–§6)** and compose everything into
   the window's content view.
5. **Present and focus** — make the window key and order it front; activate the
   application ignoring other apps so it is frontmost on launch.
6. **Announce** — write a one-line launch diagnostic to standard output. The line
   **contains the text `Controls Gallery`**; the remainder of the line (greeting shape,
   quit guidance) is implementation-specific and not part of the contract.
7. **Run** — enter the AppKit run loop; the process blocks servicing events. The
   indeterminate spinner's animation is started during setup, before the run loop is
   entered.
8. **Terminate** — via the **Quit** command (Command-Q → `-[NSApplication terminate:]`),
   the `gui-app` app-kind's termination model (`termination "ns-application-terminate"`).
   See §8.

   **Termination is Quit-driven, not close-driven.** No implementation installs an
   application delegate or opts into terminate-after-last-window-closed, and the app-kind
   does not require it; on stock AppKit, closing the window hides it and the process
   keeps running **(unknown — to confirm in-VM)**. Some implementations' printed launch
   guidance ("Close window … to exit") suggests otherwise; that text is guidance prose,
   not behaviour — an implementation that wants close-to-quit must opt in explicitly.

No timers, background work, or delegate logic is involved; all dynamism is control-local
(target-action callbacks and the controls' own behaviour).

## 4. Window

A single top-level window created through the designated initializer
`initWithContentRect:styleMask:backing:defer:`:

- **Style mask (invariant core):** the bitwise-OR of **Titled** (1) · **Closable** (2) ·
  **Miniaturizable** (4). Whether **Resizable** is added — and with it a minimum content
  size — is implementation-varying and not asserted by this spec.
- **Backing store:** *Buffered* (`NSBackingStoreBuffered` = 2). **Defer:** *false*.
- **Content size:** a fixed launch size large enough to present the whole roster; the
  realized size is implementation-varying (e.g. 500 × 920 single-column, 820 × 532
  two-column). The intent is *the gallery is visible and uncramped*, not any particular
  pixel size. (The earlier 500 × 600 example was corrected by the live-run stage: a
  600px viewport over the realized ~900px single-column roster launched bottom-scrolled,
  hiding the upper sections — a spec-§4 violation in all three stack-layout impls.)
- **Title rule:** the window title **contains the substring `Controls`** and names the
  gallery (e.g. `UI Controls Gallery`); the full realized title is implementation-varying.
- **Position:** recentered via the window's standard `center` behaviour before display.

## 5. Content layout & section grouping

- All controls live in the **single window's content-view hierarchy**; there is exactly
  one window.
- **Grouping rule:** every control appears under a **bold section header** that groups
  related controls. Headers use the **bold system font** at a moderately-larger-than-body
  size (realized 14–15 pt). The *partitioning* into sections, the section titles, and the
  visual arrangement (a vertically scrolling stack of sections vs. a static multi-column
  page) are implementation-varying realizations — the invariant is *sectioned,
  header-labelled grouping of the roster*, not any particular section map.
- **Static-label idiom (invariant):** every header/caption label is an `NSTextField`
  configured as a non-interactive label — **editable = false, selectable = false,
  bezeled = false, drawsBackground = false** — so it renders as plain text over the
  window background.

## 6. The control roster (invariant per-control contract)

The gallery presents **at least the following fourteen control kinds**; an implementation
may present additional controls, but a conforming gallery must include all of these, each
configured as stated:

| # | Control | Invariant configuration | Implementation-varying (hole) |
|---|---------|------------------------|-------------------------------|
| 1 | **Text field** (`NSTextField`) | placeholder **`Type here...`**; created without disabling editing (an ordinary input field, unlike the labels) | frame |
| 2 | **Secure text field** (`NSSecureTextField`) | placeholder **`Password`**; the secure (password-entry) field variant | frame |
| 3 | **Push button** (`NSButton`) | title **`Click Me`** | bezel style; construction path |
| 4 | **Checkbox** (`NSButton`, checkbox type) | title begins **`Enable`** (realized e.g. `Enable Feature`) | exact title capitalization; initial checked state |
| 5 | **Radio group** (`NSButton`, radio type) | at least two radio buttons titled **`Option A`** and **`Option B`**; **`Option A` is initially selected**; the group is mutually exclusive (§7) | a third `Option C`; exclusion mechanism; container geometry |
| 6 | **Slider** (`NSSlider`) | range **0–100** (`setMinValue:`/`setMaxValue:`), preset to a **fixed mid-range value** (e.g. 50) | initial value; continuous updates; tick marks; live value readout (§12) |
| 7 | **Pop-up button** (`NSPopUpButton`) | populated with **exactly three items** via `addItemWithTitle:` | item texts (e.g. `Small`/`Medium`/`Large`); initial selection |
| 8 | **Combo box** (`NSComboBox`) | populated with **exactly three items** via `addItemWithObjectValue:` | item texts; initial field text |
| 9 | **Date picker** (`NSDatePicker`) | style **text-field-and-stepper** (`NSDatePickerStyleTextFieldAndStepper`); elements **include year-month-day**; value initialized to the **current date (`NSDate` `now`) at launch** | whether hour-minute-second elements are also shown |
| 10 | **Progress bar** (`NSProgressIndicator`) | **determinate** (`setIndeterminate:` false), preset to a **fixed value of roughly two-thirds progress** (e.g. 65) | exact value (realized 60–65); companion percentage label |
| 11 | **Spinner** (`NSProgressIndicator`) | **spinning style** (`NSProgressIndicatorStyleSpinning`), **indeterminate**, and its **animation is started** (`startAnimation:`) during setup | frame; start-order relative to view insertion |
| 12 | **Stepper** (`NSStepper`) | range **0–10**, increment **1** (`setMinValue:`/`setMaxValue:`/`setIncrement:`), preset to a **fixed small value** (e.g. 5) | initial value; continuous flag; live value readout (§12) |
| 13 | **Color well** (`NSColorWell`) | color set to the **system blue color** (`NSColor` `systemBlueColor`) | frame |
| 14 | **Image view** (`NSImageView`) | displays a **built-in system-provided image** obtained from an `NSImage` class factory — **no bundled asset** | which system image and factory (named template image vs. SF Symbol); tinting/scaling; nil-guarding |

Control frames are established at construction (`initWithFrame:`) or immediately after
(`setFrame:`) — the *operation* "create the control and give it a frame" is the
invariant; the selector split is a per-target realization.

## 7. Interactive behaviour

- **Radio mutual exclusion.** When the user selects one radio button, the previously
  selected one is deselected — at most one of the group is on at any time. All
  implementations establish this (via an explicit selection callback that clears siblings
  and selects the sender, or via the platform's sibling-group behaviour); the *observable*
  exclusivity is runtime behaviour **(to confirm in-VM)**.
- **Checkbox toggles** independently of the radio group when clicked
  **(to confirm in-VM)**.
- **Text entry:** the text field accepts typed input; the secure field is the
  password-entry variant and is expected not to display typed text verbatim **(both to
  confirm in-VM — the masking expectation rests on the platform class's identity, not an
  app-configured property)**.
- **Boundary — value clamping:** the slider cannot be driven below 0 or above 100, and
  the stepper cannot be driven below 0 or above 10; increments move the stepper by
  exactly 1 **(to confirm in-VM — the ranges are configured, the clamping is platform
  runtime behaviour)**.
- **No app-level handling** is attached to the push button, popup, combo, date picker,
  color well, or image view beyond their intrinsic control behaviour.

## 8. Application menu

- The menu bar carries one application menu; its bold app-name slot comes from the
  bundle's `CFBundleName` when launched as a `.app` bundle.
- The mandated behaviour is a **Quit** command: title `"Quit " + <menu app name>`, **key
  equivalent Command-Q**, action **`-[NSApplication terminate:]`**. The *menu app name*
  argument is implementation-varying (e.g. `UI Controls Gallery`).
- A conforming implementation may include the other conventional first-menu items (About,
  Hide, …); only *Quit (Command-Q) terminates the app* is asserted.

## 9. API surface exercised

Selectors witnessed in **every** implementation (or named by the app-kind contract) —
platform truths, projection-free:

| Class | Selector | Kind | Role |
|-------|----------|------|------|
| NSApplication | `sharedApplication` | class accessor (singleton) | obtain the app instance |
| NSApplication | `setActivationPolicy:` | property setter | become a Regular app |
| NSApplication | `activateIgnoringOtherApps:` | instance method | foreground on launch |
| NSApplication | `run` | instance method | enter the run loop |
| NSApplication | `terminate:` | instance method | quit (app-kind termination; invoked by the Quit item) |
| NSWindow | `initWithContentRect:styleMask:backing:defer:` | designated initializer | create the window |
| NSWindow | `setTitle:` · `center` · `contentView` · `makeKeyAndOrderFront:` | setter/method/getter/method | title, position, composition root, show+focus |
| NSView | `addSubview:` | instance method | view containment |
| NSView | `setFrame:` | property setter | establish/adjust frames |
| NSControl | `setStringValue:` · `setFont:` | property setters | label text & fonts |
| NSControl | `setDoubleValue:` | property setter | slider/progress preset values |
| NSTextField | `setPlaceholderString:` · `setEditable:` · `setSelectable:` · `setBezeled:` · `setDrawsBackground:` | property setters | placeholders; static-label idiom |
| NSSlider | `setMinValue:` · `setMaxValue:` | property setters | slider range |
| NSStepper | `setMinValue:` · `setMaxValue:` · `setIncrement:` | property setters | stepper range/step |
| NSPopUpButton | `addItemWithTitle:` | instance method | populate popup |
| NSComboBox | `addItemWithObjectValue:` | instance method | populate combo |
| NSDatePicker | `setDatePickerStyle:` · `setDatePickerElements:` · `setDateValue:` | property setters | picker style/elements/value |
| NSProgressIndicator | `setStyle:` · `setIndeterminate:` · `setDoubleValue:` · `startAnimation:` | setters/method | bar & spinner |
| NSColorWell | `setColor:` | property setter | preset color |
| NSColor | `systemBlueColor` | class factory | the well's color |
| NSFont | `systemFontOfSize:` · `boldSystemFontOfSize:` | class factories | body & header fonts |
| NSDate | `now` | class factory | the picker's initial date |

**Abstract operations whose realizing selector varies per implementation** (this spec
asserts the operation, never one impl's selector): control instantiation + framing
(`initWithFrame:` vs. bare alloc/init + `setFrame:` vs. class convenience constructors);
button titling and typing (`setTitle:` + `setButtonType:` vs.
`+buttonWithTitle:target:action:`-family constructors); initial on/off state
(`setIntValue:` vs. `setState:`); target-action wiring (`setTarget:`/`setAction:` vs.
constructor target/action arguments); system-image acquisition and assignment
(`imageNamed:` + `setImage:` vs. `imageWithSystemSymbolName:accessibilityDescription:` +
`+imageViewWithImage:`); main-menu installation (menu object-graph construction,
`setMainMenu:`).

**9.1 Enum / constant values used in every implementation:**

| Constant | Value | Used for |
|----------|-------|----------|
| `NSApplicationActivationPolicyRegular` | 0 | activation policy |
| `NSWindowStyleMaskTitled` | 1 | window style |
| `NSWindowStyleMaskClosable` | 2 | window style |
| `NSWindowStyleMaskMiniaturizable` | 4 | window style |
| `NSBackingStoreBuffered` | 2 | window backing |
| `NSDatePickerStyleTextFieldAndStepper` | 0 | date-picker style |
| `NSDatePickerElementFlagYearMonthDay` | 0x00E0 | date-picker elements |
| `NSProgressIndicatorStyleSpinning` | 1 | spinner style |

Additional constants (resizable mask, button types, bezel styles, autoresizing masks,
stack orientation, hour-minute-second flags, bar style, alignments, …) appear only in
some implementations and are realizations, not part of this contract.

## 10. API-usage patterns

- **Object lifecycle:** allocate → initialize → configure via setters → compose into the
  view/menu graph, which owns the objects for the app's lifetime.
- **Class-method factories / singletons:** `sharedApplication`,
  `systemFontOfSize:`/`boldSystemFontOfSize:`, `systemBlueColor`, `now`, and the
  system-image factories.
- **Property configuration at breadth:** the app's core is setter calls across **diverse
  property types** — booleans, integers, doubles, strings, dates, colors, images, enum
  constants, and option-set bitmasks.
- **Target-action:** controls are wired to send action messages on user interaction (the
  registry `target-action` kind); the depth of use varies by implementation (live
  callbacks vs. constructor-supplied target/action slots).
- **View composition / containment (`parent-child`):** a multi-level hierarchy — controls
  into containers/sections into the content view.
- **Option-set bitmask:** the window style mask and the date-picker element flags are
  OR-combined flag sets.
- **Value-type geometry:** rects/sizes constructed as value types and passed by value.
- **Menu object-graph construction** and **run-loop entry**, as in the app-kind.

## 11. Observable outcomes & accessibility

**Visual outcomes:**
- A single centered window whose title contains `Controls`, showing the full roster of §6
  grouped under bold section headers.
- The text field shows greyed placeholder `Type here...` and the secure field `Password`
  while empty **(to confirm in-VM)**.
- `Option A` appears selected; the slider knob sits mid-track; the progress bar shows
  roughly two-thirds fill; the spinner is animating; the color well shows blue; the image
  view shows a recognizable system image **(fill/animation/selection rendering to confirm
  in-VM)**.
- Native macOS control appearance throughout (no custom drawing).

**Accessibility expectations** *(in-VM confirmable)*:
- The window is exposed with an accessibility title equal to the window title.
- Each roster control is exposed with its standard AppKit accessibility role (button,
  checkbox, radio button, slider, pop-up button, combo box, text field/secure text field,
  progress indicator, stepper, color well, image); section headers are static-text
  elements.
- The application menu's Quit item is reachable and carries the Command-Q key equivalent.

## 12. Not included

- **No document, persistence, or file I/O.** Nothing is read or written.
- **No live value readouts are mandated.** A live-updating numeric label tracking the
  slider/stepper is present in some implementations only; it is a per-implementation
  embellishment, not part of this contract.
- **No scrolling is mandated.** A scroll container is one layout realization, not an
  invariant; a static single-page layout also conforms.
- **No close-to-quit.** Closing the window is not specified to terminate the app (§3.8).
- **No app-specific handling** for push-button clicks, popup/combo selection, date, or
  color changes — the controls act only as themselves.
- **No custom drawing, subclassing, timers, or background threads.**

## 13. Behavioural exemplar (acceptance / forward-generation input)

Observable assertions against a live-VM run, each mapped to a scenario-runner verb
(enumeration only — not scenario code). Assertions state the *rule* (stable
substrings/invariants) so the suite verifies any conforming implementation.

- **Process is running after launch.** → `expect-running-app`
- **Launch diagnostic is emitted.** Stdout contains a line containing `Controls Gallery`
  before/at window presentation. → `wait-for-log "Controls Gallery"` /
  `expect-log "Controls Gallery"`
- **Window title names the gallery.** The frontmost window's title contains `Controls`.
  → `expect-ax` window AXTitle (substring) and/or `expect-ocr "Controls"`
- **Roster texts are visible.** `Click Me`, `Option A`, `Option B`, and a checkbox title
  beginning `Enable` are readable on screen. → `wait-for-ocr "Click Me"`,
  `expect-ocr "Option A"`, `expect-ocr "Option B"`, `expect-ocr "Enable"`
- **Placeholders are visible while the fields are empty.** `Type here` and `Password` are
  readable. → `expect-ocr "Type here"`, `expect-ocr "Password"` *(to confirm in-VM:
  placeholder rendering)*
- **Radio exclusivity.** When the user clicks `Option B`, then `Option B` becomes
  selected and `Option A` becomes deselected. → `click-at` Option B, `expect-ax` radio
  states *(to confirm in-VM)*
- **Checkbox toggles.** Clicking the checkbox flips its checked state; clicking again
  restores it. → `click-at`, `expect-ax` *(to confirm in-VM)*
- **Text field accepts input.** Clicking the text field and typing `abc` makes `abc`
  readable. → `click-at`, `type "abc"`, `expect-ocr "abc"` *(to confirm in-VM)*
- **Secure field does not echo cleartext.** After typing into the secure field, its
  accessibility value is not the typed cleartext. → `click-at`, `type "secret"`,
  `expect-ax` secure-field value *(to confirm in-VM)*
- **Slider is present within range.** A slider accessibility element exists with value in
  [0, 100]. → `expect-ax`
- **Boundary — slider clamps.** Driving the slider past either end leaves its value
  within [0, 100]. → `click-at` track ends, `expect-ax` *(to confirm in-VM)*
- **Boundary — stepper clamps.** Repeated increments stop at 10; repeated decrements stop
  at 0. → `click-at` stepper arrows repeatedly, `expect-ax` *(to confirm in-VM)*
- **Popup offers exactly three choices.** Opening the pop-up button reveals three items
  (texts are implementation-varying — assert the count, not the strings). → `click-at`
  popup, `expect-ax` menu-item count *(to confirm in-VM)*
- **Progress bar is preset.** The determinate progress indicator's value is roughly
  two-thirds of its range. → `expect-ax` value *(to confirm in-VM)*
- **Gallery structural elements exist.** Combo box, date picker, spinner (progress
  indicator), color well, and image accessibility elements are present. → `expect-ax`
  each
- **Quit menu terminates the app.** Sending Command-Q ends the process. → `chord cmd q`,
  then `expect-running-app` is false
- **(To confirm in-VM) Close-button behaviour.** Activating the close control hides the
  window; per §3.8 the process is expected to keep running (no close-to-quit opt-in). A
  scenario should record the *actual* observed behaviour. → `click-at` close button, then
  `expect-running-app`
