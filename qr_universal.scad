// ============================================
// QR Code Keychain & Payment Tag Generator
// ============================================
// Author: HESSE Valentino
// Version: 1.2
// ============================================

use <lib/qr_library.scad>
include <lib/tag_shapes.scad>

/* [QR Code Content] */
QR_Type = "Payment"; // [Payment:Czech Payment QR, URL:Website URL, WiFi:WiFi Network, Text:Plain Text, Phone:Phone Number, VCard:Contact Card]
// IMPORTANT: For Czech payment QR (SPD standard), account number MUST be in IBAN format
// Example: CZ5855000000001265098001 or CZ5855000000001265098001+RZBCCZPP (with BIC)
// Convert Czech format (123456789/0100) to IBAN at: https://www.penize.cz/kalkulacky/vypocet-iban
Payment_Account = "CZ5855000000001265098001";
Payment_Amount = 100.00; // [0:0.01:100000]
Payment_Currency = "CZK";
Payment_Message = "PAYMENT FOR SERVICES";
Payment_Variable_Symbol = "";
URL_Address = "https://example.com";
WiFi_SSID = "MyNetwork";
WiFi_Password = "password123";
WiFi_Security = "WPA"; // [WPA:WPA/WPA2, WEP:WEP (obsolete), nopass:Open Network]
WiFi_Hidden = false;
Plain_Text = "Hello World!";
Phone_Number = "+420123456789";
VCard_First_Name = "John";
VCard_Last_Name = "Doe";
VCard_Email = "john.doe@example.com";
VCard_Phone = "+420123456789";

/* [Tag Design] */
Tag_Shape = "Rectangle"; // [Rectangle:Rectangular Tag, Circle:Circular Tag, Rounded:Rounded Rectangle, Dog_Tag:Dog Tag Shape]
Tag_Width = 40; // [30:1:100]
Tag_Height = 55; // [30:1:100]
Corner_Radius = 3; // [0:1:20]
Tag_Thickness = 3; // [1:0.5:10]
Border_Width = 3; // [0:0.5:10]

/* [Circle Tag] */
Circle_Diameter = 45; // [25:1:100]
Circle_Hole_Edge_Offset = 3; // [2:0.5:15]

/* [Keychain Hole] */
Add_Keychain_Hole = true;
Hole_Diameter = 5; // [3:0.5:15]
Hole_Position_X = 0; // [-25:1:25]
Hole_Position_Y = 22; // [-25:1:25]
Hole_Border = 2; // [1:0.5:10]

/* [QR Code Settings] */
QR_Error_Correction = "M"; // [L:Low (~7%), M:Medium (~15%), Q:Quartile (~25%), H:High (~30%)]
QR_Invert = false; // Invert QR code colors (white on black)
QR_Module_Height = 0.8; // [0:0.1:3]

/* [Export] */
Export_Part = "Both"; // [Both:Preview (both parts), Tag:Tag only (base without QR), QR:QR pattern only]

/* [Advanced Settings] */
Quality = 64; // [20:Low, 32:Medium, 64:High, 100:Very High]

/* [Hidden] */
$fn = $preview ? 20 : Quality;

function eff_width() = Tag_Shape == "Circle" ? Circle_Diameter : Tag_Width;
function eff_height() = Tag_Shape == "Circle" ? Circle_Diameter : Tag_Height;

function circle_hole_y() = Circle_Diameter/2 - Circle_Hole_Edge_Offset - Hole_Diameter/2;

function hole_x() = Hole_Position_X;
function hole_y() = Tag_Shape == "Circle" ? circle_hole_y() : Hole_Position_Y;

// Generate Czech payment QR code according to SPD (Short Payment Descriptor) standard
// Specification: https://qr-platba.cz/pro-vyvojare/specifikace-formatu/
// Format: SPD*1.0*ACC:{IBAN}*CC:{currency}*AM:{amount}*X-VS:{variable_symbol}*MSG:{message}
// Note: ACC (account number in IBAN format) is MANDATORY
function generate_payment_qr() =
    let(
        // Format amount with decimal point (max 2 decimal places)
        amount_str = Payment_Amount > 0 ? str("*AM:", Payment_Amount) : "",
        vs_str = Payment_Variable_Symbol != "" ? str("*X-VS:", Payment_Variable_Symbol) : "",
        // Convert message to uppercase for better QR code efficiency (alphanumeric mode)
        msg_str = Payment_Message != "" ? str("*MSG:", Payment_Message) : ""
    )
    str("SPD*1.0*ACC:", Payment_Account, "*CC:", Payment_Currency, amount_str, vs_str, msg_str);

