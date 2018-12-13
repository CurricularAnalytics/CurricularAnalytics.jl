using JSON
using CSV
using DataFrames
function find_curric_courses(curric,course)
    for c_course in curric.courses
        if c_course.id == course
            return true
        end
    end
    return false
end
function find_additional_courses(ad_course,course)
    for ad_c in ad_course
        if ad_c.id == course
            return true
        end
    end
    return false
end
function course_line(course,term_id)
    course_ID = course.id
    course_name = course.name
    course_prefix = course.prefix
    course_num = course.num
    course_vertex = course.vertex_id 
    course_prereq = "\""
    course_coreq = "\""
    course_scoreq = "\""
    for requesite in course.requisites
        if requesite[2] == pre
            course_prereq=course_prereq*string(requesite[1])*","
        elseif requesite[2] == co
            course_coreq=course_coreq*string(requesite[1])*","
        elseif requesite[2] == strict_co
            course_scoreq=course_scoreq*string(requesite[1])*","
        end
    end
    course_prereq = chop(course_prereq)
    if length(course_prereq)>0
        course_prereq=course_prereq* "\""
    end
    course_coreq = chop(course_coreq)
    if length(course_coreq)>0
        course_coreq=course_coreq* "\""
    end
    course_scoreq = chop(course_scoreq)
    if length(course_scoreq)>0
        course_scoreq=course_scoreq* "\""
    end                           
    course_chours = course.credit_hours
    course_inst = course.institution
    course_canName = course.canonical_name
    course_term = term_id
    c_line= "\n"*string(course_ID)*","*string(course_name)*","*string(course_prefix)*","*string(course_num)*","*
                    string(course_prereq)*","*string(course_coreq)*","*string(course_scoreq)*","*
                    string(course_chours)*","*string(course_inst)*","*string(course_canName)*","*string(course_term)
    return c_line 
end

function write_csv(original_plan,file_path::AbstractString="default_csv.csv")
    dict_curric_degree_type = Dict(AA=>"AA", AS=>"AS", AAS=>"AAS", BA=>"BA", BS=>"BS")
    dict_curric_system = Dict(semester=>"semester", quarter=>"quarter")
    open(file_path, "w") do csv_file
        #11 colums
        course_header="\nCourse ID,Course Name,Prefix,Number,Prerequisites,Corequisites,Strict-Corequisites,Credit Hours,Institution,Canonical Name,Term"
        curric = original_plan.curriculum
        curric_name = "Curriculum Name,"* string(curric.name) *",,,,,,,,,"
        write(csv_file, curric_name)   
        println(isdefined(original_plan, :additional_courses))
        println(original_plan.name != "")
        if original_plan.name != "" || isdefined(original_plan, :additional_courses)
            dp_name="\nDegree Plan Name,"*string(original_plan.name)*",,,,,,,,,"
            write(csv_file, dp_name)
        end
        curric_ins = "\nInstitution,"*string(curric.institution)*",,,,,,,,,"
        write(csv_file,curric_ins) 
        curric_dtype="\nDegree Type,"*string(dict_curric_degree_type[curric.degree_type])*",,,,,,,,,"
        write(csv_file,curric_dtype) 
        curric_stype="\nSystem Type,"*string(dict_curric_system[curric.system_type])*",,,,,,,,,"
        write(csv_file,curric_stype) 
        curric_CIP="\nCIP,"*string(curric.CIP)*",,,,,,,,,"
        write(csv_file,curric_CIP) 
        write(csv_file,"\nCourses,,,,,,,,,,") 
        write(csv_file,course_header) 
        for (term_id,term) in enumerate(original_plan.terms)
            for course in term.courses
                if find_curric_courses(curric,course.id)
                    write(csv_file, course_line(course,term_id)) 
                end
            end
        end
        if isdefined(original_plan, :additional_courses)
            write(csv_file,"\nAdditional Courses,,,,,,,,,,")
            write(csv_file,course_header) 
            for (term_id,term) in enumerate(original_plan.terms)
                for course in term.courses
                    if find_additional_courses(original_plan.additional_courses,course.id)
                        write(csv_file,course_line(course,term_id)) 
                    end
                end
            end
        end

        all_course_lo = Dict{Int,Array{LearningOutcome,1}}()
        for (term_id,term) in enumerate(original_plan.terms)
            for course in term.courses
                if length(course.learning_outcomes)>0
                    all_course_lo[course.id] = course.learning_outcomes
                end
            end
        end
        if length(all_course_lo)>0
            write(csv_file,"\nCourse Learning Outcomes,,,,,,,,,,") 
            write(csv_file,"\nCourse ID,Learning Outcome ID,Learning Outcome,Description,Requisites,Hours,,,,,") 
            for lo_arr in all_course_lo
                for lo in lo_arr[2]
                    course_ID = lo_arr[1]
                    lo_ID = lo.id
                    lo_name=lo.name
                    lo_desc=lo.description
                    lo_prereq = "\""
                    for requesite in lo.requisites
                        lo_prereq=lo_prereq*string(requesite[1])*","
                    end
                    lo_prereq = chop(lo_prereq)
                    if length(lo_prereq)>0
                       lo_prereq=lo_prereq* "\""
                    end
                    lo_hours=lo.hours
                    lo_line = "\n"*string(course_ID)*","*string(lo_ID)*","*string(lo_name)*","*string(lo_desc)*","*
                                    string(lo_prereq)*","*string(lo_hours)*",,,,,"
                    
                    write(csv_file,lo_line) 
                end
            end
        end
        if length(curric.learning_outcomes)>0
            write(csv_file,"\nCurriculum Learning Outcomes,,,,,,,,,,") 
            write(csv_file,"\nLearning Outcome,Description,,,,,,,,,") 
            for lo in curric.learning_outcomes
                lo_name=lo.name
                lo_desc=lo.description
                lo_line = "\n"*string(lo_name)*","*string(lo_desc)*",,,,,,,,,"
                write(csv_file,lo_line) 
            end 
        end
        
    end
