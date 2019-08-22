# file: DataTypes.jl

# Enumerated types
@enum Degree AA AS AAS BA BS
@enum System semester quarter
@enum Requisite pre co strict_co
@enum EdgeClass tree_edge back_edge forward_edge cross_edge

##############################################################
# LearningOutcome data type
"""
The `LearningOutcome` data type is used to associate a set of learning outcomes with 
a course or a curriculum. To instantiate a `LearningOutcome` use:

    LearningOutcome(name, description, hours)

# Arguments
- `name::AbstractString` : the name of the learning outcome.
- `description::AbstractString` : detailed description of the learning outcome.
- `hours::int` : number of class (contact) hours needed to attain the learning outcome. 

# Examples:
```julia-repl
julia> LearningOutcome("M1", "Learner will demonstrate the ability to ...", 12)
```
"""
mutable struct LearningOutcome
    id::Int                             # Unique id for the learning outcome,
                                        # set when the cousrse is added to a graph
    name::AbstractString                # Name of the learning outcome
    description::AbstractString         # A description of the learning outcome
    hours::Int                          # number of class hours that should be devoted
                                        # to the learning outcome
    requisites::Dict{Int, Requisite}    # List of requisites, in
                                        #(requisite_learning_outcome, requisite_type) format
    metrics::Dict{String, Any}          # Learning outcome-related metrics

    # Constructor
    function LearningOutcome(name::AbstractString, description::AbstractString, hours::Int=0)
        this = new()
        this.name =name
        this.description = description
        this.hours = hours
        this.id = mod(hash(this.name * this.description), UInt32)
        this.requisites = Dict{Int, Requisite}()
        this.metrics = Dict{String, Any}()
        return this
    end
end

#"""
#add_lo_requisite!(rlo, tlo, requisite_type)
#Add learning outcome rlo as a requisite, of type requisite_type, for target learning 
#outcome tlo.
#"""
function add_lo_requisite!(requisite_lo::LearningOutcome, lo::LearningOutcome, requisite_type::Requisite)
    lo.requisites[requisite_lo.id] = requisite_type
end

function add_lo_requisite!(requisite_lo::Array{LearningOutcome}, lo::LearningOutcome, 
                      requisite_type::Array{Requisite})
    @assert length(requisite_lo) == length(requisite_type)
    for i = 1:length(requisite_lo)
        lo.requisites[requisite_lo[i].id] = requisite_type[i]
    end
end

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
mutable struct Course
    id::Int                             # Unique course id
    vertex_id::Dict{Int, Int}           # The vertex id of the course w/in a curriculum graph, stored as 
                                        # (curriculum_id, vertex_id)
    name::AbstractString                # Name of the course, e.g., Introduction to Psychology
    credit_hours::Real                  # Number of credit hours associated with course. For the
                                        # purpose of analytics, variable credits are not supported
    prefix::AbstractString              # Typcially a department prefix, e.g., PSY
    num::AbstractString                 # Course number, e.g., 101, or 302L
    institution::AbstractString         # Institution offering the course
    canonical_name::AbstractString      # Standard name used to denote the course in the
                                        # discipline, e.g., Psychology I
    requisites::Dict{Int, Requisite}    # List of requisites, in (requisite_course id, requisite_type) format
    learning_outcomes::Array{LearningOutcome}  # A list of learning outcomes associated with the course
    metrics::Dict{String, Any}          # Course-related metrics

    # Constructor
    function Course(name::AbstractString, credit_hours::Real; prefix::AbstractString="", learning_outcomes::Array{LearningOutcome} = Array{LearningOutcome,1}(),
                    num::AbstractString="", institution::AbstractString="", canonical_name::AbstractString="", id::Int=0)
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
        this.canonical_name = canonical_name
        this.requisites = Dict{Int, Requisite}()
        this.metrics = Dict{String, Any}()
        this.learning_outcomes = learning_outcomes
        this.vertex_id = Dict{Int, Int}()
        return this
    end
end