function qr_y_offset() =
    Tag_Shape == "Circle" ?
        let(
            r = Circle_Diameter/2,
            top_limit = Add_Keychain_Hole ?
                hole_y() - Hole_Diameter/2 - Hole_Border : r - Border_Width,
            qr_s = qr_available_size(),
            center_y = (top_limit + (-r + Border_Width)) / 2
        )
        center_y
    :
        Add_Keychain_Hole ?
            let(
                hole_bottom = hole_y() - Hole_Diameter/2 - Hole_Border,
                available_below = hole_bottom + eff_height()/2,
                center_y = -eff_height()/2 + available_below/2
            )
            center_y
        : 0;

function qr_available_size() =
    Tag_Shape == "Circle" ?
        let(
            r = Circle_Diameter/2,
            top_limit = Add_Keychain_Hole ?
                hole_y() - Hole_Diameter/2 - Hole_Border : r - Border_Width,
            bottom_limit = -r + Border_Width,
            avail_h = top_limit - bottom_limit,
            center_y = (top_limit + bottom_limit) / 2,
            half_chord = sqrt(max(0, r*r - center_y*center_y)),
            avail_w = 2 * half_chord - 2*Border_Width,
            size = min(avail_w, avail_h)
        )
        size
    :
        let(
            available_w = eff_width() - 2*Border_Width,
            available_h = Add_Keychain_Hole ?
                let(
                    hole_bottom = hole_y() - Hole_Diameter/2 - Hole_Border,
                    space_below = hole_bottom + eff_height()/2
                )
                space_below - 2*Border_Width
            : eff_height() - 2*Border_Width
        )
        min(available_w, available_h);

module create_qr_2d() {
    let(
        msg =
            QR_Type == "Payment" ? generate_payment_qr() :
            QR_Type == "URL" ? URL_Address :
            QR_Type == "WiFi" ? qr_wifi(WiFi_SSID, WiFi_Password, WiFi_Security, WiFi_Hidden) :
            QR_Type == "Text" ? Plain_Text :
            QR_Type == "Phone" ? qr_phone_call(Phone_Number) :
            QR_Type == "VCard" ? qr_vcard(VCard_Last_Name, VCard_First_Name, email=VCard_Email, phone=VCard_Phone) :
            "ERROR",
        size_modules = qr_size(msg, QR_Error_Correction),
        physical_size = qr_available_size(),
        scale_factor = physical_size / size_modules,
        y_off = qr_y_offset()
    )
    translate([-physical_size/2, y_off - physical_size/2, 0])
        scale([scale_factor, scale_factor, 1])
            qr(msg, error_correction=QR_Error_Correction, width=size_modules, height=size_modules, thickness=0);
}

if (Export_Part == "Both") {
    difference() {
        create_tag_base();
        if (Add_Keychain_Hole) {
            translate([hole_x(), hole_y(), -0.01])
                cylinder(h=Tag_Thickness+0.02, d=Hole_Diameter, $fn=$preview ? 16 : 32);
        }
    }
    translate([0, 0, QR_Invert ? -0.01 : Tag_Thickness]) {
        if (QR_Invert) {
            linear_extrude(QR_Module_Height + 0.02)
                create_qr_2d();
        } else {
            linear_extrude(QR_Module_Height)
                create_qr_2d();
        }
    }
} else if (Export_Part == "Tag") {
    difference() {
        create_tag_base();
        if (Add_Keychain_Hole) {
            translate([hole_x(), hole_y(), -0.01])
                cylinder(h=Tag_Thickness+0.02, d=Hole_Diameter, $fn=$preview ? 16 : 32);
        }
        translate([0, 0, Tag_Thickness - QR_Module_Height])
            linear_extrude(QR_Module_Height + 0.01)
                create_qr_2d();
    }
} else if (Export_Part == "QR") {
    translate([0, 0, Tag_Thickness - QR_Module_Height])
        linear_extrude(QR_Module_Height)
            create_qr_2d();
}
