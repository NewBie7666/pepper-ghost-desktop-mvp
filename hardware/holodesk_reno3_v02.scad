/*
  HOLODESK Reno3 V0.2 — single 45-degree plate desktop optical MVP
  Units: mm. Parametric for 100x100 or 150x150 acrylic sheet.

  PRINTING:
  mode="print_bracket" -> print two matching brackets.
  mode="print_bar" -> print one crossbar.
  In assembly mode the sheet and Reno3 are for visualization only.
  Smartphone rests on the table, NOT in a clamping cradle.
  Changes from V0.1: 10 mm -> 18 mm plate lower-edge height;
  accurate Reno3 Vitality physical envelope and approximate 20:9 screen.
*/
mode = "assembly";       // "assembly", "print_bracket", "print_bar", "print_layout"
panel_size = 100;         // 100 or 150
panel_thickness = 3;     // adjust to actually measured material
slot_clearance = 0.5;    // total additional slot width, tune for printer
view_angle = 45;         // degrees from tabletop
plate_bottom_z = 18;     // V0.2 extra safety clearance above phone
show_phone = true;
show_plate = true;
phone_length = 160.3;    // OPPO Reno3 Vitality (元气版)
phone_width = 74.3;
phone_thickness = 7.96; // bare phone; add an actual measured case height if using case
phone_extra_height = 0;  // measured case/standoff contribution, if any
$fn=32;

// Shape dimensions. The phone is not supported by the frame.
slot = panel_thickness + slot_clearance;
wall = 3.2;
foot_height = 8;
foot_front = 17;
foot_back = 79;
bracket_width = 8;
rad=view_angle;
c=cos(rad);
s=sin(rad);
B=[panel_size*c,plate_bottom_z];
T=[0,plate_bottom_z+panel_size*s];
v=[-c,s];
n=[s,c];
bar_x=B[0]+55;
bar_hole_w=10;
bar_hole_z=1.2;
bar_hole_h=5.6;

// Physical checks are indicative; real-world print tolerances and camera bumps apply.
echo(str("Reno3 body ",phone_length," x ",phone_width," x ",phone_thickness," mm"));
echo(str("Estimated minimum plate-surface-to-phone-top gap: ", plate_bottom_z-panel_thickness/2*cos(view_angle)-(phone_thickness+phone_extra_height)," mm"));
echo(str("Lateral phone-to-bracket total free gap: ",panel_size-2*bracket_width-phone_width," mm"));

function add(a,b)=[a[0]+b[0],a[1]+b[1]];
function scale2(a,vv)=[a[0]*vv,a[1]*vv];
function shift(a,vector,length)=add(a,scale2(vector,length));
module capsule(a,b,r){hull(){translate(a)circle(r=r);translate(b)circle(r=r);}}
module bracket_profile(){
  difference(){
    union(){
      translate([-foot_front,0]) square([B[0]+foot_back+foot_front,foot_height]);
      for(side=[-1,1])
        capsule(shift(shift(B,v,-5),n,side*(slot/2+wall/2)),
                shift(shift(T,v, 3),n,side*(slot/2+wall/2)),wall/2);
      capsule(shift(shift(B,v,-6),n,-(slot/2+wall/2)),
              shift(shift(B,v,-6),n, (slot/2+wall/2)),wall/2);
      capsule(shift(shift(T,v,-14),n,slot/2+wall+3),
              [B[0]+foot_back-7,foot_height],3.7);
    }
    translate([bar_x,bar_hole_z])square([bar_hole_w,bar_hole_h]);
  }
}
module bracket_flat(){linear_extrude(height=bracket_width) bracket_profile();}
module bar_flat(){cube([9.4,panel_size,5.0]);}
module bracket_assembled(y_top){translate([0,y_top,0])rotate([90,0,0])bracket_flat();}
module bar_assembled(){translate([bar_x+0.3,-panel_size/2,1.5])bar_flat();}
module plate_assembled(){
  color([0.35,0.8,0.92,0.28])
    translate([B[0],-panel_size/2,plate_bottom_z])
      rotate([0,-(180-view_angle),0])
        translate([0,0,-panel_thickness/2])
          cube([panel_size,panel_size,panel_thickness]);
}
module phone_assembled(){
  // Black phone envelope; camera bump/case not modeled.
  cx=B[0]/2;
  color([0.12,0.13,0.15])
    translate([cx-phone_length/2,-phone_width/2,0])
      cube([phone_length,phone_width,phone_thickness+phone_extra_height]);
  // Approximate OLED active display dimensions from 6.4-inch, 20:9 spec.
  screen_long=148.2;
  screen_short=66.7;
  color([0.003,0.006,0.012])
    translate([cx-screen_long/2,-screen_short/2,phone_thickness+phone_extra_height+0.02])
      cube([screen_long,screen_short,0.20]);
  color([0.02,0.60,0.80])
    translate([cx-8,-0.6,phone_thickness+phone_extra_height+0.24])cube([16,1.2,0.1]);
}
if(mode=="print_bracket")bracket_flat();
else if(mode=="print_bar")bar_flat();
else if(mode=="print_layout"){
  bracket_flat();
  translate([B[0]+foot_back+40,0,0])bracket_flat();
  translate([0,panel_size+30,0])bar_flat();
}else{
  if(show_phone) phone_assembled();
  color([0.16,0.17,0.19]){
    bracket_assembled(-panel_size/2+bracket_width);
    bracket_assembled(panel_size/2);
    bar_assembled();
  }
  if(show_plate)plate_assembled();
}