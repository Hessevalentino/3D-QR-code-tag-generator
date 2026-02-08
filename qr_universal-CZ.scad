// ============================================
// Generator QR stitku na klicenku
// ============================================
// Autor: HESSE Valentino
// Verze: 1.2 CZ
// ============================================

use <lib/qr_library.scad>
include <lib/tag_shapes.scad>

/* [Obsah QR kodu] */
Typ_QR = "Payment"; // [Payment:Platba (cesky QR), URL:Webova adresa, WiFi:WiFi sit, Text:Volny text, Phone:Telefonni cislo, VCard:Vizitka]
Cislo_Uctu = "123456789/0100";
Castka = 100; // [0:1:100000]
Mena = "CZK";
Zprava_Platby = "Platba za sluzby";
Variabilni_Symbol = "";
Webova_Adresa = "https://example.com";
WiFi_Nazev = "MojeSit";
WiFi_Heslo = "heslo123";
WiFi_Zabezpeceni = "WPA"; // [WPA:WPA/WPA2, WEP:WEP (zastarale), nopass:Otevrena sit]
WiFi_Skryta = false;
Volny_Text = "Ahoj svete!";
Telefonni_Cislo = "+420123456789";
Jmeno = "Jan";
Prijmeni = "Novak";
Email_Adresa = "jan.novak@example.com";
Telefon_Cislo = "+420123456789";

/* [Vzhled stitku] */
Tvar_Stitku = "Rectangle"; // [Rectangle:Obdelnik, Circle:Kruh, Rounded:Zaobleny obdelnik, Dog_Tag:Vojenska znamka]
Sirka_Stitku = 40; // [30:1:100]
Vyska_Stitku = 55; // [30:1:100]
Polomer_Zaobleni = 3; // [0:1:20]
Tloustka_Stitku = 3; // [1:0.5:10]
Sirka_Okraje = 3; // [0:0.5:10]

/* [Kulaty stitek] */
Prumer_Kruhu = 45; // [25:1:100]
Odsazeni_Otvoru = 3; // [2:0.5:15]

/* [Otvor na klice] */
Pridat_Otvor = true;
Prumer_Otvoru = 5; // [3:0.5:15]
Pozice_Otvoru_X = 0; // [-25:1:25]
Pozice_Otvoru_Y = 22; // [-25:1:25]
Okraj_Otvoru = 2; // [1:0.5:10]

/* [Nastaveni QR kodu] */
QR_Korekce_Chyb = "M"; // [L:Nizka (~7%), M:Stredni (~15%), Q:Vyssi (~25%), H:Nejvyssi (~30%)]
QR_Invertovat = false;
QR_Vyska_Modulu = 0.8; // [0:0.1:3]

/* [Export pro tisk] */
Exportovat = "Both"; // [Both:Nahled (obe casti), Tag:Pouze stitek (bez QR), QR:Pouze QR vzorec]

/* [Pokrocile nastaveni] */
Kvalita = 64; // [20:Nizka, 32:Stredni, 64:Vysoka, 100:Nejvyssi]

/* [Hidden] */
QR_Type = Typ_QR;
Payment_Account = Cislo_Uctu;
Payment_Amount = Castka;
Payment_Currency = Mena;
Payment_Message = Zprava_Platby;
Payment_Variable_Symbol = Variabilni_Symbol;
URL_Address = Webova_Adresa;
WiFi_SSID = WiFi_Nazev;
WiFi_Password = WiFi_Heslo;
WiFi_Security = WiFi_Zabezpeceni;
WiFi_Hidden = WiFi_Skryta;
Plain_Text = Volny_Text;
Phone_Number = Telefonni_Cislo;
VCard_First_Name = Jmeno;
VCard_Last_Name = Prijmeni;
VCard_Email = Email_Adresa;
VCard_Phone = Telefon_Cislo;
Tag_Shape = Tvar_Stitku;
Tag_Width = Sirka_Stitku;
Tag_Height = Vyska_Stitku;
Corner_Radius = Polomer_Zaobleni;
Tag_Thickness = Tloustka_Stitku;
Border_Width = Sirka_Okraje;
Circle_Diameter = Prumer_Kruhu;
Circle_Hole_Edge_Offset = Odsazeni_Otvoru;
Add_Keychain_Hole = Pridat_Otvor;
Hole_Diameter = Prumer_Otvoru;
Hole_Position_X = Pozice_Otvoru_X;
Hole_Position_Y = Pozice_Otvoru_Y;
Hole_Border = Okraj_Otvoru;
QR_Error_Correction = QR_Korekce_Chyb;
QR_Invert = QR_Invertovat;
QR_Module_Height = QR_Vyska_Modulu;
Export_Part = Exportovat;
Quality = Kvalita;
$fn = $preview ? 20 : Quality;

function eff_width() = Tag_Shape == "Circle" ? Circle_Diameter : Tag_Width;
function eff_height() = Tag_Shape == "Circle" ? Circle_Diameter : Tag_Height;

function circle_hole_y() = Circle_Diameter/2 - Circle_Hole_Edge_Offset - Hole_Diameter/2;

function hole_x() = Hole_Position_X;
function hole_y() = Tag_Shape == "Circle" ? circle_hole_y() : Hole_Position_Y;

function generate_payment_qr() =
    let(
        amount_str = Payment_Amount > 0 ? str("*AM:", Payment_Amount) : "",
        vs_str = Payment_Variable_Symbol != "" ? str("*X-VS:", Payment_Variable_Symbol) : "",
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
