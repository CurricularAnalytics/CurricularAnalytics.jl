##############################################################
# Term data type
"""
The `Term` data type is used to represent a single term within a `DegreePlan`. To 
instantiate a `Term` use:

    Term([c1, c2, ...])

where c1, c2, ... are `Course` data objects
"""
mutable struct Term
    courses::Array{AbstractCourse}              # The courses associated with a term in a degree plan
    num_courses::Int                    # The number of courses in the Term
    credit_hours::Real                  # The number of credit hours associated with the term
    metrics::Dict{String, Any}          # Term-related metrics
    metadata::Dict{String, Any}         # Term-related metadata

    # Constructor
    function Term(courses::Array{AbstractCourse})
        this = new()
        this.num_courses = length(courses)
        this.courses = Array{AbstractCourse}(undef, this.num_courses)
        this.credit_hours = 0
        for i = 1:this.num_courses
            this.courses[i] = courses[i]
            this.credit_hours += courses[i].credit_hours
        end
        this.metrics = Dict{String, Any}()
        this.metadata = Dict{String, Any}()
        return this
    end

    function Term(courses::Array{Course})
        Term(convert(Array{AbstractCourse}, courses))
    end

end

##############################################################
# Degree Plan data type
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
    additional_courses::Array{AbstractCourse}   # Additional (non-required) courses added to the curriculum,
                                        # e.g., these may be preparatory courses
    graph::SimpleDiGraph{Int}           # Directed graph representation of pre-/co-requisite structure 
                                        # of the degre plan
    terms::Array{Term}                  # The terms associated with the degree plan
    num_terms::Int                      # Number of terms in the degree plan
    credit_hours::Real                  # Total number of credit hours in the degree plan
    metrics::Dict{String, Any}          # Dergee Plan-related metrics
    metadata::Dict{String, Any}         # Dergee Plan-related metadata

    # Constructor
    function DegreePlan(name::AbstractString, curriculum::Curriculum, terms::Array{Term,1},
                        additional_courses::Array{AbstractCourse,1}=Array{AbstractCourse,1}())
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
            this.additional_courses = Array{AbstractCourse}(undef, length(additional_courses))
            for i = 1:length(additional_courses)
                this.additional_courses[i] = additional_courses[i]
            end
        end
        this.metrics = Dict{String, Any}()
        this.metadata = Dict{String, Any}()
        return this
    end

    # Generates a warning but is currently needed. 
    # This SHOULD NOT be needed but for some reason Julia fails to recognize when concrete elements is passed but the method accepts abstract type
    function DegreePlan(name::AbstractString, curriculum::Curriculum, terms::Array{Term,1}, additional_courses::Array{Course,1}=Array{Course,1}())
        DegreePlan(name, curriculum, terms, convert(Array{AbstractCourse}, additional_courses))
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