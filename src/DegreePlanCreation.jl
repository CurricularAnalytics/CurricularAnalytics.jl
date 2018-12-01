
# file: DegreePlanCreation.jl

function create_degree_plan(curric::Curriculum, create_terms::Function, additional_courses::Array{Course}=Array{Course,1}();
    min_terms::Int=0, max_terms::Int=0, min_credits_per_term::Int=0, max_credits_per_term::Int=0, total_terms::Int=0)

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
        elseif req_type == co || req_type == strict_co
            if !(ngbr in previous_terms)
                if !(ngbr in current_term)
                    req_complete = false 
                    break
                end
            end
        end
    end
    return req_complete
end

function create_terms(curric::Curriculum, term_count::Int, max_credit_each_term::Int)
    #total number of credits
    curric_total_credit=total_credits(curric)
    #Even though the max credit is set, the algorithim will fill in free courses that optimally fill the term, up to the maximum 
    #credits desired by the student or allowed by the university 
    #round to average credit per term
    #make a function to calculate extra(2 in this case)
    #calculate average creadit after each term
    sorted_index = sortperm(curric.metrics["complexity"][2], rev=true)
    terms = Array{Term}(undef, term_count)
    all_applied_courses = Int[]
    for current_term in 1:term_count
        termclasses = Course[]
        this_term_applied_courses = Int[]
        total_credits_for_current_term = 0
        #Find upper limit of average credit for remaining terms to balance the credit hours of terms
        avrg_credit_remaining = floor(Int, (curric_total_credit + term_count - current_term)/ (term_count-current_term + 1)) 
        #check if upper limit of average credit hours for remaining terms exceeds the maximum credit 
        #If exceed, there is no possible way of fitting remaining classses.
        #Therefor, try againg after increasing term count
        if avrg_credit_remaining  < max_credit_each_term
            #go through all courses to add in current term according to the complexity score
            for index in sorted_index
                #if current course is already added to the previous terms ignore
                if !(index in all_applied_courses)
                    #Control reqs 
                    if check_requistes(curric, index, all_applied_courses, this_term_applied_courses)
                        #add current course if we still have enough credit 
                        if total_credits_for_current_term + curric.courses[index].credit_hours <= avrg_credit_remaining
                            total_credits_for_current_term += curric.courses[index].credit_hours
                            push!(termclasses, curric.courses[index])
                            #also keep indexes of this term's classes
                            push!(this_term_applied_courses,index)
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
        println("Could not create a plan for $term_count term, try for one more term")
        return create_terms(curric, term_count+1, max_credit_each_term)
    end
    return terms
end
