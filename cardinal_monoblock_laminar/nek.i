[Mesh]
  type = NekRSMesh
  boundary = '3'  # NekRS mesh boundary ID 3
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

[Postprocessors]
  [flux_in_nek]
    type = NekHeatFluxIntegral
    boundary = '3'  # NekRS mesh boundary ID 3
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