end
function csv_line_reader(line::AbstractString, delimeter::Char=',')
    quotes =false
    result = String[]
    item=""
    for ch in line
        if ch == '"'
            quotes=!quotes
        elseif ch == delimeter && !quotes
            push!(result,item)
            item=""
        else
            item= item * string(ch)
        end
    end
    if length(item)>0
        push!(result,item)
    end
    return result
end

function find_cell(row, header)
    try
        out = row[header]
        return out
    catch e
        if isa(e, KeyError)
            return Missing
        else
            throw(e)
        end
    end
end

function generate_course_lo(df_learning_outcomes::DataFrame)
    lo_dict= Dict{Int, LearningOutcome}()
    for row in eachrow(df_learning_outcomes)
        lo_ID = find_cell(row,Symbol("Learning Outcome ID"))
        lo_name = find_cell(row,Symbol("Learning Outcome"))
        lo_description = if typeof(find_cell(row,Symbol("Description"))) == Missing "" else find_cell(row,Symbol("Description")) end
        lo_Credit = if typeof(find_cell(row,Symbol("Hours"))) == Missing 0 else find_cell(row,Symbol("Hours")) end
        if lo_ID in keys(lo_dict)
            throw("Learning Outcome ID must be unique")
        else
            lo_dict[lo_ID] = LearningOutcome(lo_name, lo_description,lo_Credit)
        end
    end
    for row in eachrow(df_learning_outcomes)
        lo_ID = find_cell(row,Symbol("Learning Outcome ID"))
        reqs = find_cell(row,Symbol("Requisites"))
        if typeof(reqs) != Missing
            for req in reqs
               add_lo_requisite!(lo_dict[req],lo_dict[lo_ID],pre)
            end
        end
    end
    lo_Course = Dict{Int, Array{LearningOutcome}}()
    for row in eachrow(df_learning_outcomes)
        c_ID = find_cell(row,Symbol("Course ID"))
        lo_ID = find_cell(row,Symbol("Learning Outcome ID"))
        if c_ID in keys(lo_Course)
            push!(lo_Course[c_ID],lo_dict[lo_ID]) 
        else
            lo_Course[c_ID] = [lo_dict[lo_ID]]
        end
    end    
    return lo_Course
end

function generate_curric_lo(df_curric_lo::DataFrame)
    learning_outcomes = LearningOutcome[]
    for row in eachrow(df_curric_lo)
        lo_name = find_cell(row,Symbol("Learning Outcome"))
        lo_description = find_cell(row,Symbol("Description"))
        push!(learning_outcomes,LearningOutcome(lo_name, lo_description,0))
    end
    return learning_outcomes
end

