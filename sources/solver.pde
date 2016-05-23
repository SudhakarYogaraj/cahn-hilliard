/// Include auxiliary files and load modules
include "freefem/write-mesh.pde"
include "freefem/getargs.pde"
include "freefem/clock.pde"
include "geometry.pde"

load "gmsh"

#if DIMENSION == 2
load "metis";
load "iovtk";
#endif

#if DIMENSION == 3
load "medit"
#endif

// Parameters for solver
string ssparams="";

// Process input parameters
int adapt      = getARGV("-adapt",0);
int plots      = getARGV("-plot",0);

#if DIMENSION == 2
#define MESH mesh
#define GMSHLOAD gmshload
#endif

#if DIMENSION == 3
#define MESH mesh3
#define GMSHLOAD gmshload3
#endif

/// Import the mesh
#ifndef MPI
MESH Th;
Th = GMSHLOAD("output/mesh.msh");
#endif

#ifdef MPI
MESH Th;
if (mpirank == 0)
{
  Th = GMSHLOAD("output/mesh.msh");
}
broadcast(processor(0), Th);
int processRegion = 1000 + mpirank + 1;
#endif

/// Declare default parameters

// Cahn-Hilliard parameters
real M       = 1;
real lambda  = 1;
real eps     = 0.01;

// Time parameters
real dt = 8.0*eps^4/M;
real nIter = 300;

// Mesh parameters
real meshError = 1.e-2;
real hmax = 0.1;
real hmin = hmax / 100;

/// Define functional spaces
#if DIMENSION == 2
fespace Vh(Th,P2), V2h(Th,[P2,P2]);
#endif

#if DIMENSION == 3
fespace Vh(Th,P1), V2h(Th,[P1,P1]);
#endif

Vh phiOld;
V2h [phi, mu];

/// Include problem file
include "problem.pde"

/// Calculate dependent parameters
real eps2 = eps*eps;
real invEps2 = 1./eps2;

// Define variational formulation

#if DIMENSION == 2
macro Grad(u) [dx(u), dy(u)] //EOM
#endif

#if DIMENSION == 3
macro Grad(u) [dx(u), dy(u), dz(u)] //EOM
#endif

#define AUX_INTEGRAL(dim) int ## dim ## d
#define INTEGRAL(dim) AUX_INTEGRAL(dim)

#ifdef MPI
#define INTREGION Th, processRegion
#else
#define INTREGION Th
#endif

