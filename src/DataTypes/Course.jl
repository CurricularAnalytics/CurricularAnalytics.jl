# Course-related data DataTypes

abstract type AbstractCourse end

##############################################################
# Course data type
"""
The `Course` data type is used to represent a single course consisting of a given number
of credit hours.  To instantiate a `Course` use:

    Course(name, credit_hours; <keyword arguments>)

# Arguments
Required:
- `name::AbstractString` : the name of the course.
- `credit_hours::int` : the number of credit hours associated with the course.
Keyword:
- `prefix::AbstractString` : the prefix associated with the course.
- `num::AbstractString` : the number associated with the course.
- `institution:AbstractString` : the name of the institution offering the course.
- `canonical_name::AbstractString` : the common name used for the course.

# Examples:
```julia-repl
julia> Course("Calculus with Applications", 4, prefix="MA", num="112", canonical_name="Calculus I")
```
"""
mutable struct Course <: AbstractCourse
    id::Int                             # Unique course id
    vertex_id::Dict{Int, Int}           # The vertex id of the course w/in a curriculum graph, stored as
                                        # (curriculum_id, vertex_id)
    name::AbstractString                # Name of the course, e.g., Introduction to Psychology
    credit_hours::Real                  # Number of credit hours associated with course. For the
                                        # purpose of analytics, variable credits are not supported
    prefix::AbstractString              # Typcially a department prefix, e.g., PSY
    num::AbstractString                 # Course number, e.g., 101, or 302L
    institution::AbstractString         # Institution offering the course
    college::AbstractString             # College or school (within the institution) offering the course
    department::AbstractString          # Department (within the school or college) offering the course
    cross_listed::Array{Course}         # courses that are cross-listed with the course (same as "also offered as")
    canonical_name::AbstractString      # Standard name used to denote the course in the
                                        # discipline, e.g., Psychology I
    requisites::Dict{Int, Requisite}    # List of requisites, in (requisite_course id, requisite_type) format
    learning_outcomes::Array{LearningOutcome}  # A list of learning outcomes associated with the course
    metrics::Dict{String, Any}          # Course-related metrics
    metadata::Dict{String, Any}         # Course-related metadata

    passrate::Float64                   # Percentage of students that pass the course

    # Constructor
    function Course(name::AbstractString, credit_hours::Real; prefix::AbstractString="", learning_outcomes::Array{LearningOutcome}=Array{LearningOutcome,1}(),
                    num::AbstractString="", institution::AbstractString="", college::AbstractString="", department::AbstractString="",
                    cross_listed::Array{Course}=Array{Course,1}(), canonical_name::AbstractString="", id::Int=0, passrate::Float64=0.5)
        this = new()
        this.name = name
        this.credit_hours = credit_hours
        this.prefix = prefix
        this.num = num
        this.institution = institution
        if id == 0
            this.id = mod(hash(this.name * this.prefix * this.num * this.institution), UInt32)
        else
            this.id = id
        end
        this.college = college
        this.department = department
        this.cross_listed = cross_listed
        this.canonical_name = canonical_name
        this.requisites = Dict{Int, Requisite}()
        #this.requisite_formula
        this.metrics = Dict{String, Any}()
        this.metadata = Dict{String, Any}()
        this.learning_outcomes = learning_outcomes
        this.vertex_id = Dict{Int, Int}()       # curriculum id -> vertex id

        this.passrate = passrate
        return this
    end
end

