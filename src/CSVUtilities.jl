function readfile(file_path)
    open(file_path) do f 
        lines = readlines(f)
        return lines
    end
end

function remove_empty_lines(file_path)
    if file_path[end-3:end] != ".csv"
        println("Input is not a csv file")
        return false
    end
    temp_file = file_path[1:end-4] * "_temp.csv"
    file = readfile(file_path)
    open(temp_file, "w") do f  
        new_file = ""
        for line in file
            line = replace(line, "\r" => "")
            if length(line) > 0 && !startswith(replace(line,"\""=>""), "#")
                line = line * "\n"
                new_file = new_file * line
            end
        end
        if length(new_file) > 0
            new_file = chop(new_file)
        end
        write(f,new_file)
    end
    return temp_file
end

function find_courses(courses, course_id)
    for course in courses
        if course_id == course.id
            return true
        end
    end
    return false
end

function course_line(course, term_id)
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
            course_prereq = course_prereq * string(requesite[1]) * ";"
        elseif requesite[2] == co
            course_coreq = course_coreq * string(requesite[1]) * ";"
        elseif requesite[2] == strict_co
            course_scoreq = course_scoreq * string(requesite[1]) * ";"
        end
    end
    course_prereq = chop(course_prereq)
    if length(course_prereq) > 0
        course_prereq=course_prereq * "\""
    end
    course_coreq = chop(course_coreq)
    if length(course_coreq) > 0
        course_coreq=course_coreq * "\""
    end
    course_scoreq = chop(course_scoreq)
    if length(course_scoreq) > 0
        course_scoreq=course_scoreq * "\""
    end                           
    course_chours = course.credit_hours
    course_inst = course.institution
    course_canName = course.canonical_name
    course_term = typeof(term_id) == Int ? string(term_id) : term_id
    c_line= "\n" * string(course_ID) * ",\"" * string(course_name) * "\",\"" * string(course_prefix) * "\",\""  *
                    string(course_num) * "\"," * string(course_prereq) * "," * string(course_coreq) * "," *
                    string(course_scoreq) * "," * string(course_chours) *",\""* string(course_inst) * "\",\"" *
                    string(course_canName) * "\"," * course_term
    return c_line 
end

function csv_line_reader(line::AbstractString, delimeter::Char=',')
    quotes = false
    result = String[]
    item = ""
    for ch in line
        if ch == '"'
            quotes != quotes
        elseif ch == delimeter && !quotes
            push!(result,item)
            item = ""
        else
            item = item * string(ch)
        end
    end
    if length(item) > 0
        push!(result, item)
    end
    return result
end

function find_cell(row, header)
    if !(header in names(row))
        return ""
    elseif typeof(row[header]) == Missing
        return ""
    else
        return row[header]
    end
end

function read_all_courses(df_courses::DataFrame, lo_Course:: Dict{Int, Array{LearningOutcome}}=Dict{Int, Array{LearningOutcome}}())
    course_dict= Dict{Int, Course}()
    for row in DataFrames.eachrow(df_courses)
        c_ID = row[Symbol("Course ID")]
        c_Name = find_cell(row, Symbol("Course Name"))
        c_Credit = row[Symbol("Credit Hours")] 
        c_Credit = typeof(c_Credit) == String ? parse(Int,c_Credit) : c_Credit
        c_Prefix = find_cell(row, Symbol("Prefix"))
        c_Number = find_cell(row, Symbol("Number"))
        if typeof(c_Number) != String c_Number = string(c_Number) end
        c_Inst = find_cell(row, Symbol("Institution"))
        c_col_name = find_cell(row, Symbol("Canonical Name"))
        learning_outcomes = if c_ID in keys(lo_Course) lo_Course[c_ID] else LearningOutcome[] end
        if c_ID in keys(course_dict)
            println("Course IDs must be unique")
            return false
        else
            course_dict[c_ID] = Course(c_Name, c_Credit, prefix=c_Prefix, learning_outcomes=learning_outcomes,
                num=c_Number, institution=c_Inst, canonical_name=c_col_name, id=c_ID)
        end
    end
    for row in DataFrames.eachrow(df_courses)
        c_ID = row[Symbol("Course ID")]
        pre_reqs = find_cell(row, Symbol("Prerequisites"))
        if pre_reqs != ""
            for pre_req in split(string(pre_reqs), ";")
                add_requisite!(course_dict[parse(Int, pre_req)], course_dict[c_ID], pre)
            end
        end
        co_reqs = find_cell(row, Symbol("Corequisites"))
        if co_reqs != ""
            for co_req in split(string(co_reqs), ";")
                add_requisite!(course_dict[parse(Int, co_req)], course_dict[c_ID], co)
            end
        end
        sco_reqs = find_cell(row, Symbol("Strict-Corequisites"))
        if sco_reqs != ""
            for sco_req in split(string(sco_reqs), ";")
                add_requisite!(course_dict[parse(Int, sco_req)], course_dict[c_ID], strict_co)
            end
        end

    end
    return course_dict
