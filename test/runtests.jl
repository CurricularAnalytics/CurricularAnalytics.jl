# This file will run all tests using the Test module
using CurricularAnalytics
using Test

# Include each test.  Each of these files should reside in this (i.e., the /test) directory. 
# All data used by each test file should also reside in /test directory.  
# to execute all tests, from the test subdirectory run:
# julia> include("runtests.jl")

include("DataTypes.jl")
include("CurricularAnalytics.jl")
include("GraphAlgs.jl")
include("DegreePlanAnalytics.jl")
include("DataHandler.jl")
include("DegreePlanCreation.jl")
include("Simulation.jl")  