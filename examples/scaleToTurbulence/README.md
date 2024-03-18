# scaleToTurbulence

This case demonstrates a workflow for using a single mesh to run a nondimensional simulation at various different resolutions, using the same mesh and applying increasing p-refinement (set by `polynomialOrder`) to change the resolution as well as using the result of a coarser mesh as the initial condition of the simulation. The flow properties can be changed with each run, in this case increasing the Reynolds number (through the viscosity) alongside the increasing polynomial order.

## Note: paths between files

This case is designed to be run from each of the `order<N>` directories, which each include a `pipe.par` file that points to `.udf`, `.oudf` and `.usr` files in the directory a level lower (unless these are replaced for higher order cases when turbulence modelling is introduced). The reader may notice that while `pipe.oudf` is in the same directory as `pipe.udf`, the `.udf` file includes `../pipe.oudf`, and the same is seen with the `.usr` file including `../yPlus_limits.f`. This is because when the simulation is run from the `order<N>` directory, these files are in the level below the working directory.