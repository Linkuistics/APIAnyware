# UI Controls Gallery — TestAnyware Validation

## Prerequisites
- App binary built and located in shared directory
- macOS VM booted and TestAnyware server running

## Validation Steps

### 1. Launch and Window
- [ ] Launch the app
- [ ] Verify window title is "UI Controls Gallery"
- [ ] Verify window is resizable

### 2. Section Visibility (scroll as needed)
- [ ] "Text Fields" section visible with editable field and password field
- [ ] "Buttons" section visible with push button, checkbox, and radio buttons
- [ ] "Sliders" section visible with horizontal slider and value label
- [ ] "Popup & Combo" section visible with dropdown and combo box
- [ ] "Date Picker" section visible
- [ ] "Progress Indicators" section visible with bar and spinner
- [ ] "Stepper" section visible with stepper control and value label
- [ ] "Color & Image" section visible with color well and image

### 3. Text Field Interaction
- [ ] Click editable text field and type text — verify it appears
- [ ] Click secure text field and type — verify input is masked (dots)
- [ ] Verify placeholder text is visible when fields are empty

### 4. Button Interaction
- [ ] Click "Click Me" push button — no crash
- [ ] Toggle checkbox — verify visual state changes
- [ ] Click radio buttons — verify only one is selected at a time

### 5. Slider Interaction
- [ ] Drag slider — verify value label updates
- [ ] Verify value is between 0 and 100
- [ ] Verify initial value is approximately 50

### 6. Popup and Combo
- [ ] Click popup button — verify dropdown shows "Small", "Medium", "Large"
- [ ] Select an item — verify selection updates
- [ ] Verify combo box shows "Red", "Green", "Blue"
- [ ] Verify combo box is editable (can type custom text)

### 7. Progress Indicators
- [ ] Verify determinate bar shows approximately 65% fill
- [ ] Verify indeterminate spinner is animating

### 8. Scrolling
- [ ] If content exceeds window height, verify scrolling works
- [ ] Resize window smaller and verify scroll activates
- [ ] Resize window larger and verify all sections visible

### 9. Visual Quality
- [ ] All section headers are bold and readable
- [ ] No overlapping controls
- [ ] Standard macOS appearance (native controls, not custom-drawn)
- [ ] Color well shows a blue color
