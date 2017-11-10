// Define initial conditions
real radius = 0.2;
real x1 = LX/2.;
real y1 = 0.0;
func droplet = ((x - x1)^2 + (y - y1)^2 < radius^2 ? 2 : 0);

func phi0 = -1 + droplet;
func mu0 = 0;
[phi, mu] = [phi0, mu0];

// Define boundary conditions
func contactAngles = CONTACT_ANGLE;
varf varPhiBoundary([phi1,mu1], [phi2,mu2]) =
  int1d(Th,1) (wetting(contactAngles) * mu2)
  + int1d(Th,1) (wetting(contactAngles) * phi1 * phiOld * mu2)
;

// Dimensionless numbers
Pe = 1;
Cn = 5e-3;

// Time adatpation
dt = 2*Cn^4*Pe;
dtMin = dt/2^6;
dtMax = dt*2^6;

// Number of iterations
nIter = 10000;
