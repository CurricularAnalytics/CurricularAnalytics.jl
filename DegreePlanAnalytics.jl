#module DegreePlanAnalytics

# Dependencies
# using LightGraphs, JSON

#include("CurricularAnalytics.jl")

function isvalid_degree_plan(degree_plan::DegreePlan)
    # TODO:
    # 1. check that there is a 1-to-1 match between the courses in the degree
    #    plan, and the curriclum required + additional courses
    # 2. check that all requisite relationships are satisfied
end

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

#end
