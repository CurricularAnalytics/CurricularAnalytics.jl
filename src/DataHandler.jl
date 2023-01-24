# ==============================
# CSV Read / Write Functionality
# ==============================
using CSV
using DataFrames
include("CSVUtilities.jl")

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
    # dict_curric_degree_type = Dict("AA"=>AA, "AS"=>AS, "AAS"=>AAS, "BA"=>BA, "BS"=>BS, ""=>BS)
    dict_curric_system = Dict("semester"=>semester, "quarter"=>quarter, ""=>semester)
    dp_name = ""
    dp_add_courses = Array{Course,1}()
    curric_name = ""
    curric_inst = ""
    curric_dtype = "BS"
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
    # Open the CSV file and read in the basic information such as the type (curric or degreeplan), institution, degree type, etc 
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
                curric_dtype = read_line[2]
                read_line = csv_line_reader(readline(csv_file), ',')
                courses_header += 1
            end
            if read_line[1] == "System Type"
                curric_stype = dict_curric_system[lowercase(read_line[2])]
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
        
        # File isn't formatted correctly, couldn't find the curriculum field in Col A Row 1
        else 
            println("Could not find a Curriculum")
            return false
        end

        # This is the row containing Course ID, Course Name, Prefix, etc
        read_line = csv_line_reader(readline(csv_file), ',')
        
        # Checks that all courses have an ID, and counts the total number of courses
        while length(read_line) > 0 && read_line[1] != "Additional Courses" && read_line[1] != "Course Learning Outcomes" && 
                    read_line[1] != "Curriculum Learning Outcomes" && !startswith(read_line[1], "#")

            # Enforce that each course has an ID
            if length(read_line[1]) == 0
                if !any(x -> x != "", read_line)
                    read_line = csv_line_reader(readline(csv_file), ',')
                    continue
                end
                println("All courses must have a Course ID (1)")
                return false
            end

            # Enforce that each course has an associated term if the file is a degree plan
            if (is_dp)
                if (length(read_line) == 10)
                    error("Each Course in a Degree Plan must have an associated term." * 
                            "\nCourse with ID \'$(read_line[1])\' ($(read_line[2])) has no term.")
                    return false
                elseif (read_line[11] == 0)
                    error("Each Course in a Degree Plan must have an associated term." * 
                            "\nCourse with ID \'$(read_line[1])\' ($(read_line[2])) has no term.")
                    return false
                end
            end

            course_count += 1
            read_line = csv_line_reader(readline(csv_file), ',')
        end

        df_courses = CSV.File(file_path, header = courses_header, limit = course_count - 1, delim = ',', silencewarnings = true) |> DataFrame
        if nrow(df_courses) != nrow(unique(df_courses, Symbol("Course ID")))
            println("All courses must have a unique Course ID (2)")
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
                println("Only Degree Plan can have additional courses") 
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
            df_additional_courses = CSV.File(file_path, header = additional_course_start, limit = additional_course_count - 1, delim = ',', silencewarnings = true) |> DataFrame
            df_all_courses = vcat(df_courses,df_additional_courses)
        else
            df_all_courses = df_courses
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
                df_course_learning_outcomes = CSV.File(file_path, header = learning_outcomes_start, limit = learning_outcomes_count - 1, delim = ',', silencewarnings = true) |> DataFrame
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
                df_curric_learning_outcomes = CSV.File(file_path, header = curric_learning_outcomes_start, limit = curric_learning_outcomes_count - 1, delim = ',', silencewarnings = true) |> DataFrame
            end
        end  
        
        curric_learning_outcomes = if df_curric_learning_outcomes != "" generate_curric_lo(df_curric_learning_outcomes) else LearningOutcome[] end

        if is_dp
            all_courses = read_all_courses(df_all_courses, course_learning_outcomes)
            if typeof(all_courses) == Bool && !all_courses
                return false
            end
            all_courses_arr = [course[2] for course in all_courses]
            additional_courses = read_courses(df_additional_courses, all_courses)  
            ac_arr = Course[]
            for course in additional_courses
                push!(ac_arr, course[2])
            end
            curric = Curriculum(curric_name, all_courses_arr, learning_outcomes = curric_learning_outcomes, degree_type = curric_dtype,
                                    system_type=curric_stype, institution=curric_inst, CIP=curric_CIP)
            terms = read_terms(df_all_courses, all_courses, all_courses_arr)
            #If some courses has term informations but some does not
            if isa(terms, Tuple)
                #Add curriculum to the output tuple
                output = (terms..., curric, dp_name, ac_arr) # ... operator enumrates the terms
            else
                degree_plan = DegreePlan(dp_name, curric, terms, ac_arr)
                output = degree_plan
            end
        else
            curric_courses = read_all_courses(df_courses, course_learning_outcomes)
            if typeof(curric_courses) == Bool && !curric_courses
                return false
            end
            curric_courses_arr = [course[2] for course in curric_courses] 
            curric = Curriculum(curric_name, curric_courses_arr, learning_outcomes = curric_learning_outcomes, degree_type = curric_dtype,
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

function read_csv_new(file_path::AbstractString)
    println("Reading CSV file: ", file_path)
    # Here we read in the header of the file, which is at most 6 lines long.
    # The columns are transposed, and they are: Curriculum, (Degree Plan?), Institution, Degree Type, System Type, CIP
    # Since we transpose, we technically only read in the first row.
    # We then check if the first 6 columns are the correct header and whether we're dealing with a Curriculum or Degree Plan.
    header = CSV.File(file_path; header=true, limit=1, ignoreemptylines=true, select=[1,2,3,4,5,6], transpose=true) |> DataFrame
    if names(header)[1] == "Curriculum" && names(header)[2] == "Institution" && names(header)[3] == "Degree Type" && names(header)[4] == "System Type" && names(header)[5] == "CIP"
        name = header[1,1]
        typeof(header[1,2]) === Missing ? curric_inst = "" : curric_inst = header[1,2]
        curric_dtype = header[1,3]
        curric_stype = lowercase(string(header[1,4]))
        curric_stype = if curric_stype == "quarter"
            CurricularAnalytics.quarter
        else
            CurricularAnalytics.semester
        end
        curric_cip = string(header[1,5])

        courses = CSV.File(file_path; header=7, silencewarnings=true, normalizenames=true)
        courses[]
        c_courses = Dict{Int, Course}()

        # Here we build all of the Course objects and put them into a dictionary with the course id as the key        
        for c in courses
            # println(c)
            c_name = c.Course_Name
            credit_hours = c.Credit_Hours
            typeof(c.Prefix) === Missing ? prefix = "" : prefix = string(c.Prefix)
            typeof(c.Number) === Missing ? num = "" : num = string(c.Number)
            typeof(c.Institution) === Missing ? institution = "" : institution = c.Institution
            typeof(c.Canonical_Name) === Missing ? canonical_name = "" : canonical_name = c.Canonical_Name
            c_id = c.Course_ID

            course = Course(c_name, credit_hours, prefix=prefix, num=num, institution=institution, canonical_name=canonical_name, id=c_id)
            c_courses[c_id] = course
        end

        # Next, we need to construct the requisites for each course.
        for c in courses
            # Check if the prerequisites column is empty
            if c.Prerequisites !== missing
                if typeof(c.Prerequisites) == String
                    prereqs = split(c.Prerequisites, ";") # Split the prerequisites into a list
                    for req in prereqs
                        try
                            add_requisite!(c_courses[parse(Int, req)], c_courses[c.Course_ID], pre) # Add the requisite to the course
                        catch
                            ""
                        end
                    end
                elseif typeof(c.Prerequisites) == Int
                    add_requisite!(c_courses[c.Prerequisites], c_courses[c.Course_ID], pre)
                end
            end
            # Check if the corequisites column is empty
            if c.Corequisites !== missing
                if typeof(c.Corequisites) == String
                    coreqs = split(c.Corequisites, ";") # Split the corequisites into a list
                    for req in coreqs
                        try
                            add_requisite!(c_courses[parse(Int, req)], c_courses[c.Course_ID], co) # Add the requisite to the course
                        catch
                            ""
                        end
                    end
                elseif typeof(c.Corequisites) == Int
                    add_requisite!(c_courses[c.Corequisites], c_courses[c.Course_ID], co)
                end
            end
            # Check if the Strict_Corequisites column is empty
            if c.Strict_Corequisites !== missing
                if typeof(c.Strict_Corequisites) == String
                    strict_coreqs = split(c.Strict_Corequisites, ";") # Split the strict corequisites into a list
                    for req in strict_coreqs
                        try
                            add_requisite!(c_courses[parse(Int, req)], c_courses[c.Course_ID], strict_co) # Add the requisite to the course
                        catch
                            ""
                        end
                    end
                elseif typeof(c.Strict_Corequisites) == Int
                    add_requisite!(c_courses[c.Strict_Corequisites], c_courses[c.Course_ID], strict_co)
                end
            end
        end

        # convert the dictionary of courses to a vector of courses
        c_courses = collect(values(c_courses))

        curric = Curriculum(name, c_courses, degree_type=curric_dtype,
                                    system_type=curric_stype, institution=curric_inst, CIP=curric_cip)
        return curric
    
    elseif names(header)[1] == "Curriculum" && names(header)[2] == "Degree Plan" && names(header)[3] == "Institution" && names(header)[4] == "Degree Type" && names(header)[5] == "System Type" && names(header)[6] == "CIP"
        courses = CSV.File(file_path; header=8, silencewarnings=true) |> DataFrame
        print(courses)
        if "Additional Courses" in courses[!,1] # If there is an additional courses portion of this degree plan
            additional_courses_index = findall(occursin.("Additional Courses", courses["Course Name"])) # Get the index of where additional courses start
            println(additional_courses_index)
            # Create a new dataframe with only the additional courses (from additional_courses_index[0] to the end of the file)
        end
    
    else
        error("This is an invalid CSV format. Please see the example file and be sure not to modify the headers.")
        return false
    end
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
function write_csv(curric::Curriculum, file_path::AbstractString; iostream=false, metrics=false)
    if iostream == true
        csv_file = IOBuffer()
        write_csv_content(csv_file, curric, false, metrics=metrics)
        return csv_file
    else
        open(file_path, "w") do csv_file
            write_csv_content(csv_file, curric, false, metrics=metrics)
        end
        return true
    end
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
function write_csv(original_plan::DegreePlan, file_path::AbstractString; iostream=false, metrics=false)
    if iostream
        csv_file = IOBuffer()
        write_csv_content(csv_file, original_plan, true, metrics=metrics)
    else  
        open(file_path, "w") do csv_file
            write_csv_content(csv_file, original_plan, true, metrics=metrics)
        end
        return true
    end
end


function write_csv_content(csv_file, program, is_degree_plan; metrics=false)
    # dict_curric_degree_type = Dict(AA=>"AA", AS=>"AS", AAS=>"AAS", BA=>"BA", BS=>"BS")
    dict_curric_system = Dict(semester=>"semester", quarter=>"quarter")
    # Write Curriculum Name
    if is_degree_plan
        # Grab a copy of the curriculum
        curric = program.curriculum
        curric_name = "Curriculum," * "\""*string(curric.name) *"\""* ",,,,,,,,,"
    else
        curric = program
        curric_name = "Curriculum," * string(curric.name) * ",,,,,,,,,"
    end
    write(csv_file, curric_name)
    
    # Write Degree Plan Name
    if is_degree_plan
        dp_name = "\nDegree Plan," * "\""*string(program.name) *"\""* ",,,,,,,,,"
        write(csv_file, dp_name)
    end

    # Write Institution Name
    curric_ins = "\nInstitution," * "\""*string(curric.institution) *"\""* ",,,,,,,,,"
    write(csv_file, curric_ins) 

    # Write Degree Type
    curric_dtype = "\nDegree Type," *"\""* string(curric.degree_type) * "\""*",,,,,,,,,"
    write(csv_file,curric_dtype) 

    # Write System Type (Semester or Quarter)
    curric_stype = "\nSystem Type," * "\""*string(dict_curric_system[curric.system_type]) * "\""*",,,,,,,,,"
    write(csv_file, curric_stype) 
    
    # Write CIP Code
    curric_CIP = "\nCIP," * "\""*string(curric.CIP) * "\""*",,,,,,,,,"
    write(csv_file, curric_CIP)
    
    # Define course header
    if is_degree_plan
        if metrics
            course_header="\nCourse ID,Course Name,Prefix,Number,Prerequisites,Corequisites,Strict-Corequisites,Credit Hours,Institution,Canonical Name,Term,Complexity,Blocking,Delay,Centrality"
        else
            # 11 cols for degree plans (including term)
            course_header = "\nCourse ID,Course Name,Prefix,Number,Prerequisites,Corequisites,Strict-Corequisites,Credit Hours,Institution,Canonical Name,Term"
        end
    else
        if metrics
            course_header="\nCourse ID,Course Name,Prefix,Number,Prerequisites,Corequisites,Strict-Corequisites,Credit Hours,Institution,Canonical Name,Complexity,Blocking,Delay,Centrality"
        else
            # 10 cols for curricula (no term)
            course_header="\nCourse ID,Course Name,Prefix,Number,Prerequisites,Corequisites,Strict-Corequisites,Credit Hours,Institution,Canonical Name"
        end
    end
    write(csv_file, "\nCourses,,,,,,,,,,") 
    write(csv_file, course_header) 

    # Define dict to store all course learning outcomes
    all_course_lo = Dict{Int, Array{LearningOutcome, 1}}()
    
    # if metrics is true ensure that all values are present before writing courses
    if metrics
        complexity(curric)
        blocking_factor(curric)
        delay_factor(curric)
        centrality(curric)
    end

    # write courses (and additional courses for degree plan)
    if is_degree_plan
        # Iterate through each term and each course in the term and write them to the degree plan
        for (term_id, term) in enumerate(program.terms)
            for course in term.courses
                if !isdefined(program, :additional_courses) || !find_courses(program.additional_courses, course.id)
                    write(csv_file, course_line(course, term_id, metrics = metrics)) 
                end
            end
        end
        # Check if the original plan has additional courses defined
        if isdefined(program, :additional_courses)
            # Write the additional courses section of the CSV
            write(csv_file, "\nAdditional Courses,,,,,,,,,,")
            write(csv_file, course_header) 
            # Iterate through each term
            for (term_id, term) in enumerate(program.terms)
                # Iterate through each course in the current term
                for course in term.courses
                    # Check if the current course is an additional course, if so, write it here
                    if find_courses(program.additional_courses, course.id)
                        write(csv_file, course_line(course, term_id, metrics = metrics)) 
                    end
                    # Check if the current course has learning outcomes, if so store them
                    if length(course.learning_outcomes) > 0
                        all_course_lo[course.id] = course.learning_outcomes
                    end
                end
            end
        end
    else
    # Iterate through each course in the curriculum
        for course in curric.courses
            # Write the current course to the CSV
            write(csv_file, course_line(course, "", metrics = metrics))
            # Check if the course has learning outcomes, if it does store them
            if length(course.learning_outcomes) > 0
                all_course_lo[course.id] = course.learning_outcomes
            end
        end
    end

    # Write course and curriculum learning outcomes, if any
    write_learning_outcomes(curric, csv_file, all_course_lo) 
end