mutable struct CourseCollection <: AbstractCourse
    id::Int                             # Unique course id
    vertex_id::Dict{Int, Int}           # The vertex id of the course w/in a curriculum graph, stored as 
                                        # (curriculum_id, vertex_id)
    courses::Array{Course}              # Courses associated with the collection                                   
    name::AbstractString                # Name of the course, e.g., Introduction to Psychology
    credit_hours::Real                  # Number of credit hours associated with a "typcial" course in the collection
    institution::AbstractString         # Institution offering the course
    college::AbstractString             # College or school (within the institution) offering the course
    department::AbstractString          # Department (within the school or college) offering the course
    canonical_name::AbstractString      # Standard name used to denote the course collection, e.g., math genearl education 
    requisites::Dict{Int, Requisite}    # List of requisites, in (requisite_course id, requisite_type) format
    metrics::Dict{String, Any}          # Course-related metrics
    metadata::Dict{String, Any}         # Course-related metadata

    # Constructor
    function CourseCollection(name::AbstractString, credit_hours::Real, courses::Array{Course,1}; institution::AbstractString="", 
         college::AbstractString="", department::AbstractString="", canonical_name::AbstractString="", id::Int=0)
        this = new()
        this.name = name
        this.credit_hours = credit_hours
        this.courses = courses
        this.institution = institution
        if id == 0
            this.id = mod(hash(this.name * this.institution * string(length(courses))), UInt32)
        else 
            this.id = id
        end
        this.college = college
        this.department = department
        this.canonical_name = canonical_name
        this.requisites = Dict{Int, Requisite}()
        #this.requisite_formula
        this.metrics = Dict{String, Any}()
        this.metadata = Dict{String, Any}()
        this.vertex_id = Dict{Int, Int}()       # curriculum id -> vertex id
        return this
    end
end

function course_id(prefix::AbstractString, num::AbstractString, name::AbstractString, institution::AbstractString)
    convert(Int, mod(hash(name * prefix * num * institution), UInt32))
end

"""
    add_requisite!(rc, tc, requisite_type)

Add course rc as a requisite, of type requisite_type, for target course tc.

# Arguments
Required:
- `rc::AbstractCourse` : requisite course.
- `tc::AbstractCourse` : target course, i.e., course for which `rc` is a requisite.
- `requisite_type::Requisite` : requisite type.

# Requisite types
One of the following requisite types must be specified for the `requisite_type`:
- `pre` : a prerequisite course that must be passed before `tc` can be attempted.
- `co`  : a co-requisite course that may be taken before or at the same time as `tc`.
- `strict_co` : a strict co-requisite course that must be taken at the same time as `tc`.
"""
function add_requisite!(requisite_course::AbstractCourse, course::AbstractCourse, requisite_type::Requisite)
    course.requisites[requisite_course.id] = requisite_type
end

"""
    add_requisite!([rc1, rc2, ...], tc, [requisite_type1, requisite_type2, ...])

Add a collection of requisites to target course tc.

# Arguments
Required:
- `rc::Array{AbstractCourse}` : and array of requisite courses.
- `tc::AbstractCourse` : target course, i.e., course for which `rc` is a requisite.
- `requisite_type::Array{Requisite}` : an array of requisite types.

# Requisite types
The following requisite types may be specified for the `requisite_type`:
- `pre` : a prerequisite course that must be passed before `tc` can be attempted.
- `co`  : a co-requisite course that may be taken before or at the same time as `tc`.
- `strict_co` : a strict co-requisite course that must be taken at the same time as `tc`.
"""
function add_requisite!(requisite_courses::Array{AbstractCourse}, course::AbstractCourse, requisite_types::Array{Requisite})
    @assert length(requisite_courses) == length(requisite_types)
    for i = 1:length(requisite_courses)
        course.requisites[requisite_courses[i].id] = requisite_types[i]
    end
end

"""
    delete_requisite!(rc, tc)

Remove course rc as a requisite for target course tc.  If rc is not an existing requisite for tc, an
error is thrown.

# Arguments
Required:
- `rc::AbstractCourse` : requisite course.
- `tc::AbstractCourse` : target course, i.e., course for which `rc` is a requisite.

"""
function delete_requisite!(requisite_course::Course, course::Course)
    #if !haskey(course.requisites, requisite_course.id)
    #    error("The requisite you are trying to delete does not exist")
    #end
    delete!(course.requisites, requisite_course.id)
end