function read_all_courses(df_courses::DataFrame, lo_Course:: Dict{Int, Array{LearningOutcome}}=Dict{Int, Array{LearningOutcome}}())
    course_dict= Dict{Int, Course}()
    for row in eachrow(df_courses)
        c_ID = row[Symbol("Course ID")]
        c_Name = if typeof(find_cell(row,Symbol("Course Name"))) == Missing "" else find_cell(row,Symbol("Course Name")) end
        c_Credit = row[Symbol("Credit Hours")] 
        c_Prefix = if typeof(find_cell(row,Symbol("Prefix"))) == Missing "" else find_cell(row,Symbol("Prefix")) end
        c_Number = if typeof(find_cell(row,Symbol("Number"))) == Missing "" else string(find_cell(row,Symbol("Number"))) end
        c_Inst = if typeof(find_cell(row,Symbol("Institution"))) == Missing "" else find_cell(row,Symbol("Institution")) end
        c_col_name = if typeof(find_cell(row,Symbol("Canonical Name"))) == Missing "" else find_cell(row,Symbol("Canonical Name")) end
        learning_outcomes = if c_ID in keys(lo_Course) lo_Course[c_ID] else LearningOutcome[] end
        if c_ID in keys(course_dict)
            throw("Course IDs must be unique")
        else
            course_dict[c_ID] = Course(c_Name, c_Credit, prefix= c_Prefix, learning_outcomes= learning_outcomes,
                num= c_Number, institution=c_Inst, canonical_name=c_col_name)
        end
    end
    for row in eachrow(df_courses)
        c_ID = row[Symbol("Course ID")]
        pre_reqs = find_cell(row,Symbol("Prerequisites"))
        if typeof(pre_reqs) != Missing
            for pre_req in split(string(pre_reqs),",")
                add_requisite!(course_dict[parse(Int,pre_req)],course_dict[c_ID],pre)
            end
        end
        co_reqs = find_cell(row,Symbol("Corequisites"))
        if typeof(co_reqs) != Missing
            for co_req in split(string(co_reqs),",")
                add_requisite!(course_dict[parse(Int,co_req)],course_dict[c_ID],co)
            end
        end
        sco_reqs = find_cell(row,Symbol("Strict-Corequisites"))
        if typeof(sco_reqs) != Missing
            for sco_req in split(string(sco_reqs),",")
                add_requisite!(course_dict[parse(Int,sco_req)],course_dict[c_ID],strict_co)
            end
        end

    end
    return course_dict
end

function read_courses(df_courses::DataFrame, all_courses::Dict{Int,Course})
    course_dict= Dict{Int, Course}()
    for row in eachrow(df_courses)
        c_ID = row[Symbol("Course ID")]
        course_dict[c_ID] = all_courses[c_ID]
    end
    return course_dict
end

function read_terms(df_courses::DataFrame, course_dict::Dict{Int, Course})
    terms = Dict{Int, Array{Course}}()
    for row in eachrow(df_courses)
        c_ID = find_cell(row,Symbol("Course ID"))
        term_ID = find_cell(row,Symbol("Term"))
        if term_ID in keys(terms)
            push!(terms[term_ID],course_dict[c_ID]) 
        else
            terms[term_ID] = [course_dict[c_ID]]
        end
    end    
    return terms
end
function read_terms(df_courses::DataFrame,course_dict::Dict{Int, Course}, course_arr::Array{Course,1})
    terms = Dict{Int, Array{Course}}()
    for row in eachrow(df_courses)
        c_ID = find_cell(row,Symbol("Course ID"))
        term_ID = find_cell(row,Symbol("Term"))
        for course in course_arr
            if course_dict[c_ID].id == course.id
                if term_ID in keys(terms)
                    push!(terms[term_ID],course) 
                else
                    terms[term_ID] = [course]
                end
                break
            end            
        end        
        
    end    
    return terms
