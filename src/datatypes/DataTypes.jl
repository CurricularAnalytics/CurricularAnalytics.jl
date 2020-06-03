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

# Returns a requisite as a string for visualization
function requisite_to_string(req::Requisite)
    if req == pre
        return "CurriculumPrerequisite"
    elseif req == co
        return "CurriculumCorequisite"
    else
        return "CurriculumStrictCorequisite"
    end
end

# Returns a requisite (enumerated type) from a string
function string_to_requisite(req::String)
    if (req == "prereq" || req == "CurriculumPrerequisite")
        return pre
    elseif (req == "coreq" || req == "CurriculumCorequisite")
        return co
    elseif (req == "strict-coreq" || req == "CurriculumStrictCorequisite")
        return strict_co
    end
end