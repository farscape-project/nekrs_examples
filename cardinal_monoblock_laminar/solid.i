[Mesh]
[]

[Variables]
  [T]
    initial_condition = 500.0
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
    boundary = '5 10' # change these to be the correct IDs
  []
[]

[Materials]
  # need to set some conductivities in here
  # [pellet]
  #   type = HeatConductionMaterial
  #   thermal_conductivity_temperature_function = k_U
  #   temp = T
  #   block = '2 3'
  # []
[]

[Postprocessors]
  [flux_integral] # evaluate the total heat flux for normalization
    type = SideDiffusiveFluxIntegral
    diffusivity = thermal_conductivity
    variable = T
    boundary = '5 10' # change these to be the correct IDs
  []
  [max_fuel_T]
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
    initial_condition = 500.0
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
    boundary = '5 10' # change these to be the correct IDs
  []
[]

[Executioner]
  type = Transient
  dt = 5e-3 # change timestepping
  num_steps = 10 # change timestepping
  nl_abs_tol = 1e-5 # change tolerances
  nl_rel_tol = 1e-16 # change tolerances
  petsc_options_value = 'hypre boomeramg'
  petsc_options_iname = '-pc_type -pc_hypre_type'
[]

[Outputs]
  exodus = true
  execute_on = 'final' # could look at other options for this
[]
