# recyclingInlet

This case demonstrates a recycling inlet boundary condition. These parts of the input files (in `.udf` and `.oudf`) are clearly marked with comments. This boundary condition is helpful in avoiding the need to simulate the full entrance length that would be required for a simulation using a laminar (parabolic) inlet profile, instead copying the velocity from a region downstream of the inlet and interpolating this onto the inlet as a boundary condition, rescaling it if required to ensure the inlet condition always provides the desired mean flow rate.