end
function read_csv_new(file_path::AbstractString)
    dict_curric_degree_type = Dict("AA"=>AA, "AS"=>AS, "AAS"=>AAS, "BA"=>BA, "BS"=>BS)
    dict_curric_system = Dict("semester"=>semester, "quarter"=>quarter)
    dp_name = ""
    dp_add_courses = Array{Course,1}()
    curric_name = ""
    curric_inst = ""
    curric_dtype = dict_curric_degree_type["BS"]
    curric_stype = dict_curric_system["semester"]
    curric_CIP = ""
    courses_header = 1
    course_count = 0
    additional_course_start=0
    additional_course_count=0
    learning_outcomes_start=0
    learning_outcomes_count=0
    curric_learning_outcomes_start=0
    curric_learning_outcomes_count=0
    part_missing_term=false
    open(file_path) do csv_file        
        read_line = csv_line_reader(readline(csv_file),',')
        courses_header += 1
        if read_line[1] == "Curriculum Name"
            curric_name = read_line[2]
            read_line = csv_line_reader(readline(csv_file),',')
            is_dp = read_line[1] == "Degree Plan Name"
            if is_dp 
                dp_name = read_line[2]
                read_line = csv_line_reader(readline(csv_file),',')
                courses_header += 1
            end
            if read_line[1] == "Institution"
                curric_inst = read_line[2]
                read_line = csv_line_reader(readline(csv_file),',')
                courses_header += 1
            end
            if read_line[1] == "Degree Type"
                curric_dtype = dict_curric_degree_type[read_line[2]]
                read_line = csv_line_reader(readline(csv_file),',')
                courses_header += 1
            end
            if read_line[1] == "System Type"
                curric_stype = dict_curric_system[read_line[2]]
                read_line = csv_line_reader(readline(csv_file),',')
                courses_header += 1
            end
            if read_line[1] == "CIP"
                curric_CIP = read_line[2]
                read_line = csv_line_reader(readline(csv_file),',')
                courses_header += 1
            end
            if read_line[1] == "Courses"
                courses_header += 1 
            else
                throw("Could not found Courses")
            end         
            
        else 
            throw("Could not found a Curriculum")
        end
        #read_line = csv_line_reader(readline(csv_file),',')
        #courses_start += 1
        read_line = csv_line_reader(readline(csv_file),',')
        while length(read_line)>0 && read_line[1] != "Additional Courses" && read_line[1] != "Course Learning Outcomes"&&
            read_line[1] != "Curriculum Learning Outcomes" && !startswith(read_line[1],"#")
            if length(read_line[1]) == 0
                throw("All courses must have Course ID")
            end
            course_count +=1
            read_line = csv_line_reader(readline(csv_file),',')
        end
        df_courses = CSV.File(file_path, header=courses_header, limit=course_count-1) |> DataFrame
        if nrow(df_courses) != nrow(unique(df_courses, Symbol("Course ID")))
            throw("All courses must have unique Course ID")
        end
        df_all_courses = DataFrame()
        df_additional_courses =DataFrame()
        if length(read_line)>0 && read_line[1] == "Additional Courses"
            if !is_dp throw("Only Degree Plan could have additional classes") end
            additional_course_start = courses_header+course_count+1
            read_line = csv_line_reader(readline(csv_file),',')
            while length(read_line)>0 && read_line[1] != "Course Learning Outcomes" && 
                read_line[1] != "Curriculum Learning Outcomes" && !startswith(read_line[1],"#")
                additional_course_count +=1
                read_line = csv_line_reader(readline(csv_file),',')
            end     
        end
        if additional_course_count > 1
            df_additional_courses = CSV.File(file_path, header=additional_course_start, limit=additional_course_count-1) |> DataFrame
            df_all_courses = vcat(df_courses,df_additional_courses)
            #add_cources=create_additional_courses(df_additional_courses, terms,part_missing)
        else
            df_all_courses = df_courses
        end
        
        if any(ismissing.(df_all_courses[Symbol("Term")])) && is_dp
            throw("All courses in Degree Plan must have Term information")
        end  
        df_course_learning_outcomes=""
        if length(read_line)>0 && read_line[1] == "Course Learning Outcomes"
            learning_outcomes_start = additional_course_start+additional_course_count+1
            read_line = csv_line_reader(readline(csv_file),',')
            while length(read_line)>0 && !startswith(read_line[1],"#")  && read_line[1] != "Curriculum Learning Outcomes"
                learning_outcomes_count +=1
                read_line = csv_line_reader(readline(csv_file),',')
            end  
            if learning_outcomes_count > 1
                df_course_learning_outcomes = CSV.File(file_path, header=learning_outcomes_start, limit=learning_outcomes_count-1) |> DataFrame
            end
        end    
        
        course_learning_outcomes =if df_course_learning_outcomes != "" generate_course_lo(df_course_learning_outcomes) else Dict{Int, Array{LearningOutcome}}() end
        
        df_curric_learning_outcomes = ""
        if length(read_line)>0 && read_line[1] == "Curriculum Learning Outcomes"
            curric_learning_outcomes_start = learning_outcomes_start+learning_outcomes_count+1
            read_line = csv_line_reader(readline(csv_file),',')
            while length(read_line)>0 && !startswith(read_line[1],"#")
                curric_learning_outcomes_count +=1
                read_line = csv_line_reader(readline(csv_file),',')
            end            
            if learning_outcomes_count > 1
                df_curric_learning_outcomes = CSV.File(file_path, header=curric_learning_outcomes_start, limit=curric_learning_outcomes_count-1) |> DataFrame
            end
        end  
        
        curric_learning_outcomes =if df_curric_learning_outcomes != "" generate_curric_lo(df_curric_learning_outcomes) else LearningOutcome[] end

        if is_dp
            all_courses = read_all_courses(df_all_courses,course_learning_outcomes)
            all_courses_arr = [course[2] for course in all_courses]
            curric = Curriculum("",all_courses_arr,learning_outcomes=Array{LearningOutcome,1}()) 
            delay_factor(curric)
            blocking_factor(curric)
            centrality(curric)
            complexity(curric)
            terms = read_terms(df_all_courses,all_courses, curric.courses)
            #terms = read_terms(df_all_courses, all_courses)
            terms_arr = Array{Term}(undef,length(terms))
            for term in terms
                terms_arr[term[1]]=Term([class for class in term[2]])
            end
            curric_courses = read_courses(df_courses, all_courses)
            curric_courses = [course[2] for course in curric_courses] 
            additional_courses = read_courses(df_additional_courses,all_courses)  
            ac_arr =Course[]
            for course in additional_courses
                push!(ac_arr,course[2])
            end             
            curric = Curriculum(curric_name, curric_courses, learning_outcomes = curric_learning_outcomes, degree_type= curric_dtype,
                                system_type=curric_stype, institution=curric_inst, CIP=curric_CIP,id=curric.id)
            
            degree_plan = DegreePlan(dp_name, curric, terms_arr, ac_arr)
            return degree_plan
            #visualize(degree_plan, notebook=true)
        else
            curric_courses = read_all_courses(df_courses,course_learning_outcomes)
            curric_courses_arr = [course[2] for course in curric_courses] 
            term_type =  eltype(df_courses[Symbol("Term")])
            if term_type == Missing  
                curric = Curriculum(curric_name, curric_courses_arr, learning_outcomes = curric_learning_outcomes, degree_type= curric_dtype,
                                    system_type=curric_stype, institution=curric_inst, CIP=curric_CIP)
                delay_factor(curric)
                blocking_factor(curric)
                centrality(curric)
                complexity(curric)
                complexity(curric)
                return curric
                #visualize(curric, notebook=true)
            else
                #If term information is given but part of it missing note that and make a new term at the end of them
                #part_missing_term=any(ismissing.(df_courses[Symbol("Term")]))
                terms = read_terms(df_courses, curric_courses)
                terms_arr = Array{Term}(undef,length(terms))
                for term in terms
                    terms_arr[term[1]]=Term([class for class in term[2]])
                end
                curric = Curriculum(curric_name, curric_courses_arr, learning_outcomes = curric_learning_outcomes, degree_type= curric_dtype,
                                    system_type=curric_stype, institution=curric_inst, CIP=curric_CIP)
                delay_factor(curric)
                blocking_factor(curric)
                centrality(curric)
                complexity(curric)
                degree_plan = DegreePlan("", curric, terms_arr)
                return degree_plan
                #visualize(degree_plan, notebook=true)
            end
        end
    end
