using JSON

function string_to_requisite(req::String)
    if req == "pre"
        return pre
    elseif req == "co"
        return co
    else
        return strict_co
    end
end 

function parse_requisites(c::Dict{String, Any})
    reqs = Dict{Int, Requisite}()
    for r in collect(keys(c["requisites"]))
        reqs[parse(Int64, r)] = string_to_requisite(c["requisites"][r])
    end
    return reqs
end

function course_to_json(c::Course)
    JSON.json(c)
end

function json_to_course(jsonString::String)
    parsedJson = JSON.parse(jsonString)
    return Course(parsedJson["id"], parsedJson["name"], parsedJson["credit_hours"], parsedJson["prefix"], parsedJson["num"], parsedJson["institution"], 
                parsedJson["canonical_name"], parse_requisites(parsedJson), parsedJson["metrics"])
end

function export_degree_plan(plan::DegreePlan)
    io = open("curriculum-data.json", "w")
    degreeplan = Dict{String, Any}()
    degreeplan["curriculum"] = Dict{String, Any}()
    degreeplan["curriculum"]["curriculum_terms"] = Dict{String, Any}[]
    for i = 1:plan.num_terms
        current_term = Dict{String, Any}()
        current_term["id"] = i
        current_term["name"] = "Term $i"
        current_term["curriculum_items"] = Dict{String, Any}[]
        for course in plan.terms[i].courses
            current_course = Dict{String, Any}()
            current_course["id"] = course.id
            # Name should be changed to export the actual course name
            current_course["nameSub"] = course.name
            # The prefix and number should be exported as seperate fields here
            # This is so it can be correctly imported later
            current_course["name"] =  course.prefix * " " * course.num
            current_course["credits"] = course.credit_hours
            current_course["curriculum_requisites"] = Dict{String, Any}[]
            for req in collect(keys(course.requisites))
                current_req = Dict{String, Any}()
                current_req["source_id"] = req
                current_req["target_id"] = course.id
                current_req["type"] = course.requisites[req]
                push!(current_course["curriculum_requisites"], current_req)
            end
            push!(current_term["curriculum_items"], current_course)
        end
        push!(degreeplan["curriculum"]["curriculum_terms"], current_term)
    end
    JSON.print(io, degreeplan, 1)
    close(io)
end

function import_degree_plan()
    # read in JSON from curriculum-data.json
    open("curriculum-data.json", "r") do f
        # Create empty dictionary to hold the imported data
        global degree_plan = Dict()
        filetxt = read(f, String)  # file information to string
        degree_plan=JSON.parse(filetxt)  # parse and transform data
    end
    # Create an array "terms" with elements equal to the number of terms from the file
    num_terms = length(degree_plan["curriculum"]["curriculum_terms"])
    terms = Array{Term}(undef, num_terms)
    # For every term
    for i = 1:num_terms
        # Grab the current term
        current_term = degree_plan["curriculum"]["curriculum_terms"][i]
        # Create an array of course objects with length equal to the number of courses
        courses = Array{Course}(undef, 0)
        # For each course in the current term
        for course in current_term["curriculum_items"]
            # Create Course object for each course in the current term
            current_course = Course(course["name"], course["credits"])
            # Push each Course object to the array of courses
            push!(courses, current_course)
        end
    end
end