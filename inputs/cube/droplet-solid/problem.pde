// Initial condition
real radius = 0.2;

real x1 = 0.5*Lx;
real y1 = 0.5*Ly;
real z1 = 0.2*Lz;
func droplet1 = ((x - x1)^2 + (y - y1)^2 + (z - z1)^2 < radius^2 ? 1 : -1);

func phi0 = droplet1;
func mu0 = 0;
[phi, mu] = [phi0, mu0];

// Boundary conditions
varf varBoundary([phi1,mu1], [phi2,mu2]) =
      int2d(Th,1) (10*mu2)
    + int2d(Th,2) (10*mu2);
;
