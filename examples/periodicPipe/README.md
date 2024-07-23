# periodicPipe

This case demonstrates the use of periodic boundary conditions in NekRS. The LES `hpfrt` turbulence model is used, and the case is nondimensional.

This example also demonstrates using `exo2nek` to convert an exodus mesh composed of 2nd order wedge (WEDGE15) and tetrahedral (TET10) elements to a NekRS `.re2` mesh. Periodic boundary conditions are set up during the mesh conversion stage; when prompted, the user enters `1` for the number of periodic boundary surface pairs, then identifies the pair of sideset IDs for the periodic surfaces (in this case sidesets 1 and 2, entered as `1 2`). For this to work, the mesh on both surfaces must be identical.

A constant mean velocity is applied in the x-direction, driving the flow.
