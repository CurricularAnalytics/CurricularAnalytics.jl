# file: DegreePlanCreation.jl
function create_degree_plan(curric::Curriculum, create_terms::Function=bin_packing, name::AbstractString="", additional_courses::Array{Course}=Array{Course,1}();
    min_terms::Int=1, max_terms::Int=8, min_credits_per_term::Int=3, max_credits_per_term::Int=19)
    terms =  create_terms(curric, additional_courses; min_terms=min_terms, max_terms=max_terms, min_credits_per_term=min_credits_per_term,
                                max_credits_per_term=max_credits_per_term)
    if terms == false
        println("Unable to create degree plan")
        return
    else
        return DegreePlan(name, curric, terms)
    end
end

function check_requistes(curric::Curriculum, index::Int, previous_terms::Array{Int}, current_term::Array{Int})
    req_complete = true
    # find all inneighbors of vertex with index supplied as input
    inngbr = inneighbors(curric.graph, index)
    for ngbr in inngbr
        req_type = curric.courses[index].requisites[curric.courses[ngbr].id]
        if req_type == pre && !(ngbr in previous_terms)
            req_complete = false 
            break      
        elseif req_type == co && !(ngbr in previous_terms) && !(ngbr in current_term)
            req_complete = false 
            break
        end
    end    
    return req_complete
end

function bin_packing(curric::Curriculum, additional_courses::Array{Course}=Array{Course,1}(); 
    min_terms::Int=1, max_terms::Int=1, min_credits_per_term::Int=5, max_credits_per_term::Int=19)
    curric_total_credit=total_credits(curric)
    if !("complexity" in keys(curric.metrics))
        complexity(curric)
    end
    sorted_index = sortperm(curric.metrics["complexity"][2], rev=true)  # returns a permutation vector
    terms = Array{Term}(undef, min_terms)
    all_applied_courses = Int[]
    for current_term in 1:min_terms
        termclasses = Course[]
        this_term_applied_courses = Int[]
        total_credits_for_current_term = 0
        # Find upper limit of average credit for remaining terms to balance the credit hours of terms
        avrg_credit_remaining = floor(Int, (curric_total_credit + min_terms - current_term)/ (min_terms-current_term + 1))
        # Check if upper limit of average credit hours for remaining terms exceeds the maximum credits per term.
        # If it does, there is no way to fit remaining classses in, so try again after increasing the number of terms.
        if avrg_credit_remaining < max_credits_per_term
            # Go through all courses to add in current term according to the complexity score
            for index in sorted_index
                # Ignore if current course was already added to a previous term
                if !(index in all_applied_courses) && !(index in this_term_applied_courses)
                    # Make sure requisites are satisfied
                    can_be_added = true
                    if check_requistes(curric, index, all_applied_courses, this_term_applied_courses)
                        credit_add = curric.courses[index].credit_hours
                        courses_to_add = [index]
                        outnbr = outneighbors(curric.graph, index)
                        for ngbr in outnbr
                            req_type = curric.courses[ngbr].requisites[curric.courses[index].id]
                            if req_type == strict_co
                                can_be_added = check_requistes(curric, ngbr, all_applied_courses, this_term_applied_courses)
                                if !can_be_added
                                    break
                                end
                                credit_add +=  curric.courses[ngbr].credit_hours
                                push!(courses_to_add, ngbr)
                            end
                        end
                        # Add current course if it does not overflow the bin 
                        if can_be_added && total_credits_for_current_term + credit_add <= avrg_credit_remaining
                            total_credits_for_current_term += credit_add
                            for course_index in courses_to_add
                                push!(termclasses, curric.courses[course_index])
                                # Track indicies of current term's courses
                                push!(this_term_applied_courses, course_index)
                            end
                        end
                        # Any credit remaining?
                        if total_credits_for_current_term == avrg_credit_remaining
                            break
                        end
                    end
                end       
            end    
            # Substract credits of added courses
            curric_total_credit = curric_total_credit - total_credits_for_current_term
            # Create term
            terms[current_term] = Term(termclasses)
            # Before starting a new term, add all indices of the current term's classes
            for course_in_term in this_term_applied_courses
                push!(all_applied_courses, course_in_term) 
            end
        end
    end
    if length(all_applied_courses) != length(sorted_index)
        if min_terms < max_terms
            # The following print statement can be uncommented for debugging purposes
            # println("Unable to create a $min_terms term plan, attempting a $(min_terms+1) term plan")
            return bin_packing(curric, additional_courses; min_terms=min_terms+1, max_terms=max_terms, min_credits_per_term=min_credits_per_term,
             max_credits_per_term=max_credits_per_term)
        else 
            return false  # No solution, the degree plans requires more terms than max_terms
        end
    end
    return terms
end

