# file: DegreePlanCreation.jl
 
function create_degree_plan(curric::Curriculum, name::AbstractString="", create_terms::Function=bin_packing, additional_courses::Array{Course}=Array{Course,1}();
    min_terms::Int=1, max_terms::Int=1, min_credits_per_term::Int=5, max_credits_per_term::Int=19)
    terms =  create_terms(curric,additional_courses; min_terms=min_terms,max_terms=max_terms, min_credits_per_term=min_credits_per_term,
                                max_credits_per_term=max_credits_per_term)
    DegreePlan(name, curric, terms)
end

function check_requistes(curric::Curriculum, index::Int, previous_terms::Array{Int}, current_term::Array{Int})
    req_complete = true
    #find all inneighbors of current node
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
    #println("min_terms $min_terms max $max_terms min_credits_per_term $min_credits_per_term")
    #println("max_credits_per_term $max_credits_per_term $total_terms")
    #total number of credits
    curric_total_credit=total_credits(curric)
    #Even though the max credit is set, the algorithim will fill in free courses that optimally fill the term, up to the maximum 
    #credits desired by the student or allowed by the university 
    #round to average credit per term
    #make a function to calculate extra(2 in this case)
    #calculate average creadit after each term
    if !("complexity" in keys(curric.metrics))
        complexity(curric)
    end
    sorted_index = sortperm(curric.metrics["complexity"][2], rev=true)
    terms = Array{Term}(undef, min_terms)
    all_applied_courses = Int[]
    for current_term in 1:min_terms
        termclasses = Course[]
        this_term_applied_courses = Int[]
        total_credits_for_current_term = 0
        #Find upper limit of average credit for remaining terms to balance the credit hours of terms
        avrg_credit_remaining = floor(Int, (curric_total_credit + min_terms - current_term)/ (min_terms-current_term + 1))
        #println("avrg_credit_remaining $avrg_credit_remaining")
        #println("$curric_total_credit $avrg_credit_remaining")
        #check if upper limit of average credit hours for remaining terms exceeds the maximum credit 
        #If exceed, there is no possible way of fitting remaining classses.
        #Therefor, try againg after increasing term count
        if avrg_credit_remaining  < max_credits_per_term
            #go through all courses to add in current term according to the complexity score
            for index in sorted_index
                
                #if current course is already added to the previous terms ignore
                if !(index in all_applied_courses)
                    #find vertex and send vertex id
                    #Control reqs 
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
                                push!(courses_to_add,ngbr)
                            end
                        end
                        #add current course if we still have enough credit 
                        if can_be_added && total_credits_for_current_term + credit_add <= avrg_credit_remaining
                            total_credits_for_current_term += credit_add
                            for course_index in courses_to_add
                                push!(termclasses, curric.courses[course_index])
                                #also keep indexes of this term's classes
                                push!(this_term_applied_courses,course_index)
                            end
                        end
                        #control if there is any credit to add other course
                        if total_credits_for_current_term == avrg_credit_remaining
                            break
                        end
                    end
                end       
            end    
            #Substract credits of added courses
            curric_total_credit = curric_total_credit - total_credits_for_current_term
            #Create term
            terms[current_term] = Term(termclasses)
            #Before starting to a new term, add all indexes of this term's classes
            for course_in_term in this_term_applied_courses
                push!(all_applied_courses, course_in_term) 
            end
        end
    end
    if length(all_applied_courses) != length(sorted_index)
        if min_terms<max_terms
            println("Could not create a plan for $min_terms term, tring for $(min_terms+1) term")
            return bin_packing(curric,additional_courses; min_terms=min_terms+1,max_terms=max_terms, min_credits_per_term=min_credits_per_term,
        max_credits_per_term=max_credits_per_term)
        else 
            throw("Could not visualize for given information")
        end
    end
    return terms
end