end

function read_courses(df_courses::DataFrame, all_courses::Dict{Int,Course})
    course_dict = Dict{Int, Course}()
    for row in DataFrames.eachrow(df_courses)
        c_ID = row[Symbol("Course ID")]
        course_dict[c_ID] = all_courses[c_ID]
    end
    return course_dict
end

function read_terms(df_courses::DataFrame,course_dict::Dict{Int, Course}, course_arr::Array{Course,1})
    terms = Dict{Int, Array{Course}}()
    for row in DataFrames.eachrow(df_courses)
        c_ID = find_cell(row, Symbol("Course ID"))
        term_ID = find_cell(row, Symbol("Term"))
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

function generate_course_lo(df_learning_outcomes::DataFrame)
    lo_dict = Dict{Int, LearningOutcome}()
    for row in DataFrames.eachrow(df_learning_outcomes)
        lo_ID = find_cell(row, Symbol("Learning Outcome ID"))
        lo_name = find_cell(row, Symbol("Learning Outcome"))
        lo_description = find_cell(row, Symbol("Description"))
        lo_Credit = find_cell(row, Symbol("Hours"))
        if lo_ID in keys(lo_dict)
            println("Learning Outcome ID must be unique")
            return false
        else
            lo_dict[lo_ID] = LearningOutcome(lo_name, lo_description,lo_Credit)
        end
    end
    for row in DataFrames.eachrow(df_learning_outcomes)
        lo_ID = find_cell(row, Symbol("Learning Outcome ID"))
        reqs = find_cell(row, Symbol("Requisites"))
        if typeof(reqs) != Missing
            for req in reqs
               add_lo_requisite!(lo_dict[req], lo_dict[lo_ID], pre)
            end
        end
    end
    lo_Course = Dict{Int, Array{LearningOutcome}}()
    for row in DataFrames.eachrow(df_learning_outcomes)
        c_ID = find_cell(row, Symbol("Course ID"))
        lo_ID = find_cell(row, Symbol("Learning Outcome ID"))
        if c_ID in keys(lo_Course)
            push!(lo_Course[c_ID], lo_dict[lo_ID]) 
        else
            lo_Course[c_ID] = [lo_dict[lo_ID]]
        end
    end    
    return lo_Course
end

function generate_curric_lo(df_curric_lo::DataFrame)
    learning_outcomes = LearningOutcome[]
    for row in DataFrames.eachrow(df_curric_lo)
        lo_name = find_cell(row, Symbol("Learning Outcome"))
        lo_description = find_cell(row, Symbol("Description"))
        push!(learning_outcomes, LearningOutcome(lo_name, lo_description, 0))
    end
    return learning_outcomes
end

function gather_learning_outcomes(curric::Curriculum)
    all_course_lo = Dict{Int,Array{LearningOutcome,1}}()
    for course in curric.courses
        if length(course.learning_outcomes)>0
            all_course_lo[course.id] = course.learning_outcomes
        end
    end
    return all_course_lo
end