function create_terms(curric::Curriculum; term_count::Int, min_credits_per_term::Int=5, max_credits_per_term::Int=19)
    if !("complexity" in keys(curric.metrics))
        complexity(curric)
    end
    sorted_index = sortperm(curric.metrics["complexity"][2], rev=true)
    terms = Array{Term}(undef, term_count)
    curric_total_credit=total_credits(curric)
    added_credits = 0
    all_applied_courses = Int[]
    for current_term in 1:term_count
        termclasses = Course[]
        this_term_applied_courses = Int[]
        total_credits_for_current_term = 0
        #  Can remaining credits be added to the remaining terms?
        if (curric_total_credit - added_credits) <= ((term_count - current_term+1) * max_credits_per_term)
            for index in sorted_index
                if !(index in all_applied_courses) && !(index in this_term_applied_courses)
                    can_be_added = true
                    if check_requistes(curric, index, all_applied_courses, this_term_applied_courses)
                        credit_add = curric.courses[index].credit_hours
                        courses_to_add = [index] 
                        for ngbr in outneighbors(curric.graph, index)
                            req_type = curric.courses[ngbr].requisites[curric.courses[index].id]
                            if req_type == strict_co
                                can_be_added = check_requistes(curric, ngbr, all_applied_courses, this_term_applied_courses)
                                if !can_be_added
                                    break
                                end
                                credit_add +=  curric.courses[ngbr].credit_hours
                                push!(courses_to_add,ngbr)
                            end
                        end
                        if can_be_added && total_credits_for_current_term + credit_add <= max_credits_per_term
                            total_credits_for_current_term += credit_add
                            for course_index in courses_to_add
                                push!(termclasses, curric.courses[course_index])
                                push!(this_term_applied_courses,course_index)
                            end
                        end
                        #Check if current term is full
                        if total_credits_for_current_term == max_credits_per_term
                            #There is no more space for any other course
                            break
                        end
                    end
                end       
            end    
            added_credits += total_credits_for_current_term
            terms[current_term] = Term(termclasses)
            for course in this_term_applied_courses
                push!(all_applied_courses, course) 
            end
        else
            return nothing, false
        end
    end
    if length(all_applied_courses) == length(sorted_index)
        return terms, true
    else
        return nothing, false
    end    
end

#"""
#find_min_terms function will find the minimum number terms possible to fit all courses with the respect that all requisite
#    conditions and returns a tuple which contains 3 elements.
#    1- Boolean value which shows if term list created for term count.
#    2- Term list which contains all courses for related term id.
#    3- The term_count is a integer value to show minimum number of terms possible to fit all courses.
#    * Altough this function returns term list, it does not guarantee that each term will have the same number of credit hours.
#    It will put all courses as early term as possible according to the complexity score.
#"""
function find_min_terms(curric::Curriculum, additional_courses::Array{Course}=Array{Course,1}(); 
    min_terms::Int=1, max_terms::Int=10, min_credits_per_term::Int=5, max_credits_per_term::Int=19)
    for term_count in range(min_terms, stop=max_terms)
        terms, control = create_terms(curric; term_count=term_count, min_credits_per_term = min_credits_per_term,
            max_credits_per_term = max_credits_per_term)
        if control
            return true, terms, term_count
        end
    end
    return false, nothing, nothing
end

#"""
#balance_terms function will spread all courses to the provided number of terms with minimum number of difference between terms.
#    In other words, balance terms according to the number of credit hours and returns a tuple which contains 3 elements.
#    1- Boolean value which shows if term list created for term count.
#    2- Term list which contains all courses for related term id.
#    3- The max_credit is a integer value to show maximum number of credit hours assigned to any of the list of terms.
#"""
function balance_terms(curric::Curriculum, additional_courses::Array{Course}=Array{Course,1}(); 
    term_count::Int=1, min_credits_per_term::Int=1, max_credits_per_term::Int=19)
    for max_credit in range(min_credits_per_term, length=max_credits_per_term-min_credits_per_term+1)
        terms, control = create_terms(curric; term_count=term_count,  min_credits_per_term = min_credits_per_term,
            max_credits_per_term = max_credit)
        if control
            return true, terms, max_credit
        end
    end
    return false, nothing, nothing
end

function bin_packing2(curric::Curriculum, additional_courses::Array{Course}=Array{Course,1}(); 
        min_terms::Int=1, max_terms::Int=8, min_credits_per_term::Int=3, max_credits_per_term::Int=19)
    control, terms, min_term_count = find_min_terms(curric, additional_courses; min_terms = min_terms,max_terms = max_terms, min_credits_per_term = min_credits_per_term, max_credits_per_term = max_credits_per_term)
    if control
        control_balance, terms, max_credit = balance_terms(curric, additional_courses;
            term_count=min_term_count, min_credits_per_term = min_credits_per_term, max_credits_per_term=max_credits_per_term)
        if control_balance
            return terms
        end
    end
    return false
end

