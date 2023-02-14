##############################################################
# DegreeRequirement data types

# Create an integer data type called Grade
Grade = UInt64

# function for converting a letter grade into a integer, divide by 3 to convert to 4-point GPA scale 
function grade(letter_grade::AbstractString)
    if letter_grade == "A➕"
        return convert(Grade, 13) 
    elseif letter_grade == "A"
        return convert(Grade, 12) 
    elseif letter_grade == "A➖"
        return convert(Grade, 11) 
    elseif letter_grade == "B➕"
        return convert(Grade, 10) 
    elseif letter_grade == "B"
        return convert(Grade, 9) 
    elseif letter_grade == "B➖"
        return convert(Grade, 8) 
    elseif letter_grade == "C➕"
        return convert(Grade, 7) 
    elseif letter_grade == "C"
        return convert(Grade, 6) 
    elseif letter_grade == "C➖"
        return convert(Grade, 5) 
    elseif letter_grade == "D➕"
        return convert(Grade, 4) 
    elseif letter_grade == "D"
        return convert(Grade, 3) 
    elseif letter_grade == "D➖"
        return convert(Grade, 2) 
    elseif letter_grade == "P"
        return convert(Grade, 0) 
    elseif letter_grade == "F"
        return convert(Grade, 0)  
    elseif letter_grade == "I" 
        return convert(Grade, 0)  
    elseif letter_grade == "WP" 
        return convert(Grade, 0)  
    elseif letter_grade == "W" 
        return convert(Grade, 0)  
    elseif letter_grade == "WF" 
        return convert(Grade, 0)  
    else
        error("letter grade $letter_grade is not supported")  
    end
end

# function for converting an integer letter grade, divide by 3 to convert to 4-point GPA scale 
function grade(int_grade::Grade)
    if int_grade == 13
        return "A➕" 
    elseif int_grade == 12
        return "A"
    elseif int_grade == 11
        return "A➖" 
    elseif int_grade == 10
        return "B➕" 
    elseif int_grade == 9
        return "B" 
    elseif int_grade == 8
        return "B➖"
    elseif int_grade == 7
        return "C➕" 
    elseif int_grade == 6
        return "C" 
    elseif int_grade == 5
        return "C➖" 
    elseif int_grade == 4
        return "D➕" 
    elseif int_grade == 3
        return "D" 
    elseif int_grade == 2
        return "D➖" 
    elseif int_grade == 0
        return "F" 
    else
        error("grade value $int_grade is not supported")    
    end
end

# Data types for requirements:
#
#                               AbstractRequirement
#                                /               \    
#                          CourseSet         RequirementSet
#
# A requirement may involve a set of courses (CourseSet), or a set of requirements (RequirementSet), but not both.
"""
The `AbstractRequirement` data type is used to represent the requirements associated with an academic program. A 
reqiurement may consist of either the set of courses that can be used to satisfy the requirement, or a set of 
requirements that all must be satisfied. That is, the two possible concrete subtypes of an `AbstractRequirement` 
are:
 - `CourseSet` : a set of courses that may be used to satisfy a requirement.
 - `RequirementSet` : a set of requirements that may be used to satisfied a requirement. The requirement set may 
    consist of other RequirementSets or CourseSets (these are the children of the parent `RequirementSet`).

A valid set of requirements for a degree program is created as a tree of requirements, where all leaves in the 
tree must be `CourseSet` objects.
"""
abstract type AbstractRequirement end

