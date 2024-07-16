# periodicPipe

This case demonstrates the use of periodic boundary conditions in NekRS. The LES `hpfrt` turbulence model is used, and the case is dimensional.

This example also demonstrates using `exo2nek` to convert an exodus mesh composed of 2nd order wedge (WEDGE15) and tetrahedral (TET10) elements to a NekRS `.re2` mesh. Periodic boundary conditions are set up during the mesh conversion stage.

A constant mean velocity is applied in the x-direction, driving the flow.