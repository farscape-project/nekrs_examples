# Initial and boundary condition parameters
initial_temp = 500 # [degC]
heat_flux = 1e3   # [W/m^2]

# Material properties
armour_thermal_conductivity = 170.0  # Tungsten [W.m^-1.K^-1]
pipe_thermal_conductivity = 400.0    # Copper [W.m^-1.K^-1]

# -----------------------------------------------------

[Mesh]
  [solid_mesh]
    type = FileMeshGenerator
    file = 'monoblock_solid.exo'
  []
[]

[Variables]
  [T]
    initial_condition = ${initial_temp}
  []
[]

[Kernels]
  [diffusion]
    type = HeatConduction
    variable = T
  []
[]

[BCs]
  [fluid_solid_interface]
    type = MatchedValueBC
    variable = T
    v = nek_temp
    boundary = 2  # MOOSE mesh boundary ID of fluid-solid interface
  []
  # [heat_flux_in]
  #   type = NeumannBC
  #   variable = T
  #   boundary = 4
  #   value = ${heat_flux}
  # []
  [hot_top_surface]
    type = DirichletBC
    variable = T
    boundary = 4
    value = 700
  []
[]

[Materials]
  [armour]
    type = HeatConductionMaterial
    thermal_conductivity = '${armour_thermal_conductivity}'
    temp = T
    block = 1
  []
  [pipe]
    type = HeatConductionMaterial
    thermal_conductivity = '${pipe_thermal_conductivity}'
    temp = T
    block = 2
  []
[]

[Postprocessors]
  [flux_integral] # evaluate the total heat flux for normalization
    type = SideDiffusiveFluxIntegral
    diffusivity = thermal_conductivity
    variable = T
    boundary = 2  # MOOSE mesh boundary ID of fluid-solid interface
  []
  [max_solid_T]
    type = NodalExtremeValue
    variable = T
    value_type = max
  []
  [synchronize]  # For avoiding unnecessary synchronisations
    type = Receiver
    default = 1
  []
[]

[MultiApps]
  [nek]
    type = TransientMultiApp
    app_type = CardinalApp
    input_files = 'nek.i'
    sub_cycling = true
    execute_on = timestep_end
  []
[]

[Transfers]
  [nek_temp] # grabs temperature from nekRS and stores it in nek_temp
    type = MultiAppGeneralFieldNearestLocationTransfer
    source_variable = temp
    from_multi_app = nek
    variable = nek_temp
    fixed_meshes = true
  []
  [avg_flux] # sends heat flux in avg_flux to nekRS
    type = MultiAppGeneralFieldNearestLocationTransfer
    source_variable = avg_flux
    to_multi_app = nek
    variable = avg_flux
    fixed_meshes = true
  []
  [flux_integral_to_nek] # sends the heat flux integral (for normalization) to nekRS
    type = MultiAppPostprocessorTransfer
    to_postprocessor = flux_integral
    from_postprocessor = flux_integral
    to_multi_app = nek
  []
  [synchronize_in] # For avoiding unnecessary synchronisations
    type = MultiAppPostprocessorTransfer
    to_postprocessor = transfer_in
    from_postprocessor = synchronize
    to_multi_app = nek
  []
[]

[AuxVariables]
  [nek_temp]
    initial_condition = ${initial_temp}
  []
  [avg_flux]
    family = MONOMIAL
    order = CONSTANT
  []
[]

[AuxKernels]
  [avg_flux]
    type = DiffusionFluxAux
    diffusion_variable = T
    component = normal
    diffusivity = thermal_conductivity
    variable = avg_flux
    boundary = 2  # MOOSE mesh boundary ID of fluid-solid interface
  []
[]

[Executioner]
  type = Transient
  dt = 8e-2 # change timestepping
  num_steps = 10 # change timestepping
  nl_abs_tol = 1e-5 # change tolerances?
  nl_rel_tol = 1e-16 # change tolerances?
  petsc_options_value = 'hypre boomeramg'
  petsc_options_iname = '-pc_type -pc_hypre_type'
[]

[Outputs]
  exodus = true
  execute_on = 'timestep_end'
[]