"""
    add_requisite!(rc, tc, requisite_type)

Add course rc as a requisite, of type requisite_type, for target course tc.

# Requisite types
One of the following requisite types must be specified for `rc`:
- `pre` : a prerequisite course that must be passed before `tc` can be attempted.
- `co`  : a co-requisite course that may be taken before or at the same time as `tc`.
- `strict_co` : a strict co-requisite course that must be taken at the same time as `tc`.
"""
function add_requisite!(requisite_course::Course, course::Course, requisite_type::Requisite)
    course.requisites[requisite_course.id] = requisite_type
end

"""
    add_requisite!([rc1, rc2, ...], tc, [requisite_type1, requisite_type2, ...])

Add a collection of requisites to target course tc.

# Requisite types
The following requisite types may be specified for `rc`:
- `pre` : a prerequisite course that must be passed before `tc` can be attempted.
- `co`  : a co-requisite course that may be taken before or at the same time as `tc`.
- `strict_co` : a strict co-requisite course that must be taken at the same time as `tc`.
"""
function add_requisite!(requisite_course::Array{Course}, course::Course, requisite_type::Array{Requisite})
    @assert length(requisite_course) == length(requisite_type)
    for i = 1:length(requisite_course)
        course.requisites[requisite_course[i].id] = requisite_type[i]
    end
end

"""
    delete_requisite!(rc, tc)

Remove course rc as a requisite for target course tc.  If rc is not an existing requisite for tc, an
error is thrown.

# Requisite types
The following requisite types may be specified for `rc`:
- `pre` : a prerequisite course that must be passed before `tc` can be attempted.
- `co`  : a co-requisite course that may be taken before or at the same time as `tc`.
- `strict_co` : a strict co-requisite course that must be taken at the same time as `tc`.
"""
function delete_requisite!(requisite_course::Course, course::Course)
    #if !haskey(course.requisites, requisite_course.id)  
    #    error("The requisite you are trying to delete does not exist")
    #end
    delete!(course.requisites, requisite_course.id)
end

#"""
#    add_learning_outcome!(course, learning_outcome)
#
#Add a learning outcome to a course.
#"""
#function add_learning_outcome!(course::Course, learning_outcome::LearningOutcome)
#    push!(course.learning_outcomes, learning_outcome)
#end

#"""
#    add_learning_outcome!(course, [lo1, lo2, ...])
#
#Add a collection `lo1, lo2, ...` of learning outcome to a course.
#"""
#function add_learning_outcome!(course::Course, learning_outcome::Array{LearningOutcome})
#    for i = 1:length(learning_outcome)
#        push!(course.learning_outcomes, learning_outcome[i])
#    end
#end

