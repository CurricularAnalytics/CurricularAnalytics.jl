using JSON
using CSV
using DataFrames


"""
    read_csv(file_path::AbstractString)

Reads a degree plan stored as a CSV file and returns the courses and terms associated with the degree plan.

# Argument
- `file_path::AbstractString` : Fully-qualfied or realtive path of the CSV file that will be read.
"""
function read_csv(file_path::AbstractString)
    df = CSV.File(file_path) |> DataFrame
    dict_Requisite = Dict("pre"=>pre, "co"=>co, "strict_co"=>strict_co)
    c = Array{Course}(undef,nrow(df))
    terms = Array{Term}(undef, nrow(unique(df, 7)))
    by(df, :7) do term    
        termclasses = Array{Course}(undef,nrow(term))
        for (index, row) in enumerate(eachrow(term))
            c_Count = row[1]
            c_Name = if typeof(row[2]) == Missing "" else row[2] end
            c_Credit = row[6]
            c_Prefix = if typeof(row[3]) == Missing "" else row[3] end
            c_Number = if typeof(row[4]) == Missing "" else row[4] end
            c[c_Count]= Course(c_Name, c_Credit, prefix = c_Prefix, num = c_Number)
            if typeof(row[5]) != Missing
                for req in split(row[5])
                    split_req = split(req,":")
                    add_requisite!(c[parse(Int64,split_req[2])],c[c_Count],dict_Requisite[split_req[1]])
                end
            end       
            termclasses[index]=c[c_Count]
        end
        terms[term[7][1]]=Term(termclasses)    
    end
    return c, terms
end

"""
    csv_to_json(csv_file_path::AbstractString, json_file_path::AbstractString)

Converts a degree plan stored as a CSV file into a degree plan stored as a JSON file.

# Arguments
- `csv_file_path::AbstractString` : fully-qualfied or realtive path of the CSV file that 
will be read.
- `json_file_path::AbstractString` : fully-qualfied or realtive path of the JSON file that 
will be written.
"""
function csv_to_json(csv_file_path::AbstractString, json_file_path::AbstractString)
    # read the CSV file into a DataFrame
    df = CSV.File(csv_file_path) |> DataFrame
    file = open(json_file_path, "w")
    # create a dictionary containing all degree plan information
    degree_plan = Dict{String, Any}()
    # add a new curriculum dictionary to the degree plan dictionary
    degree_plan["curriculum"] = Dict{String, Any}()
    #Create terms dictionary
    degree_plan["curriculum"]["curriculum_terms"] = Dict{String, Any}[]
    
    by(df, :7) do term # group by term, the 7th column in the CSV file
        current_term = Dict{String, Any}()
        current_term["id"] = term[7][1]
        name = term[7][1]
        current_term["name"] = "Term $name"
        current_term["curriculum_items"] = Dict{String, Any}[]
        for course in 1:size(term)[1]
            current_course = Dict{String, Any}()
            current_course["id"] = term[1][course]
            current_course["nameSub"] = term[2][course]
            current_course["name"] = if typeof(term[3][course]) == Missing || typeof(term[4][course]) == Missing "" else term[3][course] * " " * term[4][course] end
            current_course["prefix"] = if typeof(term[3][course]) == Missing "" else term[3][course] end 
            current_course["num"] = if typeof(term[4][course]) == Missing "" else term[4][course] end
            current_course["credits"] = term[6][course]
            current_course["curriculum_requisites"] = Dict{String, Any}[]
            # current_course["metrics"] = course.metrics
            if typeof(term[5][course]) != Missing
                for req in split(term[5][course])
                    current_req = Dict{String, Any}()
                    current_req["source_id"] = parse(Int64,(split(req,":")[2]))
                    current_req["target_id"] = term[1][course]
                    # parse the Julia requisite type to the required type for the visualization
                    current_req["type"] = split(req,":")[1]
                    push!(current_course["curriculum_requisites"], current_req)
                end
            end
            push!(current_term["curriculum_items"], current_course)
        end
        push!(degree_plan["curriculum"]["curriculum_terms"], current_term)
    end
    JSON.print(file, degree_plan, 1)
    close(file)
end

# Takes requisite and return it as a string for the visualization
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
    if req == "prereq"
        return pre
    elseif req == "coreq"
        return co
    else
        return strict_co
    end
end

"""
    write_degree_plan(plan::DegreePlan, file_path::AbstractString)

Writes a degree plan as a JSON file.  

# Arguments
- `plan::DegreePlan` : variable of type DegreePlan. 
will be read.
- `file_path::AbstractString` : fully-qualfied or realtive path of the JSON file that will be written.
"""
function write_degree_plan(plan::DegreePlan, file_path::AbstractString)
    io = open(file_path, "w")
    degreeplan = Dict{String, Any}()
    degreeplan["curriculum"] = Dict{String, Any}()
    degreeplan["curriculum"]["name"] = plan.name
    degreeplan["curriculum"]["curriculum_terms"] = Dict{String, Any}[]
    for i = 1:plan.num_terms
        current_term = Dict{String, Any}()
        current_term["id"] = i
        current_term["name"] = "Term $i"
        current_term["curriculum_items"] = Dict{String, Any}[]
        for course in plan.terms[i].courses
            current_course = Dict{String, Any}()
            current_course["id"] = course.id
            current_course["nameSub"] = course.name
            current_course["name"] =  course.prefix * " " * course.num
            current_course["prefix"] =  course.prefix
            current_course["num"] = course.num
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
        push!(degreeplan["curriculum"]["curriculum_terms"], current_term)
    end
    JSON.print(io, degreeplan, 1)
    close(io)
end

"""
    read_degree_plan(file_path::AbstractString)

Reads a degree plan stored as a JSON file and returns a DegreePlan data type containing the degree plan information.  

# Arguments
- `file_path::AbstractString` : fully-qualfied or realtive path of the JSON file that will be read.
"""
function read_degree_plan(file_path::AbstractString)
    open(file_path, "r") do f
        # Create empty dictionary to hold the imported data
        global degree_plan = Dict()
        filetxt = read(f, String)  # file information to string
        degree_plan=JSON.parse(filetxt)  # parse and transform data
    end
    # create an array for the terms 
    num_terms = length(degree_plan["curriculum"]["curriculum_terms"])
    terms = Array{Term}(undef, num_terms)
    all_courses = Array{Course}(undef, 0)
    courses_dict = Dict{Int, Course}()
    for i = 1:num_terms
        # grab the current term
        current_term = degree_plan["curriculum"]["curriculum_terms"][i]
        # create an array of course objects with length equal to the number of courses
        courses = Array{Course}(undef, 0)
        # for each course in the current term
        for course in current_term["curriculum_items"]
            # create Course object for each course in the current term
            current_course = Course(course["nameSub"], course["credits"], prefix = course["prefix"], num = course["num"])
            # push each Course object to the array of courses
            push!(courses, current_course)
            push!(all_courses, current_course)
            courses_dict[course["id"]] = current_course
        end

        # for each course object create its requisites
        for course in current_term["curriculum_items"]
            # if the course has requisites
            if !isempty(course["curriculum_requisites"])
                # cor each requisite of the course
                for req in course["curriculum_requisites"]
                    # create the requisite relationship
                    source = courses_dict[req["source_id"]]
                    target = courses_dict[req["target_id"]]
                    add_requisite!(source, target, string_to_requisite(req["type"]))
                end
            end
        end
        # Set the current term to be a Term object
        terms[i] = Term(courses)
    end
    curric = Curriculum("Underwater Basket Weaving", all_courses)
    return DegreePlan("MyPlan", curric, terms)
end