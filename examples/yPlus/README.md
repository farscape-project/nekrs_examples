# yPlus

This example demonstrates how to assess the normalised distance of the first grid point from the wall, $y_1^+$, in a NekRS simulation. The case itself is based on the laminarPipe example, and uses the same mesh; a laminar flow is used to reduce the computational requirements for a simple demonstration, though the most likely application of this functionality is for checking whether boundary layers are sufficiently resolved in simulations of turbulent flows.

The output of this calculation will look something like:
```
copying solution to nek
calling nek_userchk ...
                  minimum      maximum      average
           y_p+   1.8387E-01   3.3340E-01   3.2718E-01
```
which gives the minimum, maximum and average values of $y_1^+$ respectively.

To perform the $y_1^+$ calculation, the legacy Nek5000 backend is used. This requires writing a custom Fortran `.usr` file, such as that in this example, as well as a pair of additional routines included in the `yPlus_limits.f` file. This is a cut-down version of `limits.f` from [https://github.com/dshaver-ANL/usrcode](https://github.com/dshaver-ANL/usrcode); see this repository for additional functionality that can be added into NekRS. This legacy functionality exists entirely on the CPU side of the simulation.

In the `.usr` file, the `userchk` subroutine calls `y_p_limits` from `yPlus_limits.f`, which calculates the minimum, maximum and average values of $y_1^+$ on the mesh, and prints these to the output stream. This uses the distance `wd` of each point on the mesh from the walls, calculated (using a cheap approximation) in the `usrdat3` subroutine. This is separated from `userchk` because it only needs to be calculated once, during initialisation. This functionality also requires that the legacy Nek5000 backend is aware of the boundary IDs, as in NekRS this is usually handled on the GPU side; the user should study the `usrdat2` subroutine to understand how this is done, noting that the IDs assigned are in line with those used when generating the mesh. The key aspect is to mark the walls as `'W  '`, so that the wall distance calculation measures distance from only these walls.

By default, the `userchk` subroutine is only called once, during initialisation, whereas the user will likely want to obtain $y_1^+$ values once the flow has developed. Additional calls to `userchk` can be added in the `.udf` file, to the `UDF_ExecuteStep` function. This function is called once in every timestep, but the user can implement `if` statements to control when the $y_1^+$ calculation is called; several examples of this can be found in `yPlus.udf`. As the $y_1^+$ calculation takes place on the CPU, the simulation state must be copied from from GPU to CPU to calculate $y_1^+$. This is done with the `nek::ocopyToNek(time, tstep)` function. Then, `nek::userchk()` is called, performing the y+ calculation as explained above.