end

function prepare_data(degree_plan::DegreePlan, edit,hide_header)
    dp_dict=Dict{String,Any}()
    dp_dict["options"] = Dict{String, Any}()
    dp_dict["options"]["edit"]=edit
    dp_dict["options"]["hideTerms"]=hide_header
    dp_dict["curriculum"] = Dict{String, Any}()
    dp_dict["curriculum"]["dp_name"] = degree_plan.name
    dp_dict["curriculum"]["name"] = degree_plan.curriculum.name
    #dp_dict["curriculum"]["id"] = degree_plan.curriculum.id
    dp_dict["curriculum"]["institution"] = degree_plan.curriculum.institution
    #dp_dict["curriculum"]["CIP"] = degree_plan.curriculum.CIP
    dp_dict["curriculum"]["curriculum_terms"] = Dict{String, Any}[]
    for i = 1:degree_plan.num_terms
        current_term = Dict{String, Any}()
        current_term["id"] = i
        current_term["name"] = "Term $i"
        current_term["curriculum_items"] = Dict{String, Any}[]
        for course in degree_plan.terms[i].courses
            current_course = Dict{String, Any}()
            current_course["id"] = course.id
            current_course["nameSub"] = course.name
            current_course["name"] =  course.prefix * " " * course.num
            #current_course["prefix"] =  course.prefix
            #current_course["num"] = course.num
            current_course["credits"] = course.credit_hours
            current_course["curriculum_requisites"] = Dict{String, Any}[]
            current_course["metrics"] = course.metrics
            #current_course["institution"] = course.institution
            #current_course["canonical_name"] = course.canonical_name
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
    terms = Array{Term}(undef, nrow(unique(df, Symbol("Term"))))
    by(df, Symbol("Term")) do term    
        termclasses = Array{Course}(undef,nrow(term))
        for (index, row) in enumerate(eachrow(term))
            c_Count = find_cell(row,Symbol("Course ID"))
            c_Name = if typeof(find_cell(row,Symbol("Course Name"))) == Missing "" else find_cell(row,Symbol("Course Name")) end
            c_Credit = find_cell(row,Symbol("Credit Hours")) 
            c_Prefix = if typeof(find_cell(row,Symbol("Prefix"))) == Missing "" else find_cell(row,Symbol("Prefix")) end
            c_Number = if typeof(find_cell(row,Symbol("Number"))) == Missing "" else find_cell(row,Symbol("Number")) end
            c[c_Count]= Course(c_Name, c_Credit, prefix = c_Prefix, num = c_Number)
            if typeof(find_cell(row,Symbol("Requisities"))) != Missing
                for req in split(find_cell(row,Symbol("Requisities")))
                    split_req = split(req,":")
                    add_requisite!(c[parse(Int64,split_req[2])],c[c_Count],dict_Requisite[split_req[1]])
                end
            end       
            termclasses[index]=c[c_Count]
        end
        terms[term[Symbol("Term")][1]]=Term(termclasses)    
    end
    return c, terms