"""
The `CourseSet` data type is used to represent the requirements associated with an academic program. A 
reqiurement may consist of either the set of courses that can be used to satisfy the requirement, or a set of 
requirements that all must be satisfied. That is, a  `Requirement` must be one of two types:
 - `course_set` : the set of courses that are used to satisfy the requirement are specifed in the `courses` array.
 - `requirement_set` : that set of requirements that must be satisfied are specified in the `requirements` array.

To instantiate a `CourseSet` use:

    CourseSet(name, credit_hours, courses, description)

# Arguments
Required:
- `name::AbstractString` : the name of the requirement.
- `credit_hours::Real` : the number of credit hours associated with the requirement.
- `course_reqs::Array{Pair{Course,Grade}} ` : the collection of courses that can be used to satisfy the requirement, 
    and the minimum grade required in each.

Keyword:
- `description::AbstractString` : A detailed description of the requirement. Default is the empty string.
- `course_catalog::CourseCatalog` : Course catalog to draw courses from using the `prefix_regex` and `num_regex` regular 
    expressions (positive matches are added to the course_reqs array). Note: both `prefix_regex` and `num_regex` must 
    match in order for a course to be added the `course_reqs` array.
- `prefix_regex::Regex` : regular expression for matching a course prefix in the course catalog. Default is `".*"`, 
    i.e., match any character any number of times.
- `num_regex::Regex` : regular expression for matching a course number in the course catalog. Default is `".*"`, 
    i.e., match any character any number of times. 
- `min_grade::Grade` : The minimum letter grade that must be earned in courses satisfying the regular expressions.
- `double_count::Bool` : Specifies whether or not each course in the course set can be used to satisfy other requirements 
    that contain any of the courses in this `CourseSet`. Default = false

# Examples:
```julia-repl
julia> CourseSet("General Education - Mathematics", 9, courses)
```
where `courses` is an array of Course=>Grade `Pairs`, i.e., the set of courses/minimum grades that can satsfy this 
degree requirement.
"""
mutable struct CourseSet <: AbstractRequirement
    id::Int                             # Unique requirement id
    name::AbstractString                # Name of the requirement (must be unique)
    description::AbstractString         # Requirement description 
    credit_hours::Real                  # The number of credit hours required to satisfy the requirement
    course_reqs::Array{Pair{Course, Grade}}  # The courses that the required credit hours may be drawn from, and the minimum grade that must be earned in each
    course_catalog::CourseCatalog       # Course catalog to draw courses from using the following regular expressions (positive matches are stored in course_reqs)
    prefix_regex::Regex                 # Regular expression for matching a course prefix in the course catalog.  
    num_regex::Regex                    # Regular expression for matching a course number in the course catalog, must satisfy both 
    min_grade::Grade                    # The minimum letter grade that must be earned in courses satisfying the regular expressions
    double_count::Bool                  # Each course in the course set can satisfy any other requirement that has the same course. Default = false

    # Constructor
    # A requirement may involve a set of courses, or a set of requirements, but not both
    function CourseSet(name::AbstractString, credit_hours::Real, course_reqs::Array{Pair{Course,Grade},1}=Array{Pair{Course,Grade},1}(); description::AbstractString="", 
                   course_catalog::CourseCatalog=CourseCatalog("", ""), prefix_regex::Regex=r".^", num_regex::Regex=r".^", course_regex::Regex=r".^",
                   min_grade::Grade=grade("D"), double_count::Bool=false)
        # r".^" is a regex that matches nothing
        this = new()
        this.name = name
        this.description = description
        this.credit_hours = credit_hours  
        this.id = mod(hash(this.name * this.description * string(this.credit_hours)), UInt32)
        this.course_reqs = course_reqs 
        this.course_catalog = course_catalog
        this.prefix_regex = prefix_regex
        this.num_regex = num_regex
        this.double_count = double_count
        for c in course_catalog.catalog  # search the supplied course catalog for courses satisfying both prefix and num regular expressions
            if occursin(prefix_regex, c[2].prefix) && occursin(num_regex, c[2].num)
                push!(course_reqs, c[2] => min_grade)
            end
        end
        #if this.credit_hours  # > sum of course credits
        #    ## TODO: add this warning if credits are not sufficient
        #end
        sum = 0
        sorted = sort(this.course_reqs; by = x -> x.first.credit_hours, rev = true)
        for c in sorted
            sum += c.first.credit_hours
            sum >= this.credit_hours ? break : nothing 
        end
        if (sum - this.credit_hours) < 0
            error("Course set $(cs.name) is improperly specified, use is_valid() to check a requirement set for specification errors.")
        end

        return this
    end
