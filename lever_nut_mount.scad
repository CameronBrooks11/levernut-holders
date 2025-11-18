/* 
WAGO 221 mount

Creates a single row or double row set of 221 blocks
with mounting tabs/ears at either end.

Initially created - 2017/01/01 by Joo Chung
Further developed - 2025-11-06 by Cameron K. Brooks 
*/

$fn = $preview ? 32 : 64;
z_fight = $preview ? 0.01 : 0;

/* [User Customization] */

// vector of blocks. e.g. [5,3,2], [5,5,5], [2], [3]
blocks_config = [2, 2, 2, 2, 2];

style_config = "horizontal_mirrored"; // ["horizontal_mirrored", "horizontal", "vertical_mirrored", "vertical"]

// Tabs - include or exclude mounting tabs
tabs = true; // [true, false]

// radius of hole in tab
tab_radius = 2.6;

// thickness of tab
tab_height = 4;

// Set width and length of the tab. (tab is basically a square)
tab_width = 10;

module end_customizer(){} 

// Internal Parameters and Functions

// width of a single conductor
conductor_width = 5.6;

// block transparent plastic border
border = 1.75;

// depth of the block
block_depth = 18.25;

// manufacturing allowance
allowance = 0.2;

// Functions
function block_width(x) = conductor_width * x + border + allowance; // block width
function mount_width(i, i_max, blocks) =
  (
    i == 0 ? block_width(blocks[i]) + 2 + mount_width(i + 1, i_max, blocks)
    : (i < i_max ? block_width(blocks[i]) + 2 + mount_width(i + 1, i_max, blocks) : 0)
  ); // mount width (index, max index)

// Modules
module tab(width, hole, thickness) {
  difference() {
    union() {
      cylinder(thickness, width / 2, width / 2, true);
      translate([width / 4, 0, 0]) cube([width / 2, width, thickness], true);
    }
    cylinder(width, hole, hole, true);
  }
}

module shoulder(depth) {
  difference() {
    union() {
      cube([2, block_depth, 3.25], false);
      translate([0, 0, 3.25]) cube([2.25, block_depth, 2], false);
    }
    translate([-z_fight / 2, -z_fight, 2 - z_fight / 2]) cube([2.25 + z_fight, 2 + z_fight, 3.25 + z_fight], false);
    translate([2 + z_fight, block_depth - 4 + z_fight / 2, 2 - z_fight / 2]) cube([0.25, 4, 3.25 + z_fight], false);
  }
}

module backshoulder(height) {
  difference() {
    union() {
      translate([0, 2, 0]) cube([2, 1.25, 10.15]);
      cube([2.25, 2, 10.15]);
    }
    translate([-z_fight / 2, -z_fight / 2, 10.15 - 2]) cube([2.25 + z_fight, 3.25 + z_fight, 2 + z_fight]);
    translate([2 - z_fight, -z_fight / 2, 2 - z_fight / 2]) cube([1.25 + z_fight, 3.25 + z_fight, 3.25 + z_fight]);
  }
}

// WAGO 221 block
module block(nconn) {
  blockwidth = block_width(nconn);

  // base
  translate([2, 2, 0]) cube([blockwidth, block_depth, 2], false);

  // back headboard
  translate([0, block_depth + 2, 0]) cube([blockwidth + 4, 2, 10.15], false);

  // back lip
  translate([0, block_depth, 10.15]) cube([blockwidth + 4, 4, 2], false);

  // front lip
  translate([0, 0, 0]) cube([blockwidth + 4, 2, 2.5], false);

  // left shoulder and right shoulders
  translate([0, 2, 0]) shoulder();
  translate([blockwidth + 4, 2, 0]) mirror([1, 0, 0]) shoulder();

  // back left and shoulder
  translate([0, block_depth - 1.25, 0]) backshoulder();
  translate([blockwidth + 4, block_depth - 1.25, 0]) mirror([1, 0, 0]) backshoulder();
}

module lever_nut_mount(blocks) {

  mountwidth = mount_width(0, len(blocks), blocks);
  if (style_config == "horizontal") {
    // No mirror. Single row of blocks
    // create array of blocks
    for (i = [0:len(blocks) - 1]) {
      offset = (i == 0) ? tab_width : tab_width + mount_width(0, i, blocks);
      translate([offset, 0, 0]) block(blocks[i]);
    }

    // left and right tabs
    if (tabs) {
      translate([tab_width / 2, (block_depth + 4) / 2, tab_height / 2])
        tab(tab_width, tab_radius, tab_height);
      translate([mountwidth + 2 + tab_width + tab_width / 2, (block_depth + 4) / 2, tab_height / 2])
        mirror([1, 0, 0])
          tab(tab_width, tab_radius, tab_height);
    }
  } else if (style_config == "horizontal_mirrored") {
    // Row #1.
    for (i = [0:len(blocks) - 1]) {
      offset = (i == 0) ? tab_width : tab_width + mount_width(0, i, blocks);
      translate([offset, -block_depth - 6, -1])
        block(blocks[i]);
    }

    // Row #2. Flip
    mirror([0, 1, 0])for (i = [0:len(blocks) - 1]) {
      offset = (i == 0) ? tab_width : tab_width + mount_width(0, i, blocks);
      translate([offset, -block_depth, -1]) block(blocks[i]);
    }

    // left and right tabs
    if (tabs) {
      translate([tab_width / 2, -3, (tab_height - 2) / 2])
        tab(tab_width, tab_radius, tab_height);
      translate([mountwidth + 2 + tab_width + tab_width / 2, -3, (tab_height - 2) / 2])
        mirror([1, 0, 0])
          tab(tab_width, tab_radius, tab_height);
    }
  } else if (style_config == "vertical") {
    // Single row of blocks, standing up on headboard
    for (i = [0:len(blocks) - 1]) {
      offset = (i == 0) ? tab_width : tab_width + mount_width(0, i, blocks);
      rotate([-90, 0, 0])
        translate([offset, 0, -1])
          block(blocks[i]);
    }

    // left and right tabs
    if (tabs) {
      translate([tab_width / 2, tab_width / 2, -block_depth - tab_height / 2])
        tab(tab_width, tab_radius, tab_height);
      translate([mountwidth + 2 + tab_width + tab_width / 2, tab_width / 2, -block_depth - tab_height / 2])
        mirror([1, 0, 0])
          tab(tab_width, tab_radius, tab_height);
    }
  } else if (style_config == "vertical_mirrored") {
    // Mirrored. two rows of blocks, back to back.
    // Row #1. Stand up on headboard.
    rotate([-90, 0, 0])for (i = [0:len(blocks) - 1]) {
      offset = (i == 0) ? tab_width : tab_width + mount_width(0, i, blocks);
      translate([offset, 0, -1])
        block(blocks[i]);
    }

    // Row #2. Opposite rotation. Stand up on headbord
    rotate([90, 0, 0]) mirror([0, 1, 0])for (i = [0:len(blocks) - 1]) {
        offset = (i == 0) ? tab_width : tab_width + mount_width(0, i, blocks);
        translate([offset, 0, -1])
          block(blocks[i]);
      }

    // left and right tabs
    if (tabs) {
      translate([tab_width / 2, 0, -block_depth - tab_height / 2])
        tab(tab_width, tab_radius, tab_height);
      translate([mountwidth + 2 + tab_width + tab_width / 2, 0, -block_depth - tab_height / 2])
        mirror([1, 0, 0])
          tab(tab_width, tab_radius, tab_height);
    }
  } else {
    echo("Error: invalid style_config option.");
  }
}

lever_nut_mount(blocks_config);
