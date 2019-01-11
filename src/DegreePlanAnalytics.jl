#File DegreePlanAnalytics.jl

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
            c = course_from_id(i, plan.curriculum)
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

# Basic metrics for degree plans, based soley on credits
"""
    basic_metrics(plan::DegreePlan)

Computes basic metrics associated with degree plan `plan`.  This metrics are primarily concerned with how credits 
hours are distributed across the terms in a plan.

The basic metrics computed include:

- number of terms : The total number of terms (semesters or quarters) in the degree plan, ``n``.
- total credit hours : The total number of credit hours in the degree plan.
- max. credits in a term : The maximum number of credit hours in any one term in the degree plan.
- min. credits in a term : The minimum number of credit hours in any one term in the degree plan.
- max. credit term : The earliest term in the degree plan that has the maximum number of credit hours.
- min. credit term : The earliest term in the degree plan that has the minimum number of credit hours.
- avg. credits per term : The average number of credit hours per term in the degree plan, ``\\overline{ch}``.
- credit hour variance : The term-by-term credit hour variance, ``\\sigma^2``.  If ``ch_i`` denotes the number 
   of credit hours in term ``i``, then

```math
\\sigma^2 = \\sum_{i=1}^n {(ch_i - \\overline{ch})^2 \\over n}
```

To view the basic degree plan metrics associated with degree plan `plan` in the Julia console use:

```julia-repl
julia> basic_metrics(plan)
julia> plan.metrics
```

"""
function basic_metrics(plan::DegreePlan)
    plan.metrics["number of terms"] = plan.num_terms
    plan.metrics["total credit hours"] = plan.credit_hours
    max = 0
    min = plan.credit_hours
    max_term = 0
    min_term = 0
    var = 0
    avg = plan.credit_hours/plan.num_terms
    for i = 1:plan.num_terms
        if plan.terms[i].credit_hours > max
            max = plan.terms[i].credit_hours
            max_term = i
        end
        if plan.terms[i].credit_hours < min
            min = plan.terms[i].credit_hours
            min_term = i
        end
        var = (plan.terms[i].credit_hours - avg)^2
    end
    plan.metrics["max. credits in a term"] = max
    plan.metrics["min. credits in a term"] = min
    plan.metrics["max. credit term"] = max_term
    plan.metrics["min. credit term"] = min_term
    plan.metrics["avg. credits per term"] = avg
    plan.metrics["credit hour variance"] = var/plan.num_terms
end