end

"""
The `RequirementSet` data type is used to represent a collection of requirements. To instantiate a `RequirementSet` use:

    RequirementSet(name, credit_hours, requirements, description)

# Arguments
Required:
- `name::AbstractString` : the name of the degree requirement set.
- `credit_hours::Real` : the number of credit hours required in order to satisfy the requirement set.
- `requirements::Array{AbstractRequirement}` : the course sets or requirement sets that comprise the requirement set.
Keyword:
- `description::AbstractString` : the description of the requirement set.
- `satisfy::Int` : the number of requirements in the set that must be satisfied.  Default is all.

# Examples:
```julia-repl
julia> RequirementSet("General Education Core", 30, requirements)
```
where `requirements` is an array of `CourseSet` and/or `RequirementSet` objects.
"""
mutable struct RequirementSet <: AbstractRequirement
    id::Int                              # Unique requirement id (internally generated)
    name::AbstractString                 # Name of the requirement (must be unique)
    description::AbstractString          # Requirement description 
    credit_hours::Real                   # The number of credit hours required to satisfy the requirement
    requirements::Array{AbstractRequirement}   # The set of requirements (course sets or requirements sets) that define this requirement 
    satisfy::Int                         # The number of requirements in the set that must be satisfied.  Default is all.
    
    # Constructor
        function RequirementSet(name::AbstractString, credit_hours::Real, requirements::Array{AbstractRequirement,1}; 
            description::AbstractString="", satisfy::Int=0)
        this = new()
        this.name = name
        this.description = description
        this.credit_hours = credit_hours  
        this.id = mod(hash(this.name * this.description * string(this.credit_hours)), UInt32)
        this.requirements = requirements
        if satisfy < 0
            printstyled("WARNING: RequirementSet $(this.name), satisfy cannot be a negative number\n", color = :yellow) 
        elseif satisfy == 0
            this.satisfy = length(requirements)  # satisfy all requirements
        elseif satisfy <= length(requirements)
            this.satisfy = satisfy
        else
            # trying to satisfy more then the # of available sub-requirements
            printstyled("WARNING: RequirementSet $(this.name), satisfy variable cannot be greater than the number of available requirements\n", color = :yellow)
        end
        return this
    end
end

"""
Determine whether or not a set of requirements contained in a requirements tree rooted at `root` has credit hour 
constraints that are possible to satisfy.

    is_valid(root::RequirementSet, errors::IOBuffer)

```julia-repl
julia> errors = IOBuffer()
julia> is_valid(root, errors)
julia> println(String(take!(errors)))
```

The credit hour constraints associated with particular set of requirements may be specified in a way that 
makes them impossible to satsify. This function searches for particular cases of this problem, and if found, 
reports them in an error message. 
"""
function is_valid(
    root::AbstractRequirement, 
    error_msg::IOBuffer = IOBuffer()
)
    validity = true
    reqs = preorder_traversal(root)
    for r in reqs  
        credit_total = 0
        if typeof(r) == CourseSet
            for c in r.course_reqs
                credit_total += c[1].credit_hours
            end
            # credit_total = sum(sum(x)->x, )
            if r.credit_hours > credit_total 
                validity = false
                write(error_msg, "CourseSet: $(r.name) is unsatisfiable,\n\t $(r.credit_hours) credits are required from courses having only $(credit_total) credit hours.\n")
            end
        else # r is a RequirementSet
            credit_ary = []
            for child in r.requirements
                push!(credit_ary, child.credit_hours)
            end
            max_credits = 0
            for c in combinations(credit_ary, r.satisfy) # find the max. credits possible from r.satisfy number of requirements
                sum(c) > max_credits ? max_credits = sum(c) : nothing
            end
            if r.credit_hours > max_credits
                validity = false
                write(error_msg, "RequirementSet: $(r.name) is unsatisfiable,\n\t $(r.credit_hours) credits are required from sub-requirements that can provide at most $(max_credits) credit hours.\n")
            end
        end
    end
    return validity
end