/* 
WAGO 221 mount

Creates a single row or double row set of 221 blocks
with mounting tabs/ears at either end.

Created - 2017/01/01 by Joo Chung
Further developed - 2025-11-06 by Cameron K. Brooks 
*/

$fn = $preview ? 32 : 64;
z_fight = $preview ? 0.01 : 0;

// vector of blocks. each element specifies the number of conductors for that block
blocks_ex = [2, 2, 2, 2, 2]; // a single 5 conductor blocks
// blocks_ex = [5, 3, 2]; // a set of 5 conductor, 3 conductor, 2 conductor blocks
// blocks_ex = [5, 5, 5]; // a set of three 5 conductor blocks
// blocks_ex = [2]; // a single 2 conductor block
// blocks_ex = [3]; // a single 3 conductor block

// 0 - no mirror, mirror the mount, stand it up, and put tabs on bottom.
// 1 - mirror, rotate so its standing up, and reposition tabs
// 2 - mirror, rotate so that they are laying flat, and reposition tabs.
mirror = 2;

// Tabs - include or exclude mounting tabs
// 0 - no tabs, 1 - tabs
tabs = 1;

// radius of hole in tab
tabradius = 2.6;

// thickness of tab
tabheight = 4;

// Set width and length of the tab. (tab is basically a square)
tabwidth = 10;

function end_customizer() = "WAGO 221 mount";

// width of a single conductor
conwidth = 5.6;

// block transparent plastic border
border = 1.75;

// depth of the block
blockdepth = 18.25;

allowance = 0.2;

two_dim = 2;

// Functions
function block_width(x) = conwidth * x + border + allowance; // block width
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
      cube([2, blockdepth, 3.25], false);
      translate([0, 0, 3.25]) cube([2.25, blockdepth, 2], false);
    }
    translate([-z_fight / 2, -z_fight, 2 - z_fight / 2]) cube([2.25 + z_fight, 2 + z_fight, 3.25 + z_fight], false);
    translate([2 + z_fight, blockdepth - 4 + z_fight / 2, 2 - z_fight / 2]) cube([0.25, 4, 3.25 + z_fight], false);
  }
}

module backshoulder(height) {
  difference() {
    union() {
      translate([0, 2, 0]) cube([2, 1.25, 10.15]);
      cube([2.25, 2, 10.15]);
    }
    translate([-z_fight / 2, -z_fight/2, 10.15 - 2]) cube([2.25 + z_fight, 3.25 + z_fight, 2 + z_fight]);
    translate([2 - z_fight, -z_fight / 2, 2 - z_fight / 2]) cube([1.25 + z_fight, 3.25 + z_fight, 3.25 + z_fight]);
  }
}

// WAGO 221 block
module block(nconn) {
  blockwidth = block_width(nconn);

  // base
  translate([2, 2, 0]) cube([blockwidth, blockdepth, 2], false);

  // back headboard
  translate([0, blockdepth + 2, 0]) cube([blockwidth + 4, 2, 10.15], false);

  // back lip
  translate([0, blockdepth, 10.15]) cube([blockwidth + 4, 4, 2], false);

  // front lip
  translate([0, 0, 0]) cube([blockwidth + 4, 2, 2.5], false);

  // left shoulder and right shoulders
  translate([0, 2, 0]) shoulder();
  translate([blockwidth + 4, 2, 0]) mirror([1, 0, 0]) shoulder();

  // back left and shoulder
  translate([0, blockdepth - 1.25, 0]) backshoulder();
  translate([blockwidth + 4, blockdepth - 1.25, 0]) mirror([1, 0, 0]) backshoulder();
}

module lever_nut_mount(blocks) {

  mountwidth = mount_width(0, len(blocks), blocks);
  if (mirror == 0) {
    // No mirror. Single row of blocks
    // create array of blocks
    for (i = [0:len(blocks) - 1]) {
      offset = (i == 0) ? tabwidth : tabwidth + mount_width(0, i, blocks);
      translate([offset, 0, 0]) block(blocks[i]);
    }

    // left and right tabs
    if (tabs) {
      translate([tabwidth / 2, (blockdepth + 4) / 2, tabheight / 2]) tab(tabwidth, tabradius, tabheight);
      translate([mountwidth + 2 + tabwidth + tabwidth / 2, (blockdepth + 4) / 2, tabheight / 2]) mirror([1, 0, 0])
          tab(tabwidth, tabradius, tabheight);
    }
  } else if (mirror == 1) {
    // Mirrored. two rows of blocks, back to back.
    // Row #1. Stand up on headboard.
    rotate([-90, 0, 0])for (i = [0:len(blocks) - 1]) {
      offset = (i == 0) ? tabwidth : tabwidth + mount_width(0, i, blocks);
      translate([offset, 0, -1]) block(blocks[i]);
    }

    // Row #2. Opposite rotation. Stand up on headbord
    rotate([90, 0, 0]) mirror([0, 1, 0])for (i = [0:len(blocks) - 1]) {
        offset = (i == 0) ? tabwidth : tabwidth + mount_width(0, i, blocks);
        translate([offset, 0, -1]) block(blocks[i]);
      }

    // left and right tabs
    if (tabs == 1) {
      translate([tabwidth / 2, 0, -blockdepth - tabheight / 2]) tab(tabwidth, tabradius, tabheight);
      translate([mountwidth + 2 + tabwidth + tabwidth / 2, 0, -blockdepth - tabheight / 2]) mirror([1, 0, 0])
          tab(tabwidth, tabradius, tabheight);
    }
  } else if (mirror == 2) {
    // Row #1.
    for (i = [0:len(blocks) - 1]) {
      offset = (i == 0) ? tabwidth : tabwidth + mount_width(0, i, blocks);
      translate([offset, -blockdepth - 6, -1]) block(blocks[i]);
    }

    // Row #2. Flip
    mirror([0, 1, 0])for (i = [0:len(blocks) - 1]) {
      offset = (i == 0) ? tabwidth : tabwidth + mount_width(0, i, blocks);
      translate([offset, -blockdepth, -1]) block(blocks[i]);
    }

    // left and right tabs
    if (tabs == 1) {
      translate([tabwidth / 2, -3, (tabheight - 2) / 2]) tab(tabwidth, tabradius, tabheight);
      translate([mountwidth + 2 + tabwidth + tabwidth / 2, -3, (tabheight - 2) / 2]) mirror([1, 0, 0])
          tab(tabwidth, tabradius, tabheight);
    }
  }
}

lever_nut_mount(blocks_ex);
