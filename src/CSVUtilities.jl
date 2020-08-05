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
        course_prereq = course_prereq * "\""
    end
    course_coreq = chop(course_coreq)
    if length(course_coreq) > 0
        course_coreq = course_coreq * "\""
    end
    course_scoreq = chop(course_scoreq)
    if length(course_scoreq) > 0
        course_scoreq = course_scoreq * "\""
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
    if !(string(header) in names(row)) #I assume this means if header is not in names 
        error("$(header) column is missing")
    elseif typeof(row[header]) == Missing
        return ""
    else
        return row[header]
    end
end

function read_all_courses(df_courses::DataFrame, lo_Course:: Dict{Int, Array{LearningOutcome}}=Dict{Int, Array{LearningOutcome}}())
    course_dict = Dict{Int, Course}()
    for row in DataFrames.eachrow(df_courses)
        c_ID = row[Symbol("Course ID")]
        c_Name = find_cell(row, Symbol("Course Name"))
        c_Credit = row[Symbol("Credit Hours")] 
        c_Credit = typeof(c_Credit) == String ? parse(Float64, c_Credit) : c_Credit
        c_Prefix = string(find_cell(row, Symbol("Prefix")))
        c_Number = find_cell(row, Symbol("Number"))
        if typeof(c_Number) != String 
            c_Number = string(c_Number) 
        end
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

function read_terms(df_courses::DataFrame, course_dict::Dict{Int, Course}, course_arr::Array{Course,1})
    terms = Dict{Int, Array{Course}}()
    have_term = Course[]
    not_have_term = Course[]
    for row in DataFrames.eachrow(df_courses)
        c_ID = find_cell(row, Symbol("Course ID"))
        term_ID = find_cell(row, Symbol("Term"))
        for course in course_arr
            if course_dict[c_ID].id == course.id                #This could be simplified with logic 
                if typeof(row[Symbol("Term")]) != Missing       #operations rather than four if statemnts
                    push!(have_term, course)
                    if term_ID in keys(terms)
                        push!(terms[term_ID], course) 
                    else
                        terms[term_ID] = [course]
                    end
                else
                    push!(not_have_term, course)
                end
                break
            end            
        end        
    end  
    terms_arr = Array{Term}(undef, length(terms))
    for term in terms
        terms_arr[term[1]] = Term([class for class in term[2]])
    end
    if length(not_have_term) == 0
        return terms_arr
    else
        return terms_arr, have_term, not_have_term
    end
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
                lo_line = "\n" * string(course_ID) * "," * string(lo_ID) * ",\"" * string(lo_name) * "\",\"" * 
                          string(lo_desc) * "\",\"" * string(lo_prereq) * "\"," * string(lo_hours) * ",,,,,"
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