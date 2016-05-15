// Dimensions of square
Lx = 1; // export
Ly = 1; // export

// Width of region of nucleation
w = 0.4;

// Mesh size;
s = .02;

// Define domain
Point(1) = {0,  0,  0, s};
Point(2) = {Lx, 0,  0, s};
Point(3) = {Lx, Ly, 0, s};
Point(4) = {0,  Ly, 0, s};

Point(5) = {Lx/2. - w/2., 0, 0, s};
Point(6) = {Lx/2. + w/2., 0, 0, s};

Line(1) = {1,5};
Line(2) = {5,6};
Line(3) = {6,2};
Line(4) = {2,3};
Line(5) = {3,4};
Line(6) = {4,1};

Line Loop(7) = {1,2,3,4,5,6};
Plane Surface(1) = {7};

DOMAIN = 1;
DISK = 1;
REST = 2;
Physical Line (DISK) = {2};
Physical Line (REST) = {1,3,4,5,6};
Physical Surface (DOMAIN) = {1};

// View options
Geometry.LabelType = 2;
Geometry.Lines = 1;
Geometry.LineNumbers = 2;
Geometry.Surfaces = 1;
Geometry.SurfaceNumbers = 2;

// Metis
/* Mesh.Partitioner = 2; */
/* Mesh.MetisAlgorithm = 1; */
/* Mesh.MetisEdgeMatching = 3; */
/* Mesh.NbPartitions = 10; */
/* Mesh.MshFilePartitioned = 2; // Add physical label for each region */
Mesh.MshFilePartitioned = 0; // Do not change physical label