##############################################################
# Curriculum data type
# The required curriculum associated with a degree program
"""
The `Curriculum` data type is used to represent the collection of courses that must be
be completed in order to earn a particualr degree. Thus, we use the terms *curriculum* and
*degree program* synonymously. To instantiate a `Curriculum` use:

    Curriculum(name, courses; <keyword arguments>)

# Arguments
Required:
- `name::AbstractString` : the name of the curriculum.
- `courses::Array{Course}` : the collection of required courses that comprise the curriculum.
Keyword:
- `degree_type::Degree` : the type of degree, allowable 
    types: `AA`, `AS`, `AAS`, `BA`, `BS` (default).
- `institution:AbstractString` : the name of the institution offering the curriculum.
- `system_type::System` : the type of system the institution uses, allowable 
    types: `semester` (default), `quarter`.
- `CIP::AbstractString` : the Classification of Instructional Programs (CIP) code for the 
    curriculum.  See: `https://nces.ed.gov/ipeds/cipcode`

# Examples:
```julia-repl
julia> Curriculum("Biology", courses, institution="South Harmon Tech", degree_type=AS, CIP="26.0101")
```
"""
mutable struct Curriculum
    id::Int                             # Unique curriculum ID
    name::AbstractString                # Name of the curriculum (can be used as an identifier)
    institution::AbstractString         # Institution offering the curriculum
    degree_type::Degree                 # Type of degree_type
    system_type::System                 # Semester or quarter system
    CIP::AbstractString                 # CIP code associated with the curriculum
    courses::Array{Course}              # Array of required courses in curriculum
    num_courses::Int                    # Number of required courses in curriculum
    credit_hours::Real                  # Total number of credit hours in required curriculum
    graph::SimpleDiGraph{Int}           # Directed graph representation of pre-/co-requisite structure
                                        # of the curriculum
    learning_outcomes::Array{LearningOutcome}  # A list of learning outcomes associated with the curriculum
    metrics::Dict{String, Any}          # Curriculum-related metrics

    # Constructor
    function Curriculum(name::AbstractString, courses::Array{Course}; learning_outcomes::Array{LearningOutcome} = Array{LearningOutcome,1}(),
                        degree_type::Degree=BS, system_type::System=semester, institution::AbstractString="", CIP::AbstractString="26.0101", 
                        id::Int=0, sortby_ID::Bool=true)
        this = new()
        this.name = name
        this.degree_type = degree_type
        this.system_type = system_type
        this.institution = institution
        if id == 0
            this.id = mod(hash(this.name * this.institution * string(this.degree_type)), UInt32)
        else 
            this.id = id
        end
        this.CIP = CIP
        if sortby_ID
            this.courses = sort(collect(courses), by = c -> c.id)
        else
            this.courses = courses
        end
        this.num_courses = length(this.courses)
        this.credit_hours = total_credits(this)
        this.graph = SimpleDiGraph{Int}()
        create_graph!(this)
        this.metrics = Dict{String, Any}()
        this.learning_outcomes = learning_outcomes
        errors = IOBuffer()
        if !(isvalid_curriculum(this, errors))
            printstyled("WARNING: Curriculum was created, but is invalid due to requisite cycle(s):", color = :yellow)
            println(String(take!(errors)))
        elseif extraneous_requisites(this, errors)  # extraneous requisites only checked if the curriculum is valid
            printstyled("WARNING: $(this.institution) Curriculum: $(this.name) contains extraneous requisite(s).\n You may list extraneous requisites using the extraneous_requisites() function.\n\n", color = :yellow)
            take!(errors)  # flush the error buffer
        end
        return this
    end
end

# TODO: update a curriculum graph if requisites have been added/removed or courses have been added/removed
#function update_curriculum(curriculum::Curriculum, courses::Array{Course}=())
#    # if courses array is empty, no new courses were added
#end

# Map course IDs to vertex IDs in an underlying curriculum graph.
function map_vertex_ids(curriculum::Curriculum)
    mapped_ids = Dict{Int, Int}()
    for c in curriculum.courses
        mapped_ids[c.id] = c.vertex_id[curriculum.id]
    end
    return mapped_ids
end

# Return the course associated with a course id in a curriculum
function course_from_id(curriculum::Curriculum, id::Int)
    for c in curriculum.courses
        if c.id == id
            return c
        end
    end
end

# Return the course associated with a vertex id in a curriculum graph
function course_from_vertex(curriculum::Curriculum, vertex::Int)
    c = curriculum.courses[vertex]
end

# The total number of credit hours in a curriculum
function total_credits(curriculum::Curriculum)
    total_credits = 0
    for c in curriculum.courses
        total_credits += c.credit_hours
    end
    return total_credits
end

#"""
#    create_graph!(c::Curriculum)
#
#Create a curriculum directed graph from a curriculum specification. The graph is stored as a 
#LightGraph.jl implemenation within the Curriculum data object.
#"""
function create_graph!(curriculum::Curriculum)
    for (i, c) in enumerate(curriculum.courses)
        if add_vertex!(curriculum.graph)
            c.vertex_id[curriculum.id] = i    # The vertex id of a course w/in the curriculum
                                              # Lightgraphs orders graph vertices sequentially
                                              # TODO: make sure course is not alerady in the curriculum   
        else
            error("vertex could not be created")
        end
    end
    mapped_vertex_ids = map_vertex_ids(curriculum)
    for c in curriculum.courses
        for r in collect(keys(c.requisites))
            if add_edge!(curriculum.graph, mapped_vertex_ids[r], c.vertex_id[curriculum.id])
            else
                error("edge could not be created")
            end
        end
    end
