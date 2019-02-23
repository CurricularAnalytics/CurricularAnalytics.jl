using JuMP
using LinearAlgebra
using Gurobi
function find_min_terms_opt(curric::Curriculum, additional_courses::Array{Course}=Array{Course,1}(); 
    min_terms::Int=1, max_terms::Int, max_credits_per_term::Int)
    m = Model(solver=GurobiSolver())
    courses = curric.courses
    credit = [c.credit_hours for c in curric.courses]
    c_count = length(courses)
    mask = [i for i in 1:max_terms]
    @variable(m, x[1:c_count, 1:max_terms], Bin)
    terms = [sum(dot(x[k,:],mask)) for k = 1:c_count]
    vertex_map = Dict{Int,Int}(c.id => c.vertex_id[curric.id] for c in curric.courses)
    @constraints m begin
        #output must include all courses once
        tot[i=1:c_count], sum(x[i,:]) == 1
        #Each term must include more or equal than min credit and less or equal than max credit allowed for a term
        term[j=1:max_terms], sum(dot(credit,x[:,j])) <= max_credits_per_term
    end
    for c in courses
        for req in c.requisites
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
    @objective(m, Min, sum(terms[:]))
    status = solve(m)
    output = getvalue(x)
    optimal_terms = Term[]
    for j=1:max_terms
        if sum(dot(credit,output[:,j])) > 0 
            term = Course[]
            for course in 1:length(courses)
                if round(output[course,j]) == 1
                    push!(term, courses[course])
                end 
            end
            push!(optimal_terms, Term(term))
        end
    end
    if status == :Optimal
        return true, optimal_terms, length(optimal_terms)
    end
    return false, nothing, nothing
end
function balance_terms_opt(curric::Curriculum, additional_courses::Array{Course}=Array{Course,1}();       
    min_terms::Int=1, max_terms::Int,min_credits_per_term::Int=1, max_credits_per_term::Int)
    m = Model(solver=GurobiSolver())
    courses = curric.courses
    credit = [c.credit_hours for c in curric.courses]
    c_count = length(courses)
    mask = [i for i in 1:max_terms]
    @variable(m, x[1:c_count, 1:max_terms], Bin)
    terms = [sum(dot(x[k,:],mask)) for k = 1:c_count]
    vertex_map = Dict{Int,Int}(c.id => c.vertex_id[curric.id] for c in curric.courses)
    total_credit_term = [sum(dot(credit,x[:,j])) for j=1:max_terms]
    @variable(m, 0 <= y[1:max_terms] <= max_credits_per_term)
    @constraints m begin
        #output must include all courses once
        tot[i=1:c_count], sum(x[i,:]) == 1
        #Each term must include more or equal than min credit and less or equal than max credit allowed for a term
        term[j=1:max_terms], sum(dot(credit,x[:,j])) <= max_credits_per_term
        term[j=1:max_terms], sum(dot(credit,x[:,j])) >= min_credits_per_term
        abs_val[i=2:max_terms], y[i] >= total_credit_term[i]-total_credit_term[i-1]
        abs_val2[i=2:max_terms], y[i] >= -(total_credit_term[i]-total_credit_term[i-1])
    end
    for c in courses
        for req in c.requisites
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
    @objective(m, Min, sum(y[:]))
    status = solve(m)
    output = getvalue(x)
    optimal_terms = Term[]
    for j=1:max_terms
        if sum(dot(credit,output[:,j])) > 0 
            term = Course[]
            for course in 1:length(courses)
                if round(output[course,j]) == 1
                    push!(term, courses[course])
                end 
            end
            push!(optimal_terms, Term(term))
        end
    end
    if status == :Optimal
        return true, optimal_terms, length(optimal_terms)
    end
    return false, nothing, nothing
end