function write_learning_outcomes(curric::Curriculum, csv_file, all_course_lo)
    if length(all_course_lo) > 0
        write(csv_file, "\nCourse Learning Outcomes,,,,,,,,,,") 
        write(csv_file, "\nCourse ID,Learning Outcome ID,Learning Outcome,Description,Requisites,Hours,,,,,") 
        for lo_arr in all_course_lo
            for lo in lo_arr[2]
                course_ID = lo_arr[1]
                lo_ID = lo.id
                lo_name = lo.name
                lo_desc = lo.description
                lo_prereq = "\""
                for requesite in lo.requisites
                    lo_prereq = lo_prereq*string(requesite[1]) * ";"
                end
                lo_prereq = chop(lo_prereq)
                if length(lo_prereq) > 0
                   lo_prereq = lo_prereq * "\""
                end
                lo_hours = lo.hours
                lo_line = "\n" * string(course_ID) * "," * string(lo_ID) * ",\"" * string(lo_name) * "\",\"" * string(lo_desc) * "\",\"" *
                                string(lo_prereq) * "\"," * string(lo_hours) * ",,,,,"
                
                write(csv_file, lo_line) 
            end
        end
    end
    if length(curric.learning_outcomes) > 0
        write(csv_file, "\nCurriculum Learning Outcomes,,,,,,,,,,") 
        write(csv_file, "\nLearning Outcome,Description,,,,,,,,,") 
        for lo in curric.learning_outcomes
            lo_name = lo.name
            lo_desc = lo.description
            lo_line = "\n\"" * string(lo_name) *"\",\""* string(lo_desc) * "\",,,,,,,,,"
            write(csv_file, lo_line) 
        end 
    end
end