end

function requisite_type(curriculum::Curriculum, src_course_id::Int, dst_course_id::Int)
    src = 0; dst = 0
    for c in curriculum.courses
        if c.vertex_id == src_course_id
            src = c
        elseif c.vertex_id == dst_course_id
            dst = c
        end
    end
    if ((src == 0 || dst == 0) || !haskey(dst.requisites, src))
        error("edge ($src_course_id, $dst_course_id) does not exist")
    else
        return dst.requisites[src]
    end
end

##############################################################
# Term data type
"""
The `Term` data type is used to represent a single term within a `DegreePlan`. To 
instantiate a `Term` use:

    Term([c1, c2, ...])

where c1, c2, ... are `Course` data objects
"""
mutable struct Term
    courses::Array{Course}              # The courses associated with a term in a degree plan
    num_courses::Int                    # The number of courses in the Term
    credit_hours::Real                  # The number of credit hours associated with the term
    metrics::Dict{String, Any}          # Term-related metrics

    # Constructor
    function Term(courses::Array{Course})
        this = new()
        this.num_courses = length(courses)
        this.courses = Array{Course}(undef, this.num_courses)
        this.credit_hours = 0
        for i = 1:this.num_courses
            this.courses[i] = courses[i]
            this.credit_hours += courses[i].credit_hours
        end
        this.metrics = Dict{String, Any}()
        return this
    end
end

##############################################################
# Degree Plan data types
"""
The `DegreePlan` data type is used to represent the collection of courses that must be
be completed in order to earn a particualr degree.  To instantiate a `Curriculum` use:

    DegreePlan(name, curriculum, terms, additional_courses)

# Arguments
- `name::AbstractString` : the name of the degree plan.
- `curriculum::Curriculum` : the curriculum the degree plan must satisfy.
- `terms::Array{Term}` : the arrangement of terms associated with the degree plan.
- `additional_courses::Array{Course}` : additional courses in the degree plan that are not
   a part of the curriculum. E.g., a prerequisite math class to the first required math
   class in the curriculum.

# Examples:
```julia-repl
julia> DegreePlan("Biology 4-year Degree Plan", curriculum, terms)
```
"""
mutable struct DegreePlan
    name::AbstractString                # Name of the degree plan
    curriculum::Curriculum              # Curriculum the degree plan satisfies
    additional_courses::Array{Course}   # Additional (non-required) courses added to the curriculum,
                                        # e.g., these may be preparatory courses
    graph::SimpleDiGraph{Int}           # Directed graph representation of pre-/co-requisite structure 
                                        # of the degre plan
    terms::Array{Term}                  # The terms associated with the degree plan
    num_terms::Int                      # Number of terms in the degree plan
    credit_hours::Real                  # Total number of credit hours in the degree plan
    metrics::Dict{String, Any}          # Dergee Plan-related metrics

    # Constructor
    function DegreePlan(name::AbstractString, curriculum::Curriculum, terms::Array{Term,1},
                        additional_courses::Array{Course,1}=Array{Course,1}())
        this = new()
        this.name = name
        this.curriculum = curriculum
        this.num_terms = length(terms)
        this.terms = Array{Term}(undef, this.num_terms)
        this.credit_hours = 0
        for i = 1:this.num_terms
            this.terms[i] = terms[i]
            this.credit_hours += terms[i].credit_hours
        end
        if isassigned(additional_courses)
            this.additional_courses = Array{Course}(undef, length(additional_courses))
            for i = 1:length(additional_courses)
                this.additional_courses[i] = additional_courses[i]
            end
        end
        this.metrics = Dict{String, Any}()
        return this
    end
