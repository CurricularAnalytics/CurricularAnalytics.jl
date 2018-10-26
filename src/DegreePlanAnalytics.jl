#File DegreePlanAnalytics.jl

# Check if a degree plan is valid.
# Print error_msg using println(String(take!(error_msg))), where error_msg is the buffer returned by this function
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
                            if validity == true 
                                write(error_msg, "\nDegree Plan $(plan.name) has invalid requisite relationships:")
                                validity = false
                            end
                            write(error_msg, "\n -Course $(c.name) in term $i is a requisite for course $(k.name) in term $j")
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
                        if validity == true 
                            write(error_msg, "\nDegree Plan $(plan.name) has invalid requisite relationships:")
                            validity = false
                        end
                        write(error_msg, "\n -Course $(r.name) in term $i is a prerequisite for course $(c.name) in the same term")
                    end
                end
            end
        end
    end
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
    if curric_classes != dp_classes
        write(error_msg, "\nDegree Plan $(plan.name) does not contain all required courses. Missing courses:")
        validity == false
        for i in setdiff(curric_classes, dp_classes)
            c = course_from_id(i, plan.curriculum)
            write(error_msg, "\n -$(c.name)")
        end
    end
    # Is a course in the degree plan multiple times?
    dp_classes = Set()
    for i = 1:plan.num_terms
        for j in plan.terms[i].courses
            if in(j.id, dp_classes)
                if validity == true 
                    write(error_msg, "\nCourse $(j.name) is listed multiple times in Degree Plan $(plan.name)")
                    validity = false
                end
            else
                push!(dp_classes, j.id)
            end
        end
    end 
    return validity 
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

