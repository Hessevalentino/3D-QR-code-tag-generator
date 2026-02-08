module create_tag_base() {
    if (Tag_Shape == "Rectangle") {
        if (Corner_Radius > 0) {
            rounded_rectangle(Tag_Width, Tag_Height, Tag_Thickness, Corner_Radius);
        } else {
            translate([-Tag_Width/2, -Tag_Height/2, 0])
                cube([Tag_Width, Tag_Height, Tag_Thickness]);
        }
    } else if (Tag_Shape == "Circle") {
        cylinder(h=Tag_Thickness, d=Circle_Diameter, $fn=$preview ? 128 : 256);
    } else if (Tag_Shape == "Rounded") {
        rounded_rectangle(Tag_Width, Tag_Height, Tag_Thickness, Corner_Radius);
    } else if (Tag_Shape == "Dog_Tag") {
        dog_tag_shape(Tag_Width, Tag_Height, Tag_Thickness);
    }
}

module rounded_rectangle(w, h, thick, radius) {
    clamped_r = min(radius, min(w, h)/2 - 0.01);

    if (clamped_r > 0) {
        hull() {
            for (x = [-1, 1], y = [-1, 1]) {
                translate([x * (w/2 - clamped_r), y * (h/2 - clamped_r), 0])
                    cylinder(h=thick, r=clamped_r);
            }
        }
    } else {
        translate([-w/2, -h/2, 0])
            cube([w, h, thick]);
    }
}

module dog_tag_shape(w, h, thick) {
    difference() {
        rounded_rectangle(w, h, thick, min(w, h) * 0.1);
        translate([0, h/2 - w*0.15, -0.01])
            cylinder(h=thick+0.02, d=w*0.3, $fn=$preview ? 16 : 32);
    }
}

