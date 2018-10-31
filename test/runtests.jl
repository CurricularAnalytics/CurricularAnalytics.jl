# This file will run all tests using the Test module
using CurricularAnalytics
using Test

# Include each test file, which should be in this same directory (/test)
# Example: The below would include DataTypes.jl, from the test directory. This file should contain all
# necessary for the DataTypes file
# include("DataTypes.jl")

include("DataTypes.jl")
include("CurricularAnalytics.jl")
include("DegreePlanAnalytics.jl")