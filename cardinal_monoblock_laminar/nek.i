[Mesh]
  type = NekRSMesh
  boundary = '1 2'  # haven't set this yet
[]

[Problem]
  type = NekRSProblem
  casename = 'monoblock'
  synchronization_interval = parent_app  # For avoiding unnecessary synchronisations
[]

[Executioner]
  type = Transient

  [TimeStepper]
    type = NekTimeStepper
  []
[]

[Outputs]
  exodus = true
  execute_on = 'final'
[]

# haven't looked at these yet, can possibly delete?
[Postprocessors]
  # only need 1 flux integral as only have 1 interface
  [pin_flux_in_nek]
    type = NekHeatFluxIntegral
    boundary = '1'
  []
  [duct_flux_in_nek]
    type = NekHeatFluxIntegral
    boundary = '2'
  []
  [max_nek_T]
    type = NekVolumeExtremeValue
    field = temperature
    value_type = max
  []
  [min_nek_T]
    type = NekVolumeExtremeValue
    field = temperature
    value_type = min
  []
[]
