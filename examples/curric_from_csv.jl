using CurricularAnalytics
"""
In order to run this example follow these steps:
    1- Enter the package manager and run "activate ."
    2- In REPL mode run these lines:
        module test
            ARGS = ["examples/UH_EE.csv"]
            include("examples/curric_from_csv.jl")
        end
        On Windows:
        module test
           ARGS = ["examples\\UH_EE.csv"]
           include("examples\\curric_from_csv.jl")
       end
        
"""

println("Reading csv file: " * ARGS[1])
csv_to_json(ARGS[1], "recent-visualization.json")
dp = read_degree_plan("recent-visualization.json")
curric = dp.curriculum

errors = IOBuffer()
if isvalid_curriculum(curric, errors)
    println("Curriculum $(curric.name) is valid")
    println("  delay factor = $(delay_factor(curric))")
    println("  blocking factor = $(blocking_factor(curric))")
    println("  centrality factor = $(centrality(curric))")
    println("  curricular complexity = $(complexity(curric))")
	
    take!(errors) # clear the IO buffer
    if isvalid_degree_plan(dp, errors)
        println("Degree plan $(dp.name) is valid")
    else
        println("Degree plan $(dp.name) is not valid:")
        print(String(take!(errors)))
        println("\nDiplaying degree plan for debugging purposes...")
    end
    visualize(dp)

else # invalid curriculum
    println("Curriculum $(curric.name) is not valid:")
    print(String(take!(errors)))
end
