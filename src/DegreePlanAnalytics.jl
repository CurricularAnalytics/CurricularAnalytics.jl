#File: DegreePlanAnalytics.jl

# Basic metrics for a degree plan, based soley on credits
"""
    basic_metrics(plan)

Compute the basic metrics associated with degree plan `plan`, and return an IO buffer containing these metrics.  The baseic 
metrics are primarily concerned with how credits hours are distributed across the terms in a plan.  The basic metrics are 
also stored in the `metrics` dictionary associated with the degree plan.

# Arguments
Required:
- `plan::DegreePlan` : a valid degree plan (see [Degree Plans](@ref)). 

The basic metrics computed include:

- number of terms : The total number of terms (semesters or quarters) in the degree plan, ``m``.
- total credit hours : The total number of credit hours in the degree plan.
- max. credits in a term : The maximum number of credit hours in any one term in the degree plan.
- min. credits in a term : The minimum number of credit hours in any one term in the degree plan.
- max. credit term : The earliest term in the degree plan that has the maximum number of credit hours.
- min. credit term : The earliest term in the degree plan that has the minimum number of credit hours.
- avg. credits per term : The average number of credit hours per term in the degree plan, ``\\overline{ch}``.
- term credit hour std. dev. : The standard deviation of credit hours across all terms ``\\sigma``.  If ``ch_i`` denotes the number 
   of credit hours in term ``i``, then

```math
\\sigma = \\sqrt{\\sum_{i=1}^m {(ch_i - \\overline{ch})^2 \\over m}}
```

To view the basic degree plan metrics associated with degree plan `plan` in the Julia console use:

```julia-repl
julia> metrics = basic_metrics(plan)
julia> println(String(take!(metrics)))
julia> # The metrics are also stored in a dictonary that can be accessed as follows
julia> plan.metrics
```
"""
function basic_metrics(plan::DegreePlan)
    buf = IOBuffer()
    write(buf, "\nCurriculum: $(plan.curriculum.name)\nDegree Plan: $(plan.name)\n")
    plan.metrics["total credit hours"] = plan.credit_hours
    write(buf, "  total credit hours = $(plan.credit_hours)\n")
    plan.metrics["number of terms"] = plan.num_terms
    write(buf, "  number of terms = $(plan.num_terms)\n")
    max = 0
    min = plan.credit_hours
    max_term = 0
    min_term = 0
    var = 0
    req_distance = 0
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
        var = var + (plan.terms[i].credit_hours - avg)^2
    end
    plan.metrics["max. credits in a term"] = max
    plan.metrics["max. credit term"] = max_term
    write(buf, "  max. credits in a term = $(max), in term $(max_term)\n")
    plan.metrics["min. credits in a term"] = min
    plan.metrics["min. credit term"] = min_term
    write(buf, "  min. credits in a term = $(min), in term $(min_term)\n")
    plan.metrics["avg. credits per term"] = avg
    plan.metrics["term credit hour std. dev."] = sqrt(var/plan.num_terms)
    write(buf, "  avg. credits per term = $(avg), with std. dev. = $(plan.metrics["term credit hour std. dev."])\n")
    return buf
 end

 # Degree plan metrics based upon the distance between requsites and the classes that require them.
 """
    requisite_distance(DegreePlan, course::Course)

For a given degree plan `plan` and target course `course`, this function computes the total distance in the degree plan between `course` and 
all of its requisite courses.  

# Arguments
Required:
- `plan::DegreePlan` : a valid degree plan (see [Degree Plans](@ref)).
- `course::Course` : the target course.

The distance between a target course and one of its requisites is given by the number of terms that separate the target 
course from that particular requisite in the degree plan.  To compute the requisite distance, we sum this distance over all
requisites.  That is, if write let ``T_j^p`` denote the term in degree plan ``p`` that course ``c_j`` appears in, then for a 
degree plan with underlying curriculum graph ``G_c = (V,E)``, the requisite distance for course ``c_j`` in degree plan ``p``, 
denoted ``rd_{v_j}^p``, is:

```math
rd_{v_j}^p = \\sum_{\\{i | (v_i, v_j) \\in E\\}} (T_j - T_i).
```

In general, it is desirable for a course and its requisites to appear as close together as possible in a degree plan.
The requisite distance metric computed by this function is stored in the associated `Course` data object.
"""
function requisite_distance(plan::DegreePlan, course::Course)
    distance = 0
    term = find_term(plan, course)
    for req in keys(course.requisites[1])
        distance = distance + (term - find_term(plan, course_from_id(plan.curriculum, req)))
    end 
    return course.metrics["requisite distance"] = distance
end

"""
    requisite_distance(plan::DegreePlan)

For a given degree plan `plan`, this function computes the total distance between all courses in the degree plan, and 
the requisites for those courses.  

# Arguments
Required:
- `plan::DegreePlan` : a valid degree plan (see [Degree Plans](@ref)).   

The distance between a course a requisite is given by the number of terms that separate the course from 
its requisite in the degree plan.  If ``rd_{v_i}^p`` denotes the requisite distance between course 
``c_i`` and its requisites in degree plan ``p``, then the total requisite distance for a degree plan, 
denoted ``rd^p``, is given by:

```math
rd^p = \\sum_{v_i \\in V} = rd_{v_i}^p
```

In general, it is desirable for a course and its requisites to appear as close together as possible in a degree plan.  
Thus, a degree plan that minimizes these distances is desirable.  A optimization function that minimizes requisite 
distances across all courses in a degree plan is described in [Optimized Degree Plans]@ref.
The requisite distance metric computed by this function will be stored in the associated `DegreePlan` data object.
"""
function requisite_distance(plan::DegreePlan)
    distance = 0
    for c in plan.curriculum.courses
        distance = distance + requisite_distance(plan, c)
    end
    return plan.metrics["requisite distance"] = distance
end