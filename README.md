# QR Code Keychain & Payment Tag Generator

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![OpenSCAD](https://img.shields.io/badge/OpenSCAD-parametric-blue.svg)](https://openscad.org/)
[![3D Printing](https://img.shields.io/badge/3D%20Print-ready-orange.svg)](#export-for-ams-multi-material)
[![Open Source Hardware](https://img.shields.io/badge/OSHW-open--hardware-brightgreen.svg)](https://www.oshwa.org/)

Parametric OpenSCAD generator for 3D-printable keychains with embedded QR codes. Supports Czech payment QR (SPD), URLs, WiFi, vCards, phone numbers and plain text. Designed for multi-material (AMS) printing.

---

<img width="1720" height="800" alt="image" src="https://github.com/user-attachments/assets/21a358ec-2a48-46d2-b582-2a83badc14db" />


## Features

- **6 QR code types** -- Czech Payment (SPD), URL, WiFi, vCard, Phone, Plain Text
- **4 tag shapes** -- Rectangle, Circle, Rounded Rectangle, Dog Tag
- **Multi-material export** -- separate STL files for tag base and QR pattern (Bambu Lab AMS compatible)
- **Full Customizer support** -- all parameters adjustable via OpenSCAD GUI
- **Bilingual UI** -- English (`qr_universal.scad`) and Czech (`qr_universal-CZ.scad`)

## Project Structure

```
.
├── qr_universal.scad        # Main file (English UI)
├── qr_universal-CZ.scad     # Main file (Czech UI)
└── lib/
    ├── qr_library.scad      # QR code generation library (scadqr)
    └── tag_shapes.scad       # Tag shape modules
```

## Requirements

- [OpenSCAD](https://openscad.org/) 2021.01 or newer
- No external dependencies -- QR library is included

## Usage

1. Open `qr_universal.scad` (EN) or `qr_universal-CZ.scad` (CZ) in OpenSCAD
2. Open the **Customizer** panel (Window > Customizer)
3. Set QR content, tag shape, dimensions and hole parameters
4. Preview with **F5**, render with **F6**, export STL with **F7**

## Export for AMS Multi-Material

For two-color printing (e.g. Bambu Lab AMS):

| Export Mode | Description | Use |
|---|---|---|
| **Both** | Preview of tag + QR together | Visual check only |
| **Tag** | Tag base with recessed QR area | Export as `tag.stl` |
| **QR** | QR pattern that fits into recess | Export as `qr.stl` |

1. Set `Export Part = Tag` > Render (F6) > Export STL
2. Set `Export Part = QR` > Render (F6) > Export STL
3. Import both STL files into your slicer, assign different materials

## Czech Payment QR (SPD Standard)

For Czech payment QR codes, the account number **must be in IBAN format**.

### How to Convert Czech Account Number to IBAN

**Step-by-step guide:**

1. **Find your Czech account number** (format: `prefix-account/bank_code`)
   - Example: `123456789/0100` or `19-123456789/0100`

2. **Open IBAN calculator:** https://www.penize.cz/kalkulacky/vypocet-iban

3. **Enter your account details:**
   - Prefix (předčíslí): `19` (if you have one, otherwise leave empty)
   - Account number (číslo účtu): `123456789`
   - Bank code (kód banky): `0100`

4. **Copy the generated IBAN:**
   - Result: `CZ5855000000001265098001`

5. **Paste into OpenSCAD:**
   - English version: `Payment_Account = "CZ5855000000001265098001";`
   - Czech version: `Cislo_Uctu = "CZ5855000000001265098001";`

**The calculator also provides:**
- ✅ Bidirectional conversion (IBAN → Czech format)
- ✅ SWIFT/BIC bank codes
- ✅ Validation using Czech National Bank methodology

## Parameters

| Section | Key Parameters |
|---|---|
| QR Content | QR type, payment account, URL, WiFi credentials, vCard data |
| Tag Design | Shape, width, height, corner radius, thickness, border |
| Circle Tag | Diameter, hole edge offset |
| Keychain Hole | Enable/disable, diameter, X/Y position, border |
| QR Settings | Error correction level, invert, module height |
| Export | Part selection (Both / Tag / QR) |
| Advanced | Render quality |

## Author

**HESSE Valentino** -- Version 1.2

## License

This project is open source under the [MIT License](LICENSE).