"""
    read_csv(file_path::AbstractString)

Read (i.e., deserialize) a CSV file containing either a curriculum or a degree plan, and returns a corresponding
`Curriculum` or `DegreePlan` data object.  The required format for curriculum or degree plan CSV files is 
described in [File Format](@ref).

# Arguments
- `file_path::AbstractString` : the relative or absolute path to the CSV file.

# Examples:
```julia-repl
julia> c = read_csv("./mydata/UBW_curric.csv")
julia> dp = read_csv("./mydata/UBW_plan.csv")
```
"""
function read_csv(file_path::AbstractString)
    file_path = remove_empty_lines(file_path)
    if typeof(file_path) == Bool && !file_path
        return false
    end
    dict_curric_degree_type = Dict("AA"=>AA, "AS"=>AS, "AAS"=>AAS, "BA"=>BA, "BS"=>BS, ""=>BS)
    dict_curric_system = Dict("semester"=>semester, "quarter"=>quarter, ""=>semester)
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
    output = ""
    open(file_path) do csv_file        
        read_line = csv_line_reader(readline(csv_file), ',')
        courses_header += 1
        if read_line[1] == "Curriculum"
            curric_name = read_line[2]
            read_line = csv_line_reader(readline(csv_file), ',')
            is_dp = read_line[1] == "Degree Plan"
            if is_dp 
                dp_name = read_line[2]
                read_line = csv_line_reader(readline(csv_file), ',')
                courses_header += 1
            end
            if read_line[1] == "Institution"
                curric_inst = read_line[2]
                read_line = csv_line_reader(readline(csv_file), ',')
                courses_header += 1
            end
            if read_line[1] == "Degree Type"
                curric_dtype = dict_curric_degree_type[read_line[2]]
                read_line = csv_line_reader(readline(csv_file), ',')
                courses_header += 1
            end
            if read_line[1] == "System Type"
                curric_stype = dict_curric_system[read_line[2]]
                read_line = csv_line_reader(readline(csv_file), ',')
                courses_header += 1
            end
            if read_line[1] == "CIP"
                curric_CIP = read_line[2]
                read_line = csv_line_reader(readline(csv_file), ',')
                courses_header += 1
            end
            if read_line[1] == "Courses"
                courses_header += 1 
            else
                println("Could not find Courses")
                return false
            end         
            
        else 
            println("Could not find a Curriculum")
            return false
        end
        read_line = csv_line_reader(readline(csv_file), ',')
        while length(read_line) > 0 && read_line[1] != "Additional Courses" && read_line[1] != "Course Learning Outcomes" && 
                        read_line[1] != "Curriculum Learning Outcomes" && !startswith(read_line[1], "#")
            if length(read_line[1]) == 0
                println("All courses must have a Course ID")
                return false
            end
            course_count += 1
            read_line = csv_line_reader(readline(csv_file), ',')
        end
        df_courses = CSV.File(file_path, header=courses_header, limit=course_count-1) |> DataFrame
        if nrow(df_courses) != nrow(unique(df_courses, Symbol("Course ID")))
            println("All courses must have a unique Course ID")
            return false
        end
        if !is_dp && Symbol("Term") in names(df_courses)
            println("Curriculum cannot have term information.")
            return false
        end
        df_all_courses = DataFrame()
        df_additional_courses = DataFrame()
        if length(read_line) > 0 && read_line[1] == "Additional Courses"
            if !is_dp 
                println("Only Degree Plan can have additional classes") 
                return false
            end
            additional_course_start = courses_header+course_count+1
            read_line = csv_line_reader(readline(csv_file), ',')
            while length(read_line) > 0 && read_line[1] != "Course Learning Outcomes" && 
                read_line[1] != "Curriculum Learning Outcomes" && !startswith(read_line[1], "#")
                additional_course_count += 1
                read_line = csv_line_reader(readline(csv_file), ',')
            end     
        end
        if additional_course_count > 1
            df_additional_courses = CSV.File(file_path, header=additional_course_start, limit=additional_course_count-1) |> DataFrame
            df_all_courses = vcat(df_courses,df_additional_courses)
        else
            df_all_courses = df_courses
        end
        
        if is_dp && any(ismissing.(df_all_courses[Symbol("Term")]))
            println("All courses in Degree Plan must have Term information")
            return false
        end  
        df_course_learning_outcomes=""
        if length(read_line)>0 && read_line[1] == "Course Learning Outcomes"
            learning_outcomes_start = additional_course_start+additional_course_count+1
            read_line = csv_line_reader(readline(csv_file), ',')
            while length(read_line)>0 && !startswith(read_line[1],"#")  && read_line[1] != "Curriculum Learning Outcomes"
                learning_outcomes_count +=1
                read_line = csv_line_reader(readline(csv_file), ',')
            end  
            if learning_outcomes_count > 1
                df_course_learning_outcomes = CSV.File(file_path, header=learning_outcomes_start, limit=learning_outcomes_count-1) |> DataFrame
            end
        end    
        course_learning_outcomes = Dict{Int, Array{LearningOutcome}}()
        if df_course_learning_outcomes != "" 
            course_learning_outcomes = generate_course_lo(df_course_learning_outcomes)
            if typeof(course_learning_outcomes) == Bool && !course_learning_outcomes
                return false
            end
        end
        
        df_curric_learning_outcomes = ""
        if length(read_line)>0 && read_line[1] == "Curriculum Learning Outcomes"
            curric_learning_outcomes_start = learning_outcomes_start+learning_outcomes_count+1
            read_line = csv_line_reader(readline(csv_file), ',')
            while length(read_line)>0 && !startswith(read_line[1],"#")
                curric_learning_outcomes_count +=1
                read_line = csv_line_reader(readline(csv_file), ',')
            end            
            if learning_outcomes_count > 1
                df_curric_learning_outcomes = CSV.File(file_path, header=curric_learning_outcomes_start, limit=curric_learning_outcomes_count-1) |> DataFrame
            end
        end  
        
        curric_learning_outcomes = if df_curric_learning_outcomes != "" generate_curric_lo(df_curric_learning_outcomes) else LearningOutcome[] end

        if is_dp
            all_courses = read_all_courses(df_all_courses,course_learning_outcomes)
            if typeof(all_courses) == Bool && !all_courses
                return false
            end
            all_courses_arr = [course[2] for course in all_courses]
            additional_courses = read_courses(df_additional_courses,all_courses)  
            ac_arr = Course[]
            for course in additional_courses
                push!(ac_arr, course[2])
            end

            curric = Curriculum(curric_name, all_courses_arr, learning_outcomes = curric_learning_outcomes, degree_type= curric_dtype,
                                system_type=curric_stype, institution=curric_inst, CIP=curric_CIP)
            terms = read_terms(df_all_courses, all_courses, curric.courses)
            terms_arr = Array{Term}(undef, length(terms))
            for term in terms
                terms_arr[term[1]]=Term([class for class in term[2]])
            end

            degree_plan = DegreePlan(dp_name, curric, terms_arr, ac_arr)
            output = degree_plan
        else
            curric_courses = read_all_courses(df_courses, course_learning_outcomes)
            if typeof(curric_courses) == Bool && !curric_courses
                return false
            end
            curric_courses_arr = [course[2] for course in curric_courses] 
            curric = Curriculum(curric_name, curric_courses_arr, learning_outcomes = curric_learning_outcomes, degree_type= curric_dtype,
                                    system_type=curric_stype, institution=curric_inst, CIP=curric_CIP)
            output = curric            
        end
    end
    # Current file is the temp file created by remove_empty_lines(), remove the file.
    if file_path[end-8:end] == "_temp.csv"
        GC.gc()
        rm(file_path)
    end
    return output

