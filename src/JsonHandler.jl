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
    curric = Dict{String, Any}()
    curric["curriculum"] = Dict{String, Any}()
    curric["curriculum"]["curriculum_terms"] = Dict{String, Any}[]
    for i = 1:plan.num_terms
        current_term = Dict{String, Any}()
        current_term["id"] = i
        current_term["name"] = "Term $i"
        current_term["curriculum_items"] = Dict{String, Any}[]
        for course in plan.terms[i].courses
            current_course = Dict{String, Any}()
            current_course["id"] = course.id
            current_course["name"] = course.prefix != "" ? course.prefix * " " * course.num : course.name
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
        push!(curric["curriculum"]["curriculum_terms"], current_term)
    end
    JSON.print(io, curric, 1)
    close(io)
end