#File DegreePlanAnalytics.jl

# Basic metrics for degree plans, based soley on credits
"""
    basic_metrics(plan::DegreePlan)

Computes basic metrics associated with degree plan `plan`.  These metrics are primarily concerned with how credits 
hours are distributed across the terms in a plan.

The basic metrics computed include:

- number of terms : The total number of terms (semesters or quarters) in the degree plan, ``m``.
- total credit hours : The total number of credit hours in the degree plan.
- max. credits in a term : The maximum number of credit hours in any one term in the degree plan.
- min. credits in a term : The minimum number of credit hours in any one term in the degree plan.
- max. credit term : The earliest term in the degree plan that has the maximum number of credit hours.
- min. credit term : The earliest term in the degree plan that has the minimum number of credit hours.
- avg. credits per term : The average number of credit hours per term in the degree plan, ``\\overline{ch}``.
- credit hour variance : The term-by-term credit hour variance, ``\\sigma^2``.  If ``ch_i`` denotes the number 
   of credit hours in term ``i``, then

```math
\\sigma^2 = \\sum_{i=1}^m {(ch_i - \\overline{ch})^2 \\over m}
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
    plan.metrics["min. credits in a term"] = min
    plan.metrics["max. credit term"] = max_term
    plan.metrics["min. credit term"] = min_term
    plan.metrics["avg. credits per term"] = avg
    plan.metrics["credit hour variance"] = var/plan.num_terms
 end

 # Degree plan metrics based upon the distance between requsites and the classes that require them.
 """
    requisite_distance(plan::DegreePlan, course::Int)

For a given degree plan `plan` and course `course`, this function computes the total distance between `course` and 
each of its requisites.  The distance between a course a requisite is given by the number of terms that separate 
the course from its requisite in the degree plan.  If we let ``T_i^p`` denote the term in degree plan ``p`` that course ``c_i`` 
appears in, then for a degree plan with underlying curriculum graph ``G_c = (V,E)``, the requisite distance for course 
``c_i`` in degree plan ``p``, denoted ``rd_{v_i}^p``, is:

```math
rd_{v_i}^p = \\sum{(v_i, v_j) \\in E} (T_i - T_j).
```

In general, it is desirable for a course and its requisites to appear as close together as possible in a degree plan.
The requisite distance metric computed by this function will be stored in the associated `Course` data object.
"""
function requisite_distance(plan::DegreePlan, course::Course)
    distance = 0
    term = find_term(plan, course)
    for req in keys(course.requisites)
        distance = distance + (term - find_term(plan, course_from_id(req, plan.curriculum)))
    end 
    return course.metrics["requisite distance"] = distance
end

"""
    requisite_distance(plan::DegreePlan)

For a given degree plan `plan`, this function computes the total distance between all courses in the degree plan, and 
the requisites for those courses.  The distance between a course a requisite is given by the number of terms that 
separate the course from its requisite in the degree plan.  If ``rd_{v_i}^p`` denotes the requisite distance 
between course ``c_i`` and its requisites in degree plan ``p``, then the total requisite distance for a degree plan, 
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