// make-fixture.swift — regenerate fixtures/fixture.pdf, the PDF the scenario
// suite provisions into the VM (the app ships no document — spec §6; the open
// panel is the only source).
//
//   swift make-fixture.swift [output.pdf]     (default: fixture.pdf in cwd)
//
// Fixture rule (spec §13 / observable-state.md): N ≥ 3 pages so first-boundary,
// last-boundary, and interior states are all reachable, each page carrying an
// OCR-distinguishable marker. Each page gets a distinct pale background plus a
// big black "PAGE n" in the upper third — upper third so the marker is visible
// at fit-width auto-scale zoom without scrolling (the 612x792 page is ~2x the
// 720x492 view; only the top ~435pt shows after open/navigation).
import CoreGraphics
import CoreText
import Foundation

let output = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "fixture.pdf"
var mediaBox = CGRect(x: 0, y: 0, width: 612, height: 792)
guard let ctx = CGContext(URL(fileURLWithPath: output) as CFURL, mediaBox: &mediaBox, nil) else {
    fatalError("cannot create PDF context at \(output)")
}

let backgrounds: [(CGFloat, CGFloat, CGFloat)] = [
    (1.00, 0.90, 0.90), // page 1 — pale red
    (0.90, 1.00, 0.90), // page 2 — pale green
    (0.90, 0.93, 1.00), // page 3 — pale blue
]
let font = CTFontCreateWithName("Helvetica-Bold" as CFString, 96, nil)
let black = CGColor(red: 0, green: 0, blue: 0, alpha: 1)

for (index, bg) in backgrounds.enumerated() {
    ctx.beginPDFPage(nil)
    ctx.setFillColor(red: bg.0, green: bg.1, blue: bg.2, alpha: 1)
    ctx.fill(mediaBox)
    let attrs: [CFString: Any] = [
        kCTFontAttributeName: font,
        kCTForegroundColorAttributeName: black,
    ]
    let text = "PAGE \(index + 1)" as CFString
    let attributed = CFAttributedStringCreate(kCFAllocatorDefault, text, attrs as CFDictionary)!
    let line = CTLineCreateWithAttributedString(attributed)
    let width = CGFloat(CTLineGetTypographicBounds(line, nil, nil, nil))
    ctx.textPosition = CGPoint(x: (mediaBox.width - width) / 2, y: 560)
    CTLineDraw(line, ctx)
    ctx.endPDFPage()
}
ctx.closePDF()
print("wrote \(output)")
