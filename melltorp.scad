/* 3d printer enclosure from Ikea Melltorp table. Connector pieces. */

/* [Global] */
part = "both"; // [top,top-wrap,bottom]

/* [Hidden] */
function inch() = 25.4;
function inner_clear() = 0.5; // how much larger to make holes
$fn = 48;

function middle_thick() = 4; // a bit of clearance from ring_thick()
function magnet_diam() = 10;
function magnet_depth() = 3;
function magnet_margin() = 5;

function ring_inset() = [70,39];
function ring_extra() = [5,22];
function ring_diam() = 17.8 + 1/*clearance*/;
function ring_thick() = 6.1; /* measured */

function leg_inset() = [4,0]; // from 70.2 to 69.4
function table_thick() = 18.5; // 18.2 with a little bit of clearance
function plexi_thick() = 2.2; // including clearance (measured 1.8mm)
function top_thick() = 2;
function plexi_guide_thick() = 3.5;


piece(which=part);

module piece(which="both") {
  if (which=="bottom" || which=="both") {
    bottom_bracket();
  }
  if (which=="top" || which=="top-wrap" || which=="both") {
    top_bracket();
  }
  if (which=="top-wrap" || which=="both") {
    top_wrapper(shrink=(which=="top-wrap"));
  }
}

module middle(wall=[0,0], extra=[0,0]) {
  inset = ring_inset();
  margin = ring_extra();
  difference() {
    translate([-wall.x,-wall.y,0])
    cube([inset.x + ring_diam()/2 + margin.x + wall.x - extra.x,
          inset.y + ring_diam()/2 + margin.y + wall.y - extra.y,
          middle_thick()]);
    translate([inset.x,inset.y,-1])
      cylinder(d=ring_diam() + inner_clear(), h=middle_thick() + 2);
  }
}

module bottom_bracket() {
  magnet_y = 14;
  height = magnet_y + magnet_diam()/2 + magnet_margin();
  width = magnet_diam() + 2*magnet_margin();
  extra_width = 38; /* for side holder x axis */
  epsilon=.1;
  middle();
  // front holder
  difference() {
    translate([0,50.5,middle_thick()-height])
      cube([4,width,height-epsilon]);
    translate([3,50.5-epsilon,middle_thick()-height-epsilon])
      rotate([0,atan2(1,height-middle_thick()),0]) // 1mm over height-middle_thick() mm
      cube([2,width+2*epsilon,height+epsilon]);
    translate([-epsilon, 50.5 + width/2, middle_thick() - magnet_y])
      rotate([0,90,0])
      cylinder(d=magnet_diam() + inner_clear(), h=magnet_depth() + epsilon);
  }
  // side holder
  difference() {
    translate([26.5,0,middle_thick()-height])
      cube([width + extra_width,10,height-epsilon]);
    translate([26.5 + width/2, -epsilon, middle_thick() - magnet_y])
      rotate([-90,0,0])
      cylinder(d=magnet_diam() + inner_clear(), h=magnet_depth() + epsilon);
  }
}

module top_wrapper(shrink=false) {
  leg_outer_size = [25.5, 50.5];
  size = leg_inset() + leg_outer_size;
  wall = [-(leg_inset().x - plexi_thick() - plexi_guide_thick()),
          -(leg_inset().y - plexi_thick() - plexi_guide_thick())];
  epsilon = .1;
  difference() {
    translate([-wall.x,-wall.y,0])
      cube([size.x+wall.x,size.y+wall.y,middle_thick() + table_thick() + top_thick() - epsilon]);
    translate([0,0,middle_thick() - epsilon])
      cube([size.x + epsilon, size.y + epsilon, table_thick() + 2*epsilon]);
  }
  middle(wall=wall, extra=shrink?[0,17]:[0,0]);
}

module top_bracket() {
  leg_outer_size = [25.5, 50.5];
  leg_inner_size = [22.4, 47.3];
  leg_core_size = [19.6,44.3];
  leg_holder_height = 14;
  plexi_guide_height = 14;
  screw_hole = 4.3; // measured 3.8
  screw_head_hole = 10; // measured 7.8
  screw_deep = 4;
  epsilon=.1;
  difference() {
  union() translate([0,0,middle_thick() + table_thick()]) {
    *cube([leg_inset().x + leg_outer_size.x,
          leg_inset().y + leg_outer_size.y,
          top_thick()]);
    translate([leg_inset().x + leg_outer_size.x/2,
               leg_inset().y + leg_outer_size.y/2,
               top_thick()-epsilon]) {
      translate([0,0,(leg_holder_height + epsilon)/2])
      cube([leg_core_size.x, leg_core_size.y, leg_holder_height + epsilon],
           center=true);
      // groovy things
      for (i=[0:2]) translate([0,0,5*i + 3])
        for (j=[-1,1]) scale([1,1,j])
          linear_extrude(height=2, scale=leg_core_size.x/leg_inner_size.x)
            square([leg_inner_size.x, leg_inner_size.y], center=true);
      // plexi guide
      difference() {
        translate([-leg_outer_size.x/2 - plexi_thick() - plexi_guide_thick(),
                   -leg_outer_size.y/2 - plexi_thick() - plexi_guide_thick(),
                   -(top_thick()-epsilon)])
          cube([leg_outer_size.x + plexi_thick() + plexi_guide_thick(),
                leg_outer_size.y + plexi_thick() + plexi_guide_thick(),
                plexi_guide_height + top_thick()]);
        translate([-leg_outer_size.x/2 - plexi_thick(),
                   -leg_outer_size.y/2 - plexi_thick(),
                   epsilon])
          cube([leg_outer_size.x + plexi_thick() + epsilon,
                leg_outer_size.y + plexi_thick() + epsilon,
                plexi_guide_height + epsilon]);
      }
    }
  }
  // screw hole
  translate([leg_inset().x + leg_outer_size.x/2,
             leg_inset().y + leg_outer_size.y/2,
             middle_thick() + table_thick() - epsilon]) {
    cylinder(d=screw_hole + inner_clear(),
             h=top_thick() + leg_holder_height + 2*epsilon);
    translate([0,0,screw_deep])
      cylinder(d=screw_head_hole + inner_clear(),
               h=top_thick() + leg_holder_height + 2*epsilon);
  }
  }
}