end

# Check if a degree plan is valid.
# Print error_msg using println(String(take!(error_msg))), where error_msg is the buffer returned by this function
"""
    isvalid_degree_plan(plan::DegreePlan, errors::IOBuffer)

Tests whether or not the degree plan `plan` is valid.  Returns a boolean value, with `true` indicating the 
degree plan is valid, and `false` indicating it is not.

If `plan` is not valid, the reason(s) why are written to the `errors` buffer. To view these 
reasons, use:

```julia-repl
julia> errors = IOBuffer()
julia> isvalid_degree_plan(plan, errors)
julia> println(String(take!(errors)))
```

There are two reasons why a curriculum graph might not be valid:

- Requisites not satsified : A prerequisite for a course occurs in a later term than the course itself.
- Incomplete plan : There are course in the curriculum not included in the degree plan.
- Redundant plan : The same course appears in the degree plan multiple times. 

"""
function isvalid_degree_plan(plan::DegreePlan, error_msg::IOBuffer=IOBuffer())
    validity = true
    # All requisite relationships are satisfied?
    #  -no backwards pointing requisites 
    for i in 2:plan.num_terms
        for c in plan.terms[i].courses
            for j in i-1:-1:1
                for k in plan.terms[j].courses
                    for l in keys(k.requisites) 
                        if l == c.id 
                            validity = false
                            write(error_msg, "\n-Invalid requisite: $(c.name) in term $i is a requisite for $(k.name) in term $j")
                        end
                    end 
                end
            end
        end
    end
    #  -requisites within the same term must be corequisites
    for i in 1:plan.num_terms
        for c in plan.terms[i].courses
            for r in plan.terms[i].courses
                if c == r
                    continue
                elseif haskey(c.requisites, r.id) 
                    if c.requisites[r.id] == pre
                        validity = false
                        write(error_msg, "\n-Invalid prerequisite: $(r.name) in term $i is a prerequisite for $(c.name) in the same term")
                    end
                end
            end
        end
    end
    #  -TODO: strict co-requisites must be in the same term
    # All courses in the curriculum are in the degree plan?
    curric_classes = Set()
    dp_classes = Set()
    for i in plan.curriculum.courses
        push!(curric_classes, i.id)  
    end
    for i = 1:plan.num_terms
        for j in plan.terms[i].courses
            push!(dp_classes, j.id)
        end
    end
    if length(setdiff(curric_classes, dp_classes)) > 0
        validity = false
        for i in setdiff(curric_classes, dp_classes)
            c = course_from_id(plan.curriculum, i)
            write(error_msg, "\n-Degree plan is missing required course: $(c.name)")
        end
    end
    # Is a course in the degree plan multiple times?
    dp_classes = Set()
    for i = 1:plan.num_terms
        for j in plan.terms[i].courses
            if in(j.id, dp_classes)
                validity = false
                write(error_msg, "\n-Course $(j.name) is listed multiple times in degree plan")
            else
                push!(dp_classes, j.id)
            end
        end
    end 
    return validity 
end

"""
    find_term(plan::DegreePlan, course::Course)

In degree plan `plan`, find the term in which course `course` appears.  If `course` in not in the degree plan an
error message is provided.
"""
function find_term(plan::DegreePlan, course::Course)
    for (i, term) in enumerate(plan.terms)
        if course in term.courses
            return i
        end
    end
    write(error_msg, "Course $(course.name) is not in the degree plan")
end

# ugly print of degree plan 
"""
    print_plan(plan::DegreePlan) 

Ugly print out of a degree plan to the Julia console.
"""
function print_plan(plan::DegreePlan)
    println("\nDegree Plan: $(plan.name) for $(plan.curriculum.degree_type) in $(plan.curriculum.name)\n")
    println(" $(plan.credit_hours) credit hours")
    for i = 1:plan.num_terms
        println(" Term $i courses:")
        for j in plan.terms[i].courses
            println(" $(j.name) ")
        end
        println("\n")
    end
end
