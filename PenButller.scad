// Customizable Pen Butler by DrLex
// Based on "Pen butler" by sotenck (thing:1670728)
// and "Wall-mounted Pen Butler" by DrLex (thing:1676070).
// License: Creative Commons - Attribution

/* [General] */
// Number of slots in the holder
numSlots=4; //[1:10]

// Diameter of the slot space (max pen diameter)
maxPenDia = 13; //[10:.1:20]

// Distance between outer edges
outerWidth=70; //[40:1:120]

// Type of mounting point at top and bottom. A modular top can be attached to a modular bottom.
topType = "holes"; //["holes", "modular", "none"]
bottomType = "modular"; //["holes", "modular"]

// Generate what kind of model? For a desk version, print the "single" model twice and 1 "base" model, and assemble those 3 parts.
generateModel = "wall"; //["wall", "single", "base"]

// Diameter of the mounting holes
holeDiameter = 3.0; //[0:.1:5]

// Tolerance for modular dovetail joint
modularTolerance = 0.1; //[0:.01:.3]


/* [Hidden] */
unitScale = maxPenDia/13;
unitShift = maxPenDia-13;
slotR = maxPenDia/2;
outerR = slotR + 1.65;
avgR = (slotR + outerR)/2;
unitDist = 20 * unitScale;
outerWidX = 2 + outerWidth;
holdWid = 10;
innerWid = outerWidth - 2*holdWid;
holeFn = max(round(4*holeDiameter), 3);
holeRadius = (holeDiameter/2) / cos(180/holeFn);

module unitAdditions() {
    union() {
        translate([0, 11.75, 9*unitScale]) {
            difference() {
                rotate([0, 90, 0]) cylinder(r=outerR, h=outerWidth, center=true, $fn=48);
                translate([-outerWidX/2, 0, 0]) rotate([37.5, 0, 0]) cube([outerWidX, 10, 20]);
            }
            rotate([-52.5, 0, 0]) translate([0, -avgR, 0]) rotate([0, 90, 0]) cylinder(r=.85, h=outerWidth, center=true, $fn=16);
        }
    }
}

module unitSubtractions() {
    hull() {
        translate([0, 11.75, 9*unitScale]) rotate([0, 90, 0]) cylinder(r=slotR, h=outerWidX, center=true, $fn=48);
        translate([0, 10.2+unitScale*7, 9*unitScale+1.5]) rotate([0, 90, 0]) cylinder(r=slotR, h=outerWidX, center=true, $fn=48);
    }
}

module holeTab() {
    translate([0, 0, 1.2]) {
        difference() {
            union() {
                translate([0, -5, 0]) cube([holdWid, 10, 2.4], center=true);
                cylinder(r=holdWid/2, h=2.4, center=true, $fn=32);
            }
            if(holeDiameter > 0) {
                cylinder(r=holeRadius, h=5, $fn=holeFn, center=true);
            }
        }
    }
}

module fancyFillet() {
    translate([0, -holdWid/2-2, 2.4]) rotate([0,-90,0]) linear_extrude(holdWid, center=true) polygon([[0, 0], [2.25, 0], [2.25, .6], [2.1, 1.2], [1.6, 1.8], [0.65, 2.4], [0.15, 3.0], [0, 3.6]]);
}

module modularPoly() {
    polygon([[2.2, -.1], [3.4, 5], [3.4, 6], [-3.4, 6], [-3.4, 5], [-2.2, -.1]]);
}

module modularTab() {
    translate([0, 0, 1.2]) linear_extrude(2.4, center=true) modularPoly();
}

module modularSlot() {
    translate([0, 0, 1.4]) linear_extrude(3.2, center=true) {
        if(modularTolerance == 0) {
            modularPoly();
        }
        else {
            offset(delta = modularTolerance) modularPoly();
        }
    }
}

module generateButler() {
    difference() {
        union() {
            translate([-outerWidth/2, 0, 0]) cube([outerWidth, numSlots*unitDist, 10*unitScale]);
            for(i=[0:numSlots-1]) {
                translate([0, i*unitDist+unitShift, 0]) unitAdditions();
            }
        }
        for(i=[0:numSlots-1]) {
            translate([0, i*unitDist+unitShift, 0]) unitSubtractions();
        }
        // Finishing touch at the bottom
        translate([0, unitShift-unitDist, 0]) unitSubtractions();
        
        translate([-innerWid/2, -1, -1]) cube([innerWid, 10+numSlots*unitDist, 40]);
        if(generateModel == "single") {
            translate([-innerWid/2-holdWid-1, -1, -1]) cube([innerWid, 10+numSlots*unitDist, 40]);
        }

        if(bottomType == "modular") {
            translate([(innerWid+holdWid)/2, 0, 0]) modularSlot();
            if(generateModel != "single") {
                translate([-(innerWid+holdWid)/2, 0, 0]) modularSlot();
            }
        }
    }

    if(generateModel != "single") {
        for(i=[1:2*numSlots]) {
            translate([-(1+innerWid)/2, i*unitDist/2-6, 0]) cube([1+innerWid, 2.27, 1.4]);
        }
    }

    if(topType == "holes") {
        translate([(innerWid+holdWid)/2, numSlots*unitDist + 2 + holdWid/2, 0]) {
            holeTab();
            fancyFillet();
        }
        if(generateModel != "single") {
            translate([-(innerWid+holdWid)/2, numSlots*unitDist + 2 + holdWid/2, 0]) {
                holeTab();
                fancyFillet();
            }
        }
    }
    else if(topType == "modular") {
        translate([(innerWid+holdWid)/2, numSlots*unitDist, 0]) modularTab();
        if(generateModel != "single") {
            translate([-(innerWid+holdWid)/2, numSlots*unitDist, 0]) modularTab();
        }
    }
        

    if(bottomType == "holes") {
        translate([(innerWid+holdWid)/2, - holdWid/2, 0]) mirror([0,1,0]) {
            holeTab();
            fancyFillet();
        }
        if(generateModel != "single") {
            translate([-(innerWid+holdWid)/2, - holdWid/2, 0]) mirror([0,1,0]) {
                holeTab();
                fancyFillet();
            }
        }
    }
}

module generateBase() {
    baseDepth = max(20, .575 * numSlots*unitDist);
    insOffset = 1.37 * (maxPenDia - 13)/7;
    translate([-outerWidth/2, 0, 0]) difference() {
        union() {
            cube([outerWidth, baseDepth, 5]);
            cube([outerWidth, 3, 7]);
        }
        translate([10,-10,-1]) cube([innerWid, baseDepth, 10]);
        translate([-1, 5 + insOffset, 2.35]) rotate([55,0,0]) {
            cube([outerWidX, 20, 20]);
        }
        translate([-1, -2.3, 0]) rotate([55,0,0]) {
            cube([outerWidX, 20, 20]);
        }
    }
    translate([0, 5 + insOffset, 2.35]) rotate([55,0,0]) {
        translate([(innerWid+holdWid)/2, 0, 0]) modularTab();
        translate([-(innerWid+holdWid)/2, 0, 0]) modularTab();
    }
}

if(generateModel != "base") {
    generateButler();
}
else {
    generateBase();
}