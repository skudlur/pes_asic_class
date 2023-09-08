/* Generated by Yosys 0.32+51 (git sha1 6405bbab1, gcc 12.3.0-1ubuntu1~22.04 -fPIC -Os) */

module multiple_modules(a, b, c, y);
  wire _0_;
  wire _1_;
  wire _2_;
  wire _3_;
  wire _4_;
  wire _5_;
  input a;
  wire a;
  input b;
  wire b;
  input c;
  wire c;
  wire mid;
  wire \sub_and.a ;
  wire \sub_and.b ;
  wire \sub_and.y ;
  wire \sub_or.a ;
  wire \sub_or.b ;
  wire \sub_or.y ;
  output y;
  wire y;
  sky130_fd_sc_hd__and2_0 _6_ (
    .A(_1_),
    .B(_0_),
    .X(_2_)
  );
  sky130_fd_sc_hd__or2_0 _7_ (
    .A(_4_),
    .B(_3_),
    .X(_5_)
  );
  assign _4_ = \sub_or.b ;
  assign _3_ = \sub_or.a ;
  assign \sub_or.y  = _5_;
  assign \sub_or.a  = mid;
  assign \sub_or.b  = c;
  assign y = \sub_or.y ;
  assign _1_ = \sub_and.b ;
  assign _0_ = \sub_and.a ;
  assign \sub_and.y  = _2_;
  assign \sub_and.a  = a;
  assign \sub_and.b  = b;
  assign mid = \sub_and.y ;
endmodule
