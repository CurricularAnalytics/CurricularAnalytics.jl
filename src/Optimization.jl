using MultiJuMP, JuMP
using Gurobi
using LinearAlgebra
using LightGraphs

include("CSVUtilities.jl")

# Helper function that uses the course ID to find the vertex id of taht course in a curriculum graph.
function get_vertex(courseID, curric)
    for course in curric.courses
        if course.id == courseID
            return course.vertex_id[curric.id]
        end
    end
    return 0
end

# Objective function for creating a degree plan with a minimal number of terms
function term_count_obj(model, mask, x, c_count, multi=true)
    terms = [sum(dot(x[k,:], mask)) for k = 1:c_count]
    if multi
        exp = @expression(model, sum(terms[:]))
        obj = SingleObjective(exp, sense = :Min)
        return obj
    else
        @objective(model, Min, sum(terms[:]))
        return true
    end
end

# Objective function for balancing credit hours as evenly as possible across a degree plan
function balance_obj(model, max_cpt, term_count, x, y, credit, multi=true)
    total_credit_term = [sum(dot(credit,x[:,j])) for j=1:term_count]
    # Work around for computing absoluate value: when y was declared as a variable, it was constratined to be >= 0, so only 
    # one of these two constaints will be "active," i.e, the one that is >= 0.
    @constraints model begin
        diff1[i=1:term_count, j=1:term_count], y[i,j] >= total_credit_term[i] - total_credit_term[j]
        diff2[i=1:term_count, j=1:term_count], y[i,j] >= -(total_credit_term[i] - total_credit_term[j])
    end
    if multi
        exp = @expression(model, sum(y))
        obj = SingleObjective(exp, sense = :Min)
        return obj
    else
        @objective(model, Min, sum(y))
        return true
    end
end

