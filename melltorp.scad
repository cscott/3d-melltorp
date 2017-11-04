/* 3d printer enclosure from Ikea Melltorp table. Connector pieces. */

/* [Global] */
part = "both"; // [above:Leg coupler (above table top),above-wrap:Leg coupler (wraps around table top),below:Magnet holder (below table top),holder,handle-top,handle-bottom]

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
function above_thick() = 2; // thickness underneath leg holder
function plexi_guide_thick() = 3.5;


piece(which=part);

module piece(which="both") {
  if (which=="below" || which=="both") {
    below_bracket();
  }
  if (which=="above" || which=="above-wrap" || which=="both") {
    above_bracket();
  }
  if (which=="above-wrap" || which=="both") {
    above_wrapper(shrink=(which=="above-wrap"));
  }
  if (which=="holder") {
    magnet_holder();
  }
  if (which=="handle-top") {
    plexi_handle(is_top=true);
  }
  if (which=="handle-bottom") {
    plexi_handle(is_top=false);
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

module below_bracket() {
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

module above_wrapper(shrink=false) {
  leg_outer_size = [25.5, 50.5];
  size = leg_inset() + leg_outer_size;
  wall = [-(leg_inset().x - plexi_thick() - plexi_guide_thick()),
          -(leg_inset().y - plexi_thick() - plexi_guide_thick())];
  epsilon = .1;
  difference() {
    translate([-wall.x,-wall.y,0])
      cube([size.x+wall.x,size.y+wall.y,middle_thick() + table_thick() + above_thick() - epsilon]);
    translate([0,0,middle_thick() - epsilon])
      cube([size.x + epsilon, size.y + epsilon, table_thick() + 2*epsilon]);
  }
  middle(wall=wall, extra=shrink?[0,17]:[0,0]);
}

module above_bracket() {
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
          above_thick()]);
    translate([leg_inset().x + leg_outer_size.x/2,
               leg_inset().y + leg_outer_size.y/2,
               above_thick()-epsilon]) {
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
                   -(above_thick()-epsilon)])
          cube([leg_outer_size.x + plexi_thick() + plexi_guide_thick(),
                leg_outer_size.y + plexi_thick() + plexi_guide_thick(),
                plexi_guide_height + above_thick()]);
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
             h=above_thick() + leg_holder_height + 2*epsilon);
    translate([0,0,screw_deep])
      cylinder(d=screw_head_hole + inner_clear(),
               h=above_thick() + leg_holder_height + 2*epsilon);
  }
  }
}

module magnet_holder() {
  epsilon = .1;
  margin = 2;
  inset = 0.5;
  difference() {
    cylinder(d=magnet_diam() + 2*margin, h=magnet_depth() - inset + margin);
    translate([0,0,-inset-epsilon]) {
      cylinder(d=magnet_diam() + inner_clear(), h=magnet_depth()+epsilon);
      cylinder(d=magnet_diam() - 2*margin, h=magnet_depth() + inset + margin + 2*epsilon);
    }
  }
}

module plexi_handle(is_top=true) {
  width=90; height=27; depth=is_top ? 10 : 4;
  round=2;
  inset=[14, 5, 1.5/*floor thickness*/];
  scale([1,1,is_top?1:-1])
  difference() {
    translate([0,0,depth/2-round]) {
      round_rect([width, height, depth], r=[round, round, 10], center=true);
    }
    translate([0,0,-round]) {
      cube([width*2, height*2, round*2], center=true);
    }
    if (is_top) translate([0,0,depth + inset.z])
      round_rect([width-2*inset.x, height-2*inset.y, 2*depth], r=[round, round, 6], center=true);
    for (i=[1,-1]) scale([i,1,1]) translate([width/2 - inset.x/2, 0, 0]) {
      translate([0,0,-1])
        cylinder(d=4, h=depth+2);
      translate([0,0,inset.z])
        cylinder(d=9, h=depth);
    }
  }
}

function max(x,y) = (x > y) ? x : y;

// uses the same radius for x and y, but we can live with that.
module round_rect(size=[1,1,1], r=[0,0,0], center=false) {
  s = size; // abbreviation
  r2 = max(r.x, r.y); // XXX sigh
  minkowski() {
    round_rect2a([s.x-r2, s.y-r2, s.z-r2], r.z);
    sphere(r=r2);
  }
}

// XXX the corners in this are sharp. :(
module round_rect2(size=[1,1,1], r=[0,0,0], center=false) {
  s = size; // abbreviation
  s2 = size/2;
  d = 2*r;
  translate(center ? [0,0,0] : [s2.x, s2.y, s2.z]) intersection() {
    round_rect2a([s.x, s.y, s.z], r.z);
    rotate([90,0,0]) round_rect2a([s.x, s.z, s.y], r.y);
    rotate([0,90,0]) round_rect2a([s.z, s.y, s.x], r.x);
  }
}

module round_rect2a(s, r) {
  if (r > 0) {
    cube([s.x-2*r, s.y, s.z], center=true);
    cube([s.x, s.y-2*r, s.z], center=true);
    for (i=[1,-1]) for (j=[1,-1]) scale([i,j,1])
      translate([s.x/2 - r, s.y/2 - r, 0])
        cylinder(r=r, h=s.z, center=true);
  } else {
    cube([s.x, s.y, s.z], center=true);
  }
}


// This one rounds the top edge more than I'd like.
module round_rect3(size=[1,1,1], r=[0,0,0], center=false) {
  s = size; // abbreviation
  s2 = size/2;
  d = 2*r;
  maxr = max(r.x, max(r.y, r.z));
  translate(center ? [0,0,0] : [s2.x, s2.y, s2.z]) {
    if (maxr<=0) cube([s.x, s.y, s.z], center=true);
    if (r.x>0) cube([s.x,     s.y-d.y, s.z-d.z], center=true);
    if (r.y>0) cube([s.x-d.x, s.y,     s.z-d.z], center=true);
    if (r.z>0) cube([s.x-d.x, s.y-d.y, s.z     ], center=true);
    for (i=[-1,1]) for (j=[-1,1]) {
      scale([1,i,j]) translate([         0, s2.y - r.y, s2.z - r.z])
        if (r.y>0 && r.z>0) scale([1,r.y/maxr,r.z/maxr])
          rotate([0,90,0]) cylinder(r=maxr, h=s.x-d.x, center=true);
      scale([i,1,j]) translate([s2.x - r.x,          0, s2.z - r.z])
        if (r.x>0 && r.z>0) scale([r.x/maxr,1,r.z/maxr])
          rotate([90,0,0]) cylinder(r=maxr, h=s.y-d.y, center=true);
      scale([i,j,1]) translate([s2.x - r.x, s2.y - r.y,          0])
        if (r.x>0 && r.y>0) scale([r.x/maxr,r.y/maxr,1])
          rotate([ 0,0,0]) cylinder(r=maxr, h=s.z-d.z, center=true);
      for (k=[-1,1]) scale([i,j,k])
        translate([s2.x - r.x, s2.y - r.y, s2.z - r.z])
          if (r.x>0 && r.y>0 && r.z>0) scale(r/maxr)
            sphere(r=maxr);
    }
  }
}
