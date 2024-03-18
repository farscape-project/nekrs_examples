# laminarPipe

This example runs a nondimensionalised simulation of a laminar pipe flow at Re=100 (set using viscosity=1/Re). The geometry is the fluid region of a circular pipe with a diameter of 1 and length of 5, with flow in the negative z direction. A parabolic inlet profile is used at the inlet (avoiding a sharp transition that would occur at the curve between the inlet and the no-slip walls if a uniform inlet profile was used).

The .par (parameters) file contains the general settings for the case, including the polynomial order, time stepping, write controls, the mesh, fluid parameters, tolerances, and boundary conditions. As this case is set up to be dimensionless, the "viscosity" parameter actually represents the inverse of the Reynolds number, with the minus sign being interpreted by NekRS as setting the viscosity to be the inverse of the number following the sign. The `[CASEDATA]` block sets parameters which are used in custom functions in the .udf file, setting the average velocity across the inlet, the pipe radius, x and y coordinates of the central axis (all used in the parabolic inlet profile calculation).

The .udf (user-defined functions) file is used to read parameters from `[CASEDATA]` (in `UDF_Setup0`) and pass them to the occa kernels (in `UDF_LoadKernels`). It also adds in the .oudf file using an #include directive.

The .oudf (OCCA user-defined functions) file is used to set boundary conditions, which must be done on the device. The inlet condition requires a `velocityDirichletConditions` function to set `bc->{u,v,w}`, and in this case is used to set the parabolic inlet profile. The outlet condition requires a `pressureDirichletConditions` function to set `bc->p`, and in this case implements the stabilised outflow condition proposed by Dong et al in accordance with several official NekRS examples (though is likely not necessary for this example and could instead be replaced with `bc->p = 0.0`).

To set up the case, first create the mesh (a .jou script for Coreform Cubit is provided, which creates a .exo exodus mesh) and convert it to .re2 format using the `exo2nek` utility available from https://github.com/Nek5000/Nek5000/tree/master/tools. To run the case, ensure the NekRS environment is active and run `./run.sh`; if the simulation runs successfully several `laminarPipe0.f*` files will be created containing the output results, and the `nrsvis` command in the script will create a `laminarPipe.nek5000` file which allows ParaView or VisIt to read the outputs. Running `./clean.sh` will remove the outputs and logs but preserve the `.cache` (allowing you to re-run the simulation with minor changes), though if major changes are made you may need to run `./clean_all` to delete the `.cache`.

# Compatability

Tested with NekRS v23.0