end

"""
    write_csv(c::Curriculum, file_path::AbstractString)

Write (i.e., serialize) a `Curriculum` data object to disk as a CSV file. To read 
(i.e., deserialize) a curriculum CSV file, use the corresponding `read_csv` function.
The file format used to store curricula is described in [File Format](@ref).

# Arguments
- `c::Curriculum` : the `Curriculum` data object to be serialized.
- `file_path::AbstractString` : the absolute or relative path where the CSV file will be stored.

# Examples:
```julia-repl
julia> write_csv(c, "./mydata/UBW_curric.csv")
```
"""
function write_csv(curric::Curriculum, file_path::AbstractString)
    dict_curric_degree_type = Dict(AA=>"AA", AS=>"AS", AAS=>"AAS", BA=>"BA", BS=>"BS")
    dict_curric_system = Dict(semester=>"semester", quarter=>"quarter")
    open(file_path, "w") do csv_file
        # Write Curriculum Name
        curric_name = "Curriculum," * string(curric.name) * ",,,,,,,,,"
        write(csv_file, curric_name)

        # Write Institution Name
        curric_ins = "\nInstitution," * string(curric.institution) * ",,,,,,,,,"
        write(csv_file, curric_ins)

        # Write Degree Type
        curric_dtype="\nDegree Type," * string(dict_curric_degree_type[curric.degree_type]) * ",,,,,,,,,"
        write(csv_file, curric_dtype)

        # Write System Type (Semester or Quarter)
        curric_stype="\nSystem Type," * string(dict_curric_system[curric.system_type]) * ",,,,,,,,,"
        write(csv_file, curric_stype)

        # Write CIP Code
        curric_CIP="\nCIP," * string(curric.CIP) * ",,,,,,,,,"
        write(csv_file, curric_CIP)

        # Define the course header, 10 columns of data for each course
        course_header="\nCourse ID,Course Name,Prefix,Number,Prerequisites,Corequisites,Strict-Corequisites,Credit Hours,Institution,Canonical Name"
        # Write Course Section and Course Header
        write(csv_file, "\nCourses,,,,,,,,,,") 
        write(csv_file, course_header) 

        # Define dict to store all course learning outcomes
        all_course_lo = Dict{Int,Array{LearningOutcome,1}}()
        # Iterate through each course in the curriculum
        for course in curric.courses
            # Write the current course to the CSV
            write(csv_file, course_line(course,""))
            # Check if the course has learning outcomes, if it does store them
            if length(course.learning_outcomes) > 0
                all_course_lo[course.id] = course.learning_outcomes
            end
        end
        
        # Write course and curriculum learning outcomes, if any
        write_learning_outcomes(curric, csv_file, all_course_lo)
    end
    return true
