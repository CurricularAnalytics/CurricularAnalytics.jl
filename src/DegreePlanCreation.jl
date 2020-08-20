# file: DegreePlanCreation.jl

function create_degree_plan(curric::Curriculum, create_terms::Function=bin_filling, name::AbstractString="", additional_courses::Array{AbstractCourse}=Array{AbstractCourse,1}();
                    min_terms::Int=1, max_terms::Int=10, min_cpt::Int=3, max_cpt::Int=19)
    terms = create_terms(curric, additional_courses; min_terms=min_terms, max_terms=max_terms, min_cpt=min_cpt, max_cpt=max_cpt)
    if terms == false
        println("Unable to create degree plan")
        return
    else
        return DegreePlan(name, curric, terms)
    end
end

function bin_filling(curric::Curriculum, additional_courses::Array{AbstractCourse}=Array{AbstractCourse,1}(); min_terms::Int=2, max_terms::Int=10, min_cpt::Int=3, max_cpt::Int=19)
    terms = Array{Term,1}()
    term_credits = 0
    term_courses = Array{AbstractCourse,1}()
    UC = sort!(deepcopy(curric.courses), by=course_num)  # lower numbered courses will be considered first
    while length(UC) > 0
        if ((c = select_vertex(curric, term_courses, UC)) != nothing)
            deleteat!(UC, findfirst(isequal(c), UC))
            if term_credits + c.credit_hours <= max_cpt
                append!(term_courses, [c])
                term_credits = term_credits + c.credit_hours
            else  # exceeded max credits allowed per term
                append!(terms, [Term(term_courses)])
                term_courses = AbstractCourse[c] 
                term_credits = c.credit_hours
            end
            # if c serves as a strict-corequisite for other courses, include them in current term too
            for course in UC 
                for req in course.requisites
                    if req[1] == c.id  
                        if req[2] == strict_co  
                            deleteat!(UC, findfirst(isequal(course), UC))
                            append!(term_courses, [course])
                            term_credits = term_credits + course.credit_hours
                        end
                    end
                end
            end
        else  # can't find a course to add to current term, create a new term
            length(term_courses) > 0 ? append!(terms, [Term(term_courses)]) : nothing
            term_courses = AbstractCourse[]
            term_credits = 0
        end
    end
    length(term_courses) > 0 ? append!(terms, [Term(term_courses)]) : nothing
    return terms
end

function select_vertex(curric::Curriculum, term_courses::Array{AbstractCourse,1}, UC::Array{AbstractCourse,1})
    for target in UC
        t_id = target.vertex_id[curric.id]
        UCs = deepcopy(UC)
        deleteat!(UCs, findfirst(c->c.id==target.id, UCs))
        invariant1 = true
        for source in UCs
            s_id = source.vertex_id[curric.id]
            vlist = reachable_from(curric.graph, s_id)
            if t_id in vlist  # target cannot be moved to AC
                invariant1 = false  # invariant 1 violated
                break  # try a new target
            end
        end
        if invariant1 == true
            invariant2 = true
            for c in term_courses
                if c.id in collect(keys(target.requisites)) && target.requisites[c.id] == pre  # AND shortcircuits, otherwise 2nd expression would error
                    invariant2 = false
                    break  # try a new target
                end
            end
            if invariant2 == true
                return target
            end
        end
    end
    return nothing
end

function course_num(c::Course)
    c.num != "" ? c.num : c.name
end
