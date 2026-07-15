import AppKit
let outputPath = "/Users/karimbaisuev/.codex/visualizations/2026/07/14/019f61b0-4e2b-72d0-9a0a-485b081ad54e/pickup-haul-hvac-security-full-board.png"
let stylePath = "/Users/karimbaisuev/.codex/visualizations/2026/07/14/019f61b0-4e2b-72d0-9a0a-485b081ad54e/pickup-haul-style-board.png"

let coreRoot = "/tmp/codex-remote-attachments/019f61b0-4e2b-72d0-9a0a-485b081ad54e/3137EBD2-EF39-4DCA-BA1A-79F099572E63"
let accentRoot = "/tmp/codex-remote-attachments/019f61b0-4e2b-72d0-9a0a-485b081ad54e/D02CCDAD-FC6C-42D2-996E-9107FB7AFD67"

let items: [(String, String)] = [
    ("Core 01 · unfinished room", "\(coreRoot)/1-Photo-1.jpg"),
    ("Core 02 · prepared room", "\(coreRoot)/2-Photo-2.jpg"),
    ("Core 03 · duct materials", "\(coreRoot)/3-Photo-3.jpg"),
    ("Core 04 · materials pickup", "\(coreRoot)/4-Photo-4.jpg"),
    ("Core 05 · rooftop work", "\(coreRoot)/5-Photo-5.jpg"),
    ("Core 06 · installed duct", "\(coreRoot)/6-Photo-6.jpg"),
    ("Core 07 · blower detail A", "\(coreRoot)/7-Photo-7.jpg"),
    ("Core 08 · blower detail B", "\(coreRoot)/8-Photo-8.jpg"),
    ("Core 09 · finished pegboard", "\(coreRoot)/9-Photo-9.jpg"),
    ("Core 10 · finished workshop", "\(coreRoot)/10-Photo-10.jpg"),
    ("Accent 01 · security setup", "\(accentRoot)/1-Photo-1.jpg"),
    ("Accent 02 · indoor hub", "\(accentRoot)/2-Photo-2.jpg"),
    ("Accent 03 · exterior camera", "\(accentRoot)/3-Photo-3.jpg"),
    ("Accent 04 · cabinet install", "\(accentRoot)/4-Photo-4.jpg")
]

let width = 2400
let height = 2280
let padding: CGFloat = 36
let gap: CGFloat = 20
let columns = 4
let styleHeight: CGFloat = 480
let photoTop = CGFloat(height) - padding - styleHeight - gap
let photoAreaHeight = photoTop - padding
let rows = 4
let cellWidth = (CGFloat(width) - padding * 2 - gap * CGFloat(columns - 1)) / CGFloat(columns)
let cellHeight = (photoAreaHeight - gap * CGFloat(rows - 1)) / CGFloat(rows)

func drawCover(_ image: NSImage, in rect: NSRect) {
    let sourceSize = image.size
    let sourceAspect = sourceSize.width / sourceSize.height
    let targetAspect = rect.width / rect.height
    var sourceRect = NSRect(origin: .zero, size: sourceSize)
    if sourceAspect > targetAspect {
        let croppedWidth = sourceSize.height * targetAspect
        sourceRect.origin.x = (sourceSize.width - croppedWidth) / 2
        sourceRect.size.width = croppedWidth
    } else {
        let croppedHeight = sourceSize.width / targetAspect
        sourceRect.origin.y = (sourceSize.height - croppedHeight) / 2
        sourceRect.size.height = croppedHeight
    }
    image.draw(in: rect, from: sourceRect, operation: .copy, fraction: 1)
}

func drawLabel(_ text: String, in rect: NSRect) {
    let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 22, weight: .semibold),
        .foregroundColor: NSColor.white
    ]
    let textSize = text.size(withAttributes: attributes)
    let labelRect = NSRect(x: rect.minX + 16, y: rect.minY + 16, width: min(textSize.width + 28, rect.width - 32), height: 42)
    NSColor(calibratedWhite: 0.015, alpha: 0.86).setFill()
    NSBezierPath(roundedRect: labelRect, xRadius: 21, yRadius: 21).fill()
    text.draw(at: NSPoint(x: labelRect.minX + 14, y: labelRect.minY + 9), withAttributes: attributes)
}

guard let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: width,
    pixelsHigh: height,
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
) else { fatalError("Unable to create bitmap") }

NSGraphicsContext.saveGraphicsState()
guard let context = NSGraphicsContext(bitmapImageRep: rep) else { fatalError("Unable to create graphics context") }
NSGraphicsContext.current = context
NSColor(calibratedRed: 0.031, green: 0.031, blue: 0.051, alpha: 1).setFill()
NSBezierPath(rect: NSRect(x: 0, y: 0, width: width, height: height)).fill()

guard let styleImage = NSImage(contentsOfFile: stylePath) else { fatalError("Unable to load style board") }
let styleRect = NSRect(x: padding, y: CGFloat(height) - padding - styleHeight, width: CGFloat(width) - padding * 2, height: styleHeight)
NSGraphicsContext.saveGraphicsState()
NSBezierPath(roundedRect: styleRect, xRadius: 34, yRadius: 34).addClip()
drawCover(styleImage, in: styleRect)
NSGraphicsContext.restoreGraphicsState()
drawLabel("APPROVED PICKUP HAUL SITE STYLE · VISUAL GROUNDING ONLY", in: styleRect)

for (index, item) in items.enumerated() {
    guard let image = NSImage(contentsOfFile: item.1) else { fatalError("Unable to load \(item.1)") }
    let column = index % columns
    let rowFromTop = index / columns
    let row = rows - 1 - rowFromTop
    let rect = NSRect(
        x: padding + CGFloat(column) * (cellWidth + gap),
        y: padding + CGFloat(row) * (cellHeight + gap),
        width: cellWidth,
        height: cellHeight
    )
    NSGraphicsContext.saveGraphicsState()
    NSBezierPath(roundedRect: rect, xRadius: 28, yRadius: 28).addClip()
    drawCover(image, in: rect)
    NSGraphicsContext.restoreGraphicsState()
    drawLabel(item.0, in: rect)
}

context.flushGraphics()
NSGraphicsContext.restoreGraphicsState()

guard let data = rep.representation(using: .png, properties: [:]) else { fatalError("Unable to encode PNG") }
try data.write(to: URL(fileURLWithPath: outputPath))
print(outputPath)
