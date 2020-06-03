# file: DataTypes.jl

# Enumerated types
@enum Degree AA AS AAS BA BS
@enum System semester quarter
@enum Requisite pre co strict_co
@enum EdgeClass tree_edge back_edge forward_edge cross_edge

# fundamental data types for curricular analytics
include("learningoutcome.jl")
include("course.jl")
include("curriculum.jl")
include("degreeplan.jl")

# additional types
include("coursecatalog.jl")