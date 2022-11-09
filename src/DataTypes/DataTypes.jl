# file: DataTypes.jl

# Enumerated types
# @enum Degree AA AS AAS BA BAAS BAH BBA BDes BE BED BFA BGS BIS BLA BLS BM BME BMS BMus BPS BRIT BS BSAS BSBA BSBE BSCE BSCH BSCP BSCS BSCYS BSE BSEd BSEE BSEV BSIE BSIS BSIT BSME BSN BSPH BSW BTAS
@enum System semester quarter
@enum Requisite pre co strict_co custom belong_to
@enum EdgeClass tree_edge back_edge forward_edge cross_edge
@enum EdgeType c_to_c lo_to_lo lo_to_c

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