varf varCH([phi1,mu1], [phi2,mu2]) =
  INTEGRAL(DIMENSION)(INTREGION)(
    phi1*phi2/dt
    + M*(Grad(mu1)'*Grad(phi2))
    - mu1*mu2
    + lambda*(Grad(phi1)'*Grad(mu2))
    + lambda*invEps2*0.5*3*phiOld*phiOld*phi1*mu2
    - lambda*invEps2*0.5*phi1*mu2
    )
;

varf varCHrhs([phi1,mu1], [phi2,mu2]) =
  INTEGRAL(DIMENSION)(INTREGION)(
    phiOld*phi2/dt
    + lambda*invEps2*0.5*phiOld*phiOld*phiOld*mu2
    + lambda*invEps2*0.5*phiOld*mu2
    )
;

#if DIMENSION == 3
/// Output file
ofstream foutHeader("output/output.msh");

// Write header, nodes and elements
writeHeader(foutHeader);
writeNodes(foutHeader, Vh);
writeElements(foutHeader, Vh, Th);
#endif

/// Loop in time

// Open output file
ofstream file("output/thermodynamics.txt");

// Extensive physical variables
real freeEnergy,
     massPhi,
     dissipation;

real timeStart,
     timeMacro,
     timeMatrixBulk,
     timeMatrixBc,
     timeMatrix,
     timeRhsBulk,
     timeRhsBc,
     timeRhs,
     timeFactorization,
     timeSolution;

#ifdef MPI
real freeEnergyReg,
     massPhiReg,
     dissipationReg;

real timeMatrixRegion,
     timeMatrixTotal,
     timeRhsRegion,
     timeRhsTotal;
#endif

for(int i = 0; i <= nIter; i++)
{
  timeStart = clock(); tic();

  // Update previous solution
  phiOld = phi;

  // Calculate macroscopic variables
  #ifdef MPI
  freeEnergyReg  = INTEGRAL(DIMENSION)(Th, processRegion) (0.5*lambda*(Grad(phi)'*Grad(phi)) + 0.25*lambda*invEps2*(phi^2 - 1)^2);
  massPhiReg     = INTEGRAL(DIMENSION)(Th, processRegion) (phi);
  dissipationReg = INTEGRAL(DIMENSION)(Th, processRegion) (M*(Grad(mu)'*Grad(mu)));

  mpiAllReduce(freeEnergyReg,  freeEnergy,  mpiCommWorld, mpiSUM);
  mpiAllReduce(massPhiReg,     massPhi,     mpiCommWorld, mpiSUM);
  mpiAllReduce(dissipationReg, dissipation, mpiCommWorld, mpiSUM);
  #endif

  #ifndef MPI
  freeEnergy  = INTEGRAL(DIMENSION)(Th)   (0.5*lambda*(Grad(phi)'*Grad(phi)) + 0.25*lambda*invEps2*(phi^2 - 1)^2);
  massPhi     = INTEGRAL(DIMENSION)(Th)   (phi);
  dissipation = INTEGRAL(DIMENSION)(Th)   (M*(Grad(mu)'*Grad(mu)));
  #endif

  timeMacro = tic();

  #ifdef MPI
  if (mpirank == 0)
  #endif
  {
    // Save data to files
    #if DIMENSION == 2
    savevtk("output/phi."+i+".vtk", Th, phi, dataname="PhaseField");
    savevtk("output/mu."+i+".vtk",  Th, mu,  dataname="ChemicalPotential");
    #endif

    #if DIMENSION == 3
    ofstream fo("output/phase-" + i + ".msh");
    writeHeader(fo); write1dData(fo, "Cahn-Hilliard", i*dt, i, phiOld);
    #endif

    file << i*dt           << "    "
         << freeEnergy     << "    "
         << massPhi        << "    "
         << dt*dissipation << "    " << endl;

    // Print variables at current iteration
    cout << endl
      << "** ITERATION **"      << endl
      << "Time = "              << i*dt          << endl
      << "Iteration = "         << i             << endl
      << "Mass = "              << massPhi       << endl
      << "Free energy bulk = "  << freeEnergy    << endl;

    // Visualize solution at current time step
    if (plots)
    {
      #if DIMENSION == 2
      plot(phi, wait=true, fill=true);
      plot(Th, wait=true);
      #endif

      #if DIMENSION == 3
      medit("Phi",Th,phi,wait=true);
      medit("Mu",Th,mu,wait=true);
      #endif
    }
  }

  // Exit if required
  if (i == nIter) break;

  #ifdef MPI
  mpiBarrier(mpiCommWorld);
  #endif

  tic();

  // Calculate the matrix
  #ifdef MPI
  matrix matRegion = varCH(V2h, V2h);
  timeMatrixRegion = tic();

  matrix matBulk;
  mpiAllReduce(matRegion,matBulk,mpiCommWorld,mpiSUM);
  mpiAllReduce(timeMatrixRegion,timeMatrixTotal,mpiCommWorld,mpiSUM);
  timeMatrixBulk = timeMatrixRegion + tic();

  matrix matCH;
  if (mpirank == 0)
  {
      matrix matBoundary = varBoundary(V2h, V2h);
      timeMatrixBc = tic();

      matCH = matBulk + matBoundary;
      timeMatrix = tic() + timeMatrixBulk + timeMatrixBc;

      set(matCH,solver=sparsesolver);
      timeFactorization = tic();
  }
  #endif

  #ifndef MPI
  matrix matBulk = varCH(V2h, V2h);
  timeMatrixBulk = tic();

  matrix matBoundary = varBoundary(V2h, V2h);
  timeMatrixBc = tic();

  matrix matCH = matBulk + matBoundary;
  timeMatrix = tic() + timeMatrixBulk + timeMatrixBc;

  set(matCH,solver=sparsesolver);
  timeFactorization = tic();
  #endif

  // Calculate the right-hand side
  #ifdef MPI
  real[int] rhsRegion = varCHrhs(0, V2h);
  timeRhsRegion = tic();

  real[int] rhsBulk(rhsRegion.n);
  mpiAllReduce(rhsRegion,rhsBulk,mpiCommWorld,mpiSUM);
  mpiAllReduce(timeRhsRegion,timeRhsTotal,mpiCommWorld,mpiSUM);
  timeRhsBulk = tic() + timeRhsRegion;

  real[int] rhsCH(rhsRegion.n);
  if (mpirank == 0)
  {
      real[int] rhsBoundary = varBoundary(0, V2h);
      timeRhsBc = tic();

      rhsCH = rhsBulk + rhsBoundary;
      timeRhs = tic() + timeRhsBulk + timeRhsBc;
  }
  #endif

  #ifndef MPI
  real[int] rhsBulk = varCHrhs(0, V2h);
  timeRhsBulk = tic();

  real[int] rhsBoundary = varBoundary(0, V2h);
  timeRhsBc  = tic();

  real[int] rhsCH = rhsBulk + rhsBoundary;
  timeRhs = timeRhsBulk + timeRhsBc + tic();
  #endif

  // Calculate the solution
  #ifdef MPI
  if (mpirank == 0)
  #endif
  {
    ofstream fout("matrix.txt");
    fout << matCH;
    ofstream foutrhs("rhs.txt");
    fout << rhsCH;
    phi[] = matCH^-1*rhsCH;
    timeSolution = tic();
  }
  #ifdef MPI
  broadcast(processor(0), phi[]);
  #endif

  #if DIMENSION == 2
  if (adapt)
  {
    #ifdef MPI
    if (mpirank == 0)
    #endif
    {
      Th = adaptmesh(Th, phi, mu, err = meshError, hmax = hmax, hmin = hmin);
      [phi, mu] = [phi, mu];
    }
    #ifdef MPI
    broadcast(processor(0), Th);
    broadcast(processor(0), phi[]);
    #endif
  }
  #endif

  // Print time of iteration
  #ifdef MPI
  if (mpirank == 0)
  #endif
  {
    cout << endl
         << "** TIME OF COMPUTATIONS **           " << endl
         << "Matrix: total time of computations   " << timeMatrix          << endl;
    #ifdef MPI
    cout << "Matrix: computation of volume terms  " << timeMatrixTotal     << endl
         << "Matrix: time spent in process 0      " << timeMatrixBulk      << endl
         << "Matrix: boundary conditions          " << timeMatrixBc        << endl;
    #endif
  }
  #ifdef MPI
  mpiBarrier(mpiCommWorld);
  cout   << "... Time for region " << mpirank << ": " << timeMatrixRegion << endl;
  mpiBarrier(mpiCommWorld);
  #endif

  #ifdef MPI
  if (mpirank == 0)
  #endif
  {
    cout << endl
         << "Rhs: total time of computations      " << timeRhs             << endl;
    #ifdef MPI
    cout << "Rhs: computation of volume terms     " << timeRhsTotal        << endl
         << "Rhs: time spent in process 0         " << timeRhsBulk         << endl
         << "Rhs: boundary conditions             " << timeRhsBc           << endl;
    #endif
  }
  #ifdef MPI
  mpiBarrier(mpiCommWorld);
  cout   << "... Time for region " << mpirank << ": " << timeRhsRegion << endl;
  mpiBarrier(mpiCommWorld);
  #endif

  #ifdef MPI
  if (mpirank == 0)
  #endif
  {
    cout << endl
         << "Factorization of the matrix          " << timeFactorization   << endl
         << "Solution  of the linear system       " << timeSolution        << endl
         << "Total time spent in process 0        " << clock() - timeStart << endl;
  }
}
