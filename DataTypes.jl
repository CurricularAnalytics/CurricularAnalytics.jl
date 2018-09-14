# file: DataTypes.jl

# Enumerated types
@enum Degree AA AS AAS BA BS
@enum System semester quarter
@enum Requisite pre co strict_co
@enum EdgeClass tree_edge back_edge forward_edge cross_edge

##############################################################
# LearningOutcome data type
mutable struct LearningOutcome
    id::Int                             # Unique id for the learning outcome,
                                        # set when the cousrse is added to a graph
    name::AbstractString                # Name of the learning outcome
    description::AbstractString         # A description of the learning outcome
    hours::Int                          # number of class hours that should be devoted
                                        # to the learning outcome
    requisites::Dict{LearningOutcome, Requisite} # List of requisites, in
                                                 #(requisite_learning_outcome, requisite_type) format
    metrics::Dict{String, Any}          # Learning outcome-related metrics

    # Constructor
    function LearningOutcome(name::AbstractString, description::AbstractString, hours::Int=0)
        this = new()
        this.name
        this.description = description
        this.hours = hours
        this.requisites = Dict{LearningOutcome, Requisite}()
        this.metrics = Dict{String, Any}()
        return this
    end
end

function add_requisite!(requisite_lo::LearningOutcome, lo::LearningOutcome, requisite_type::Requisite)
    lo.requisites[requisite_lo] = requisite_type
end

function add_requisite!(requisite_lo::Array{LearningOutcome}, lo::LearningOutcome, requisite_type::Array{Requisite})
    @assert length(requisite_lo) == length(requisite_type)
    for i = 1:length(requisite_lo)
        lo.requisites[lo[i]] = requisite_type[i]
    end
end

##############################################################
# Course data type
mutable struct Course
    id::Int                             # Unique course id
    vertex_id::Int                      # The vertex id of the course w/in a curriculum graph -- this id is
                                        # only set when the cousrse is added to a curriculum
    name::AbstractString                # Name of the course, e.g., Introduction to Psychology
    credit_hours::Int                   # Number of credit hours associated with course. For the
                                        # purpose of analytics, variable credits are not supported
    prefix::AbstractString              # Typcially a department prefix, e.g., PSY
    num::AbstractString                 # Course number, e.g., 101, or 302L
    institution::AbstractString         # Institution offering the course
    canonical_name::AbstractString      # Standard name used to denote the course in the
                                        # discipline, e.g., Psychology I
    requisites::Dict{Course, Requisite} # List of requisites, in (requisite_course, requisite_type) format
    learning_outcomes::Array{LearningOutcome}  # A list of learning outcomes associated with the course
    metrics::Dict{String, Any}          # Course-related metrics

    # Constructor
    function Course(name::AbstractString, credit_hours::Int; prefix::AbstractString="",
                    num::AbstractString="", institution::AbstractString="", canonical_name::AbstractString="")
        this = new()
        this.name = name
        this.credit_hours = credit_hours
        this.prefix = prefix
        this.num = num
        this.institution = institution
        this.canonical_name = canonical_name
        this.requisites = Dict{Course, Requisite}()
        this.metrics = Dict{String, Any}()
        return this
    end
end

function add_requisite!(requisite_course::Course, course::Course, requisite_type::Requisite)
    course.requisites[requisite_course] = requisite_type
end

function add_requisite!(requisite_course::Array{Course}, course::Course, requisite_type::Array{Requisite})
    @assert length(requisite_course) == length(requisite_type)
    for i = 1:length(requisite_course)
        course.requisites[course[i]] = requisite_type[i]
    end
end

##############################################################
# Curriculum data type
# The required curriculum associated with a degree program
mutable struct Curriculum
    name::AbstractString                # Name of the curriculum (can be used as an identifier)
    institution::AbstractString         # Institution offering the curriculum
    degree_type::Degree                 # Type of degree_type
    system_type::System                 # Semester or quarter system
    CIP::AbstractString                 # CIP code associated with the curriculum
    courses::Array{Course}              # Array of required courses in curriculum
    num_courses::Int                    # Number of required courses in curriculum
    credit_hours::Int                   # Total number of credit hours in required curriculum
    graph::SimpleDiGraph{Int}           # Directed graph representation of pre-/co-requisite structure
    metrics::Dict{String, Any}      # Curriculum-related metrics

    # Constructor
    function Curriculum(name::AbstractString, courses::Array{Course}; degree_type::Degree=BS, system_type::System=semester,
                        institution::AbstractString="", CIP::AbstractString="")
        this = new()
        this.name = name
        this.degree_type = degree_type
        this.system_type = system_type
        this.institution = institution
        this.CIP = CIP
        this.courses = courses
        this.num_courses = length(this.courses)
        this.credit_hours = total_credits(this)
        this.graph = SimpleDiGraph{Int}()
        create_graph!(this)
        this.metrics = Dict{String, Any}()
        return this
    end
end

function total_credits(curriculum::Curriculum)
    total_credits = 0
    for c in curriculum.courses
        total_credits += c.credit_hours
    end
    return total_credits
end

function create_graph!(curriculum::Curriculum)
    for (i, c) in enumerate(curriculum.courses)
        if add_vertex!(curriculum.graph)
            c.vertex_id = i # graph vertex id == course vertex_id, assumes LightGraph
                            # vertex ids start at 1 and are incremented by 1 as
                            # vertices are created.
        else
            error("vertex could not be created")
        end
    end
    for c in curriculum.courses
        for r in collect(keys(c.requisites))
            if add_edge!(curriculum.graph, r.vertex_id, c.vertex_id)
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
mutable struct Term
    courses::Array{Course}              # The courses associated with a term in a degree plan
    num_courses::Int                    # The number of courses in the Term
    credit_hours::Int                   # The number of credit hours associated with the term
    metrics::Dict{String, Any}          # Course-related metrics

    # Constructor
    function Term(courses::Array{Course})
        this = new()
        this.num_courses = length(courses)
        this.courses = Array{Course}(this.num_courses)
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
mutable struct DegreePlan
    name::AbstractString                # Name of the degree plan
    curriculum::Curriculum              # Curriculum the degree plan satisfies
    additional_courses::Array{Course}   # Additional (non-required) courses added to the curriculum,
                                        # e.g., these may be preparatory courses
    terms::Array{Term}                  # The terms associated with the degree plan
    num_terms::Int                      # Number of terms in the degree plan
    credit_hours::Int                   # Total number of credit hours in the degree plan

    # Constructor
    function DegreePlan(name::AbstractString, curriculum::Curriculum, terms::Array{Term},
                        additional_courses::Array{Course}=Array{Course}())
        this = new()
        this.name = name
        this.curriculum = curriculum
        this.num_terms = length(terms)
        this.terms = Array{Term}(this.num_terms)
        this.credit_hours = 0
        for i = 1:this.num_terms
            this.terms[i] = terms[i]
            this.credit_hours += terms[i].credit_hours
        end
        if isassigned(additional_courses)
            this.additional_courses = Array{Course}(length(additional_courses))
            for i = 1:length(additional_courses)
                this.additional_courses[i] = additional_courses[i]
            end
        end
        return this
    end
end
