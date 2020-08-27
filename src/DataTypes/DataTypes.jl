# file: DataTypes.jl

# Enumerated types
@enum Degree AA AS AAS BA BS
@enum System semester quarter
@enum Requisite pre co strict_co custom
@enum EdgeClass tree_edge back_edge forward_edge cross_edge

# fundamental data types for curricular analytics
include("LearningOutcome.jl")
include("Course.jl")
include("Curriculum.jl")
include("DegreePlan.jl")
include("CourseCatalog.jl")
include("DegreeRequirements.jl")
include("StudentRecord.jl")
include("Student.jl")
include("TransferArticulation.jl")
include("Simulation.jl")
