Include "geometries/macros-gmsh/square.geo";
Include "geometries/macros-gmsh/circle.geo";
Include "geometries/macros-gmsh/cube.geo";
Include "geometries/macros-gmsh/cylinder.geo";

Lx = 1; // export
Ly = 1;// export
Lz = 0.6; // export
s = 0.04;

// Outer cube
  dx   = Lx;
  dy   = Ly;
  dz   = Lz;
  x    = 0.5*Lx;
  y    = 0.5*Ly;
  z    = 0.5*Lz;
  t    = 0.0*Pi;
  surf = 0;

  Call Cube;

  outer_cube_ll = lineloops[];

// Square
  x  = 0.5*Lx;
  y  = 0.5*Ly;
  z  = Lz;
  lx = 0.2 * Lx;
  ly = 0.2 * Ly;

  Call Square;

  sloop = lloop;
  square = newreg;
  Plane Surface(square) = {lloop};

// Circle
  x = 0.5*Lx;
  y = 0.5*Ly;
  z = 0;
  r = 0.15;

  Call Circ;

  cloop = lloop;
  circ = newreg;
  Plane Surface(circ) = {cloop};

// Define surfaces of domain
  i1 = newreg; Plane Surface(i1) = {outer_cube_ll[1], cloop};
  i2 = newreg; Plane Surface(i2) = outer_cube_ll[2];
  i3 = newreg; Plane Surface(i3) = outer_cube_ll[3];
  i4 = newreg; Plane Surface(i4) = outer_cube_ll[4];
  i5 = newreg; Plane Surface(i5) = outer_cube_ll[5];
  i6 = newreg; Plane Surface(i6) = {outer_cube_ll[6], sloop};

// Define volume of domain
  outer_cube_sl_index = newreg;
  Surface Loop(outer_cube_sl_index) = {circ, i1, i2, i3, i4, i5, i6, square};
  Volume(1) = {outer_cube_sl_index};

// Define physical entities
  // Outer cube
  Physical Surface(1) = {i1};
  Physical Surface(2) = {i2};
  Physical Surface(3) = {i3};
  Physical Surface(4) = {i4};
  Physical Surface(5) = {i5};
  Physical Surface(6) = {i6};

  // Circle and square
  Physical Surface(11) = {circ};
  Physical Surface(12) = {square};

  // Domain
  Physical Volume (1) = {1};

// View options
  Geometry.LabelType = 2;
  Geometry.SurfaceNumbers = 2;

  Color Gray
  {
    Surface
    {
      Physical Surface{21},
      Physical Surface{22}
    };
  }