end

# TODO - Reduce duplicated code between this and the curriculum version of the function
"""
    write_csv(dp::DegreePlan, file_path::AbstractString)

Write (i.e., serialize) a `DegreePlan` data object to disk as a CSV file. To read 
(i.e., deserialize) a degree plan CSV file, use the corresponding `read_csv` function.
The file format used to store degree plans is described in [File Format](@ref).

# Arguments
- `dp::DegreePlan` : the `DegreePlan` data object to be serialized.
- `file_path::AbstractString` : the absolute or relative path where the CSV file will be stored. 

# Examples:
```julia-repl
julia> write_csv(dp, "./mydata/UBW_plan.csv")
```
"""
function write_csv(original_plan::DegreePlan, file_path::AbstractString)
    dict_curric_degree_type = Dict(AA=>"AA", AS=>"AS", AAS=>"AAS", BA=>"BA", BS=>"BS")
    dict_curric_system = Dict(semester=>"semester", quarter=>"quarter")
    open(file_path, "w") do csv_file
        # Grab a copy of the curriculum
        curric = original_plan.curriculum
        
        # Write Curriculum Name
        curric_name = "Curriculum," * "\""*string(curric.name) *"\""* ",,,,,,,,,"
        write(csv_file, curric_name)
        
        # Write Degree Plan Name
        dp_name = "\nDegree Plan," * "\""*string(original_plan.name) *"\""* ",,,,,,,,,"
        write(csv_file, dp_name)

        # Write Institution Name
        curric_ins = "\nInstitution," * "\""*string(curric.institution) *"\""* ",,,,,,,,,"
        write(csv_file, curric_ins) 

        # Write Degree Type
        curric_dtype = "\nDegree Type," *"\""* string(dict_curric_degree_type[curric.degree_type]) * "\""*",,,,,,,,,"
        write(csv_file,curric_dtype) 

        # Write System Type (Semester or Quarter)
        curric_stype = "\nSystem Type," * "\""*string(dict_curric_system[curric.system_type]) * "\""*",,,,,,,,,"
        write(csv_file, curric_stype) 
        
        # Write CIP Code
        curric_CIP = "\nCIP," * "\""*string(curric.CIP) * "\""*",,,,,,,,,"
        write(csv_file, curric_CIP)

        # Define the course header, 11 columns of data for each course
        course_header = "\nCourse ID,Course Name,Prefix,Number,Prerequisites,Corequisites,Strict-Corequisites,Credit Hours,Institution,Canonical Name,Term"
        # Write Course Section and Course Header
        write(csv_file, "\nCourses,,,,,,,,,,") 
        write(csv_file, course_header) 

        # Iterate through each term and each course in the term and write them to the degree plan
        for (term_id, term) in enumerate(original_plan.terms)
            for course in term.courses
                if !isdefined(original_plan, :additional_courses) || !find_courses(original_plan.additional_courses, course.id)
                    write(csv_file, course_line(course, term_id)) 
                end
            end
        end

        # Define dict to store all course learning outcomes
        all_course_lo = Dict{Int, Array{LearningOutcome, 1}}()
        # Check if the original plan has additional courses defined
        if isdefined(original_plan, :additional_courses)
            # Write the additional courses section of the CSV
            write(csv_file, "\nAdditional Courses,,,,,,,,,,")
            write(csv_file, course_header) 
            # Iterate through each term
            for (term_id, term) in enumerate(original_plan.terms)
                # Iterate through each course in the current term
                for course in term.courses
                    # Check if the current course is an additional course, if so, write it here
                    if find_courses(original_plan.additional_courses, course.id)
                        write(csv_file, course_line(course, term_id)) 
                    end
                    # Check if the current course has learning outcomes, if so store them
                    if length(course.learning_outcomes) > 0
                        all_course_lo[course.id] = course.learning_outcomes
                    end
                end
            end
        end

        # Write course and curriculum learning outcomes, if any
        write_learning_outcomes(curric, csv_file, all_course_lo)        
    end
    return true
end