end

function write_csv(file_path::AbstractString, original_plan::Dict{String,Any}, editied_curric::Dict{String,Any})

    println("dsadasda")
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
    #Create terms dictionary    
    degree_plan["name"] = ""
    degree_plan["curriculum"] = Dict{String, Any}()
    degree_plan["curriculum"]["name"] = ""
    degree_plan["curriculum"]["id"] = 0
    degree_plan["curriculum"]["institution"] = ""
    degree_plan["curriculum"]["CIP"] = ""
    degree_plan["curriculum"]["curriculum_terms"] = Dict{String, Any}[]
    by(df, :7) do term # group by term, the 7th column in the CSV file
        current_term = Dict{String, Any}()
        current_term["id"] = term[7][1]
        name = term[7][1]
        current_term["name"] = "Term $name"
        current_term["curriculum_items"] = Dict{String, Any}[]
        for course in 1:size(term)[1]
            current_course = Dict{String, Any}()
            current_course = Dict{String, Any}()
            current_course["id"] = term[1][course]
            current_course["nameSub"] = term[2][course]
            current_course["name"] = if typeof(term[3][course]) == Missing || typeof(term[4][course]) == Missing "" else term[3][course] * " " * term[4][course] end
            current_course["prefix"] = if typeof(term[3][course]) == Missing "" else term[3][course] end 
            current_course["num"] = if typeof(term[4][course]) == Missing "" else term[4][course] end
            current_course["institution"] = ""
            current_course["canonical_name"] = ""
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
    degreeplan["curriculum"]["dp_name"] = plan.name
    degreeplan["curriculum"]["name"] = plan.curriculum.name
    degreeplan["curriculum"]["id"] = plan.curriculum.id
    degreeplan["curriculum"]["institution"] = plan.curriculum.institution
    degreeplan["curriculum"]["CIP"] = plan.curriculum.CIP
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
            current_course["institution"] = course.institution
            current_course["canonical_name"] = course.canonical_name
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
            current_course = Course(course["nameSub"], course["credits"], institution = course["institution"],
                 prefix = course["prefix"], num = course["num"], canonical_name=course["canonical_name"], id = course["id"])
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
    curric = Curriculum(degree_plan["curriculum"]["name"], all_courses, institution = degree_plan["curriculum"]["institution"],
        id = degree_plan["curriculum"]["id"], CIP=degree_plan["curriculum"]["CIP"])
    return DegreePlan(degree_plan["name"], curric, terms)
end