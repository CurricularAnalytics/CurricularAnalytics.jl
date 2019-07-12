using JuMP
using MultiJuMP
using Gurobi
using LinearAlgebra
using LightGraphs

include("CSVUtilities.jl")

# Helper function that provides id in curriculum from course id
function get_vertex(courseID, curric)
    for course in curric.courses
        if course.id == courseID
            return course.vertex_id[curric.id]
        end
    end
    return 0
end

function term_count_obj(m, mask, x, c_count, multi=true)
    terms = [sum(dot(x[k,:],mask)) for k = 1:c_count]
    if multi
        exp = @expression(m, sum(terms[:]))
        obj = SingleObjective(exp, sense = :Min)
        return obj
    else
        @objective(m, Min, sum(terms[:]))
        return true
    end  
end

function balance_obj(m, max_credits_per_term,termCount,x,y,credit, multi=true)
    total_credit_term = [sum(dot(credit,x[:,j])) for j=1:termCount]
    @constraints m begin
        abs_val[i=2:termCount], y[i] >= total_credit_term[i]-total_credit_term[i-1]
        abs_val2[i=2:termCount], y[i] >= -(total_credit_term[i]-total_credit_term[i-1])
    end
    if multi
        exp = @expression(m, sum(y[:]))
        obj = SingleObjective(exp, sense = :Min)
        return obj
    else
        @objective(m, Min, sum(y[:]))
        return true
    end
end

function toxicity_obj(toxic_score_file, m, c_count, courses, termCount,x,ts, curric_id, multi=true)
    toxicFile = readfile(toxic_score_file)
    comboDict = Dict()
    for coursePair in toxicFile[2:end] 
        coursePair = split(coursePair, ",")
        comboDict[replace(coursePair[1], " "=> "")*"_"*replace(coursePair[2], " "=> "")] = parse(Float64,coursePair[9])+1
    end
    toxicity_scores = zeros((c_count, c_count))
    for course in courses
        for innerCourse in courses
            if course != innerCourse 
                if course.prefix*course.num*"_"*innerCourse.prefix*innerCourse.num in keys(comboDict)
                    toxicity_scores[course.vertex_id[curric_id],innerCourse.vertex_id[curric_id]] = comboDict[course.prefix*course.num*"_"*innerCourse.prefix*innerCourse.num]
                end
            end
        end
    end
    for j=1:termCount
        push!(ts, sum((toxicity_scores .* x[:,j]) .* x[:,j]'))
    end
    if multi
        exp = @expression(m, sum(ts[:]))
        obj = SingleObjective(exp, sense = :Min)
        return obj
    else
        @objective(m, Min, sum(ts[:]))
        return true
    end

end

function prereq_obj(m, mask, x, graph, total_distance,  multi=true)
    for edge in collect(edges(graph))
        push!(total_distance, sum(dot(x[dst(edge),:],mask)) - sum(dot(x[src(edge),:],mask)))
    end
    if multi
        exp = @expression(m, sum(total_distance[:]))
        obj = SingleObjective(exp, sense = :Min)
        return obj
    else
        @objective(m, Min, sum(total_distance[:]))
        return true
    end
end

function optimize_plan(config_file, curric_file, toxic_score_file= "")
    
    consequtiveCourses, fixedCourses, termRange, termCount, min_credits_per_term, max_credits_per_term,
        obj_order, diff_max_credits_per_term = read_Opt_Config(config_file)
    
    input = read_csv(curric_file)
    curric = []
    courses = []
    if isa(input, Tuple)
        curric = input[4]
        courses = input[3]
    else
        curric = input
        courses = curric.courses
    end

    m = Model(solver = GurobiSolver())
    multi = length(obj_order) > 1
    if multi
        m = multi_model(solver = GurobiSolver(), linear = true);
    end
    println("Number of courses in curriculum: "*string(length(courses)))
    println("Total credit hours: "*string(total_credits(curric)))
    
    c_count = length(curric.courses)
    vertex_map = Dict{Int,Int}(c.id => c.vertex_id[curric.id] for c in courses)
    taken_cour_ids = [c.id for c in input[2]]
    credit = [c.credit_hours for c in curric.courses]
    mask = [i for i in 1:termCount]
    @variable(m, x[1:c_count, 1:termCount], Bin)
    @variable(m, 0 <= y[1:termCount] <= max_credits_per_term)
    ts=[]
    total_distance = []
    for c in courses
        for req in c.requisites
            if !(req[1] in taken_cour_ids)
                if req[2] == pre
                    @constraint(m, sum(dot(x[vertex_map[req[1]],:],mask)) <= (sum(dot(x[c.vertex_id[curric.id],:],mask))-1))
                elseif req[2] == co
                    @constraint(m, sum(dot(x[vertex_map[req[1]],:],mask)) <= (sum(dot(x[c.vertex_id[curric.id],:],mask))))
                elseif req[2] == strict_co
                    @constraint(m, sum(dot(x[vertex_map[req[1]],:],mask)) == (sum(dot(x[c.vertex_id[curric.id],:],mask))))
                else
                    println("req type error")
                end
            end
        end   
    end
    for idx in 1:c_count
        #output must include all courses once
        if idx in values(vertex_map)
            @constraint(m, sum(x[idx,:]) == 1)
        else
            @constraint(m, sum(x[idx,:]) == 0)
        end
    end

    @constraints m begin
        # Each term must include at least the min # of credits and no more than the max # of credits allowed for a term
        term_lower[j=1:termCount], sum(dot(credit,x[:,j])) >= min_credits_per_term
    end
    println(diff_max_credits_per_term)
    if length(diff_max_credits_per_term) > 0
        for j in 1:termCount
            if j in keys(diff_max_credits_per_term)
                @constraint(m, sum(dot(credit,x[:,j])) <= diff_max_credits_per_term[j])
            else
                @constraint(m, sum(dot(credit,x[:,j])) <= max_credits_per_term)
            end
        end

        @constraints m begin
            term_upper[j=1:termCount], sum(dot(credit,x[:,j])) <= diff_max_credits_per_term[j]
        end
    end

    if length(keys(fixedCourses)) > 0
        for courseID in keys(fixedCourses)
            if !(courseID in taken_cour_ids)
                vID = get_vertex(courseID, curric)
                println(vID)
                if vID != 0
                    @constraint(m, x[vID,fixedCourses[courseID]] >= 1)
                else
                    println("Vertex ID cannot be found for course: "* courseName)
                end
            end
        end
    end
    if length(keys(consequtiveCourses)) > 0
        for (first, second) in consequtiveCourses
            vID_first = get_vertex(first, curric)
            vID_second = get_vertex(second, curric)
            if vID_first != 0 && vID_second != 0
                @constraint(m, sum(dot(x[vID_second,:],mask)) - sum(dot(x[vID_first,:],mask)) <= 1)
                @constraint(m, sum(dot(x[vID_second,:],mask)) - sum(dot(x[vID_first,:],mask)) >= 1)
            else
                println("Vertex ID cannot be found for course: "* first * " or " * second)
            end
        end
    end
    if length(keys(termRange)) > 0
        for (courseID,(lowTerm, highTerm)) in termRange
            vID_Course = get_vertex(courseID, curric)
            if vID_Course != 0
                @constraint(m, sum(dot(x[vID_Course,:],mask)) >= lowTerm)
                @constraint(m, sum(dot(x[vID_Course,:],mask)) <= highTerm)
            end
        end
    end
    if multi
        objectives =[]
        for objective in obj_order
            if objective == "Toxicity"
                push!(objectives, toxicity_obj(toxic_score_file, m,c_count, courses ,termCount, x, ts, curric.id, multi))
            end
            if objective == "Balance"
                push!(objectives, balance_obj(m,max_credits_per_term, termCount, x, y, credit, multi))
            end
            if objective == "Prereq"
                push!(objectives, prereq_obj(m, mask, x, curric.graph, total_distance, multi))
            end
        end
        multim = get_multidata(m)
        multim.objectives = objectives
    else
        if obj_order[1] == "Toxicity"
            toxicity_obj(toxic_score_file, m,c_count, courses ,termCount, x,ts, curric.id, multi)
        end
        if obj_order[1] == "Balance"
            balance_obj(m,max_credits_per_term, termCount, x,y, credit, multi)
        end
        if obj_order[1] == "Prereq"
            prereq_obj(m, mask, x, curric.graph, total_distance, multi)
        end
    end
    status = solve(m)
    if status == :Optimal
        output = getvalue(x)
        if "Balance" in obj_order
            println(sum(getvalue(y)))
        end
        if "Toxicity" in obj_order
            println(sum(getvalue(ts)))
        end
        if "Prereq" in obj_order
            println(sum(getvalue(total_distance)))
        end
        #println(ts)
        optimal_terms = Term[]
        if isa(input, Tuple)
            optimal_terms = input[1]
        end
        for j=1:termCount
            if sum(dot(credit,output[:,j])) > 0 
                term = Course[]
                for course_id in keys(vertex_map)
                    if round(output[vertex_map[course_id],j]) == 1
                        for c in courses
                            if c.id == course_id
                                push!(term, c)
                            end
                        end
                    end 
                end
                push!(optimal_terms, Term(term))
            end
        end
        dp = DegreePlan("", curric, optimal_terms)
        if isa(input, Tuple)
            dp = DegreePlan(input[5], curric, optimal_terms, input[6])
        end
        visualize(dp, notebook=true)
    else
        println("not optimal")
    end
end