# Objective function for minimizing toxic course combinations in a degree plan
function toxicity_obj(toxic_score_file, model, c_count, courses, term_count, x, ts, curric_id, multi=true)
    toxicFile = readfile(toxic_score_file)
    comboDict = Dict()
    for coursePair in toxicFile[2:end] 
        coursePair = split(coursePair, ",")
        comboDict[replace(coursePair[1], " " => "") * "_" * replace(coursePair[2], " " => "")] = parse(Float64,coursePair[9]) + 1
    end
    toxicity_scores = zeros((c_count, c_count))
    for course in courses
        for innerCourse in courses
            if course != innerCourse 
                if course.prefix * course.num * "_" * innerCourse.prefix * innerCourse.num in keys(comboDict)
                    toxicity_scores[course.vertex_id[curric_id], innerCourse.vertex_id[curric_id]] = comboDict[course.prefix * course.num * "_" * innerCourse.prefix * innerCourse.num]
                end
            end
        end
    end
    for j=1:term_count
        push!(ts, sum((toxicity_scores .* x[:,j]) .* x[:,j]'))
    end
    if multi
        exp = @expression(model, sum(ts[:]))
        obj = SingleObjective(exp, sense = :Min)
        return obj
    else
        @objective(model, Min, sum(ts[:]))
        return true
    end
end

# Objective function for minimizing the number of terms between pre- and post-requisites in a degree plan (i.e., keep prerequisites
# as close as possible to the follow-on courses that require them.)
function req_distance_obj(model, mask, x, graph, distance,  multi=true)
    for edge in edges(graph)
        push!(distance, sum(dot(x[dst(edge),:], mask)) - sum(dot(x[src(edge),:], mask)))
    end
    if multi == true  # Multi-objective optimization
        exp = @expression(model, sum(distance[:]))
        obj = SingleObjective(exp, sense = :Min)
        return obj
    else 
        @objective(model, Min, sum(distance[:]))
        return true
    end
end

# Should be able to pass the curriculum as an object. Currently can only be passed as a file. 
# Configuration options should be passable via args, not just as a file.
function optimize_plan(config_file, curric_degree_file, toxic_score_file= "")
    # read parameters from the configuration file
    consec_courses, fix_courses, term_range, term_count, min_cpt, max_cpt,
        obj_order, diff_max_cpt = read_Opt_Config(config_file)
    println("done")
    input = read_csv(curric_degree_file)
    curric = []
    courses = []
    if isa(input, Tuple)  # Input is a degree plan
        curric = input[4]
        courses = input[3]
    else # Input is a curriculum
        curric = input
        courses = curric.courses
    end
    model = Model(solver = GurobiSolver())
    multi = length(obj_order) > 1
    if multi
        model = multi_model(solver = GurobiSolver(), linear = true)
    end
    
    c_count = length(curric.courses)
    # Create a map from course ID in curriculum to vertex ID of course in the curriculum graph.
    vertex_map = Dict{Int,Int}(c.id => c.vertex_id[curric.id] for c in courses)
    taken_course_ids = []
    if isa(input, Tuple)
        taken_course_ids = [c.id for c in input[2]]
    end
    credit = [c.credit_hours for c in curric.courses]
    # The mask vector is used to determine the term that a course is in, via dot product with a row of the x matrix
    mask = [i for i in 1:term_count]
    # Bin specifes binary optimzation variables in JuMP.
    @variable(model, x[1:c_count, 1:term_count], Bin) # Assignment variables: course-to-term assignment
    @variable(model, y[1:term_count, 1:term_count] >= 0) # Variables used for balanced curriculum objective function.
    ts=[]
    distance = []
    for c in courses
        for req in c.requisites
            if !(req[1] in taken_course_ids)
                if req[2] == pre
                    @constraint(model, dot(x[vertex_map[req[1]],:], mask) <= sum(dot(x[c.vertex_id[curric.id],:], mask))-1) # Constraints cannot use "<", so need to subtract 1 for pre
                elseif req[2] == co
                    @constraint(model, dot(x[vertex_map[req[1]],:], mask) <= sum(dot(x[c.vertex_id[curric.id],:], mask)))
                elseif req[2] == strict_co
                    @constraint(model, dot(x[vertex_map[req[1]],:], mask) == sum(dot(x[c.vertex_id[curric.id],:], mask)))
                else
                    println("requisite type error")
                end
            end
        end   
    end

    # Degree plan must include all courses once.
    for i in 1:c_count
        if i in values(vertex_map)
            @constraint(model, sum(x[i,:]) == 1)
        else
            @constraint(model, sum(x[i,:]) == 0)
        end
    end

    # Each term must include at least the min # of credits and no more than the max # of credits allowed for a term
    @constraints model begin
        term_lower[j=1:term_count], sum(dot(credit,x[:,j])) >= min_cpt
    end

    # Each term must have no more than the max number of credits defined via the configuration config_file
    for j in 1:term_count
        if j in keys(diff_max_cpt)
            @constraint(model, sum(dot(credit,x[:,j])) <= diff_max_cpt[j])
        else  # Use this if a different amount was not specified for a given term
            @constraint(model, sum(dot(credit, x[:,j])) <= max_cpt)
        end
    end

    # Fixed courses must appear in their assigned terms
    if length(keys(fix_courses)) > 0
        for courseID in keys(fix_courses)
            if !(courseID in taken_course_ids)
                vID = get_vertex(courseID, curric)
                if vID != 0
                    @constraint(model, x[vID,fix_courses[courseID]] == 1)  # GLH: changed from >= to == 
                else
                    println("Vertex ID cannot be found for course: $courseName")
                end
            end
        end
    end

    # Courses specified as consecutive must appear in consecutive terms 
    if length(keys(consec_courses)) > 0
        for (first, second) in consec_courses
            vID_first = get_vertex(first, curric)
            vID_second = get_vertex(second, curric)
            if vID_first != 0 && vID_second != 0
                @constraint(model, sum(dot(x[vID_second,:], mask)) - sum(dot(x[vID_first,:], mask)) == 1)
            else
                println("Vertex ID cannot be found for either course $first or $second")
            end
        end
    end

    # Courses specified to appear in a range must appear in that term range 
    if length(keys(term_range)) > 0
        for (courseID,(lowTerm, highTerm)) in term_range
            vID_Course = get_vertex(courseID, curric)
            if vID_Course != 0
                @constraint(model, sum(dot(x[vID_Course,:], mask)) >= lowTerm)
                @constraint(model, sum(dot(x[vID_Course,:], mask)) <= highTerm)
            end
        end
    end

    if multi == true
        objectives = []
        for objective in obj_order
            if objective == "Toxicity"
                push!(objectives, toxicity_obj(toxic_score_file, model,c_count, courses ,term_count, x, ts, curric.id, multi))
            end
            if objective == "Balance"
                push!(objectives, balance_obj(model,max_cpt, term_count, x, y, credit, multi))
            end
            if objective == "Prereq"
                push!(objectives, req_distance_obj(model, mask, x, curric.graph, distance, multi))
            end
        end
        multim = get_multidata(model)
        multim.objectives = objectives
    else
        if obj_order[1] == "Toxicity"
            toxicity_obj(toxic_score_file, model, c_count, courses, term_count, x, ts, curric.id, multi)
        end
        if obj_order[1] == "Balance"
            balance_obj(model, max_cpt, term_count, x, y, credit, multi)
        end
        if obj_order[1] == "Prereq"
            req_distance_obj(model, mask, x, curric.graph, distance, multi)
        end
    end
    status = solve(model)
    if status == :Optimal
        output = getvalue(x)
        if "Balance" in obj_order
            println(sum(getvalue(y)))
        end
        if "Toxicity" in obj_order
            println(sum(getvalue(ts)))
        end
        if "Prereq" in obj_order
            println(sum(getvalue(distance)))
        end
        optimal_terms = Term[]
        # Add the courses that have already been taken to the degree plan. 
        if isa(input, Tuple)  # Input is a degree plan, with courses already taken specified in first terms.
            optimal_terms = input[1]
        end
        # Fill in the remaining terms as determined by the optimization algorithm.
        for j=1:term_count
            if sum(dot(credit, output[:,j])) > 0 
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
        return dp
    else
        println("not optimal")
        return false
    end
end