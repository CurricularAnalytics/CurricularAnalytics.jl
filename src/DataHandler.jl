using JSON
using CSV
using DataFrames

# Returns a requisite as a string for visualization
function requisite_to_string(req::Requisite)
    if req == pre
        return "prereq"
    elseif req == co
        return "coreq"
    else
        return "strict-coreq"
    end
end

# Returns a requisite (enumerated type) from a string
function string_to_requisite(req::String)
    if req == "CurriculumPrerequisite"
        return pre
    elseif req == "CurriculumCorequisite"
        return co
    else
        return strict_co
    end
end

function prepare_data(degree_curric::DegreePlan; edit::Bool=false, hide_header::Bool=false, show_delay::Bool=true, 
                        show_blocking::Bool=true, show_centrality::Bool=true, show_complexity::Bool=true)
    dp_dict = Dict{String,Any}()
    dp_dict["options"] = Dict{String, Any}()
    dp_dict["options"]["edit"] = edit
    dp_dict["options"]["hideTerms"] = hide_header
    dp_dict["curriculum"] = Dict{String, Any}()
    dp_dict["curriculum"]["dp_name"] = degree_curric.name
    dp_dict["curriculum"]["name"] = degree_curric.curriculum.name
    dp_dict["curriculum"]["institution"] = degree_curric.curriculum.institution
    dp_dict["curriculum"]["curriculum_terms"] = Dict{String, Any}[]
    for i = 1:degree_curric.num_terms
        current_term = Dict{String, Any}()
        current_term["id"] = i
        current_term["name"] = "Term $i"
        current_term["curriculum_items"] = Dict{String, Any}[]
        for course in degree_curric.terms[i].courses
            current_course = Dict{String, Any}()
            current_course["id"] = course.id
            current_course["nameSub"] = course.name
            current_course["name"] =  course.prefix * " " * course.num
            current_course["credits"] = course.credit_hours
            current_course["curriculum_requisites"] = Dict{String, Any}[]
            if !show_complexity
                delete!(course.metrics, "complexity")
            end
            if !show_centrality
                delete!(course.metrics, "centrality")
            end
            if !show_delay
                delete!(course.metrics, "delay factor")
            end
            if !show_blocking
                delete!(course.metrics, "blocking factor")
            end
            current_course["metrics"] = course.metrics
            current_course["nameCanonical"] = course.canonical_name
            for req in collect(keys(course.requisites))
                current_req = Dict{String, Any}()
                current_req["source_id"] = req
                current_req["target_id"] = course.id
                # Parse the Julia requisite type to the required type for the visualization
                current_req["type"] = requisite_to_string(course.requisites[req])
                push!(current_course["curriculum_requisites"], current_req)
            end
            push!(current_term["curriculum_items"], current_course)
        end
        push!(dp_dict["curriculum"]["curriculum_terms"], current_term)
    end
    return dp_dict
end

function json_to_julia(json_tuple::NamedTuple)
    # Create an array "terms" with elements equal to the number of terms from the file
    num_terms = length(json_tuple.curriculum_terms)
    terms = Array{Term}(undef, num_terms)
    all_courses = Array{Course}(undef, 0)
    courses_dict = Dict{Int, Course}()
    # For every term
    for i = 1:num_terms
        # Grab the current term
        current_term = json_tuple[:curriculum_terms][i]
        # Create an array of course objects for the current term
        courses = Array{Course}(undef, 0)
        # For each course in the current term
        for course in current_term[:curriculum_items]
            # Check if nameSub is defined on the current course
            if(:nameSub in keys(json_tuple.curriculum_terms[2][:curriculum_items][1]))
                # If it is, use nameSub as the course name when constructing the course object
                current_course = Course(course[:nameSub], course[:credits])
            else
                # Otherwise, just use the normal course :name
                current_course = Course(course[:name], course[:credits])
            end
            # Push each Course object to the array of courses
            push!(courses, current_course)
            push!(all_courses, current_course)
            courses_dict[course.id] = current_course
        end

        # For each course object create its requisites
        for course in current_term[:curriculum_items]
            # If the course has requisites
            if !isempty(course[:curriculum_requisites])
                # For each requisite of the course
                for req in course[:curriculum_requisites]
                    # Create the requisite relationship
                    source = courses_dict[req[:source_id]]
                    target = courses_dict[req[:target_id]]
                    add_requisite!(source, target, string_to_requisite(req[:type]))
                end
            end
        end
        # Set the current term to be a Term object
        terms[i] = Term(courses)
    end
    curric = Curriculum("Underwater Basket Weaving", all_courses)
    degreeplan = DegreePlan("My Plan", curric, terms)
    return degreeplan
end

function julia_to_json(degreeplan::DegreePlan)
    json_dp = Dict{String, Any}()
    json_dp["curriculum"] = Dict{String, Any}()
    json_dp["curriculum"]["name"] = degreeplan.name
    json_dp["curriculum"]["curriculum_terms"] = Dict{String, Any}[]
    for i = 1:degreeplan.num_terms
        current_term = Dict{String, Any}()
        current_term["id"] = i
        current_term["name"] = "Term $i"
        current_term["curriculum_items"] = Dict{String, Any}[]
        for course in degreeplan.terms[i].courses
            current_course = Dict{String, Any}()
            current_course["id"] = course.id
            current_course["name"] = course.name
            # current_course["nameSub"] = course.name
            # current_course["name"] =  course.prefix * " " * course.num
            # current_course["prefix"] =  course.prefix
            # current_course["num"] = course.num
            current_course["credits"] = course.credit_hours
            current_course["curriculum_requisites"] = Dict{String, Any}[]
            current_course["metrics"] = course.metrics
            for req in collect(keys(course.requisites))
                current_req = Dict{String, Any}()
                current_req["source_id"] = req
                current_req["target_id"] = course.id
                # Parse the Julia requisite type to the required type for the visualization
                current_req["type"] = requisite_to_string(course.requisites[req])
                push!(current_course["curriculum_requisites"], current_req)
            end
            push!(current_term["curriculum_items"], current_course)
        end
        push!(json_dp["curriculum"]["curriculum_terms"], current_term)
    end
    return json_dp
end

function update_curric(original_curric::DegreePlan, edited_curric::Dict{String,Any}, file_path::AbstractString)
    dict_requisite = Dict("prereq"=>pre, "coreq"=>co, "strict-coreq"=>strict_co)
    # Requisites might be updated by interface
    # Get all original courses without any requisite
    original_curriculum = original_curric.curriculum
    is_dp = original_curric.name != "" || isdefined(original_curric, :additional_courses) 
    original_courses = Dict{Int,Course}()
    new_courses_IDs = Dict{String,Int}()
    new_courses =  Dict{Int,Course}()
    for term in original_curric.terms
        for course in term.courses
            course.requisites = Dict{Int, Requisite}()
            original_courses[course.id] = course
        end
    end    
    num_terms = length(edited_curric["curriculum_terms"])
    terms = Array{Term}(undef, num_terms)
    all_courses = Array{Course}(undef, 0)
    courses_dict = Dict{Int, Course}()
    for i = 1:num_terms
        # grab the current term
        current_term = edited_curric["curriculum_terms"][i]
        # create an array of course objects with length equal to the number of courses
        courses = Array{Course}(undef, 0)    
        # for each course in the current term
        for course in current_term["curriculum_items"]    
            # create Course object for each course in the current term
            current_course = ""        
            if typeof(course["id"]) == String && !(course["id"] in keys(new_courses_IDs))
                c_credit = typeof(course["credits"]) == String ? parse(Int,course["credits"]) : course["credits"]
                current_course = Course(course["nameSub"], c_credit, prefix=split(course["name"], " ")[1], num = split(course["name"], " ")[end])
                new_courses_IDs[course["id"]] = current_course.id
                new_courses[current_course.id] = current_course    
            else
                course_id = course["id"]
                if typeof(course_id) == String
                    course_id = new_courses_IDs[course_id]
                end
                current_course = original_courses[course_id]
                current_course.name=course["nameSub"]
                current_course.credit_hours=typeof(course["credits"]) == String ? parse(Int,course["credits"]) : course["credits"] 
                # get course remove all reqs
            end
            # push each Course object to the array of courses
            push!(courses, current_course)
            push!(all_courses, current_course)
            courses_dict[current_course.id] = current_course
        end

        # for each course object create its requisites
        for course in current_term["curriculum_items"]
            # if the course has requisites
            if !isempty(course["curriculum_requisites"])
                # cor each requisite of the course
                for req in course["curriculum_requisites"]
                    # create the requisite relationship
                    source = ""
                    if(typeof(req["source_id"]) == Int)
                        source = courses_dict[req["source_id"]]
                    elseif(typeof(req["source_id"]) == String)
                        source = courses_dict[new_courses_IDs[req["source_id"]]]
                    end
                    target = ""
                    if(typeof(req["target_id"]) == Int)
                        target = courses_dict[req["target_id"]]
                    elseif(typeof(req["target_id"]) == String)
                        target = courses_dict[new_courses_IDs[req["target_id"]]]
                    end
                    add_requisite!(source, target, dict_requisite[req["type"]])
                end
            end
        end
        # Set the current term to be a Term object
        terms[i] = Term(courses)
    end    
    #then split courses betweeen additional and curriculum courses
    curric_courses = Course[]
    additional_courses = Course[]
    for course in all_courses
        if isdefined(original_curric, :additional_courses) && find_courses(original_curric.additional_courses, course.id)
            push!(additional_courses,course)
            push!(curric_courses,course)
        elseif find_courses(original_curriculum.courses,course.id)
            push!(curric_courses,course)
        elseif is_dp
            push!(additional_courses,course)
        else
            push!(curric_courses,course)
        end
    end
    curric = Curriculum(original_curriculum.name, curric_courses, learning_outcomes = original_curriculum.learning_outcomes,
                        degree_type = original_curriculum.degree_type, system_type = original_curriculum.system_type, 
                        institution = original_curriculum.institution, CIP=original_curriculum.CIP, id=original_curriculum.id)
    if is_dp
        degree_curric = DegreePlan(original_curric.name, curric, terms, additional_courses)
        write_csv(degree_curric, file_path)
    else
        write_csv(curric, file_path)
    end
end