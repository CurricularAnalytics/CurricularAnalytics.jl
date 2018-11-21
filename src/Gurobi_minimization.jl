function optimal_student_schedule(curric, beta, prereq)
    optimal_student_schedule = Model(solver=GurobiSolver())

function check_requistes(curric::Curriculum, index::Int, all_applied_courses::Array{Int}, this_term_applied_courses::Array{Int})
        req_complete = true
        
    #import curriucla file, no time/term included 
  @variable(optimal_student_schedule, 0<= x[link in links] <= u_dict[link])

  @objective(optimal_student_schedule, Min, sum( c_dict[link] * x[link] for link in links)  )



  for i in nodes
    @constraint(optimal_student_schedule, sum(x[(ii,j)] for (ii,j) in links if ii==i )
                    - sum(x[(j,ii)] for (j,ii) in links if ii==i ) == b[i])
  end

  status = solve(optimal_student_schedule)
  obj = getobjectivevalue(optimal_student_schedule)
 

  return  obj, status
end

using JuMP, Gurobi, DataFrames

# Data Preparation
curric_data_file = "examples/CornellECECources.csv"
curric_data = readcsv(curric_data_file,  header=true)
data = curric_data[1]
header = curric_data[2]

start_node = round.(Int64, data[:,1])
end_node = round.(Int64, data[:,2])
c = data[:,3]
d = data[:,4]

# find max optimized req path, and set to lowest possible term count 
no_node = max( maximum(start_node), maximum(end_node) )
no_link = length(start_node)

# Creating a graph
nodes = 1:no_node
links = Array{Tuple{Int, Int}}(no_link)
c_dict = Dict()
d_dict = Dict()
for i=1:no_link
  links[i] = (start_node[i], end_node[i])
  c_dict[(start_node[i], end_node[i])] = c[i]
  u_dict[(start_node[i], end_node[i])] = d[i]
end

