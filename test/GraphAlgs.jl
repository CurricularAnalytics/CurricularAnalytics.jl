# Graph Algs tests

using LightGraphs

@testset "GraphAlgs Tests" begin

# 12-vertex test diagraph with 5 components 
g = SimpleDiGraph(12) 
add_edge!(g, 2, 3)
add_edge!(g, 2, 5)
add_edge!(g, 2, 6)
add_edge!(g, 4, 2)
add_edge!(g, 6, 10)
add_edge!(g, 7, 8)
add_edge!(g, 7, 11)

# topological sort w/ no ordering by component size
@test topological_sort(g) == [[1], [4, 2, 6, 10, 5, 3], [7, 11, 8], [9], [12]]
# topological sort w/ ordering by component size in descenting order
@test topological_sort(g, sort = "descending") == [[4, 2, 6, 10, 5, 3], [7, 11, 8], [1], [9], [12]]
# topological sort w/ ordering by component size in ascending order
@test topological_sort(g, sort = "ascending") == [[1], [9], [12], [7, 11, 8], [4, 2, 6, 10, 5, 3]]

#test all_paths()
paths = all_paths(g)
@test length(paths) == 5
@test [4, 2, 3] in paths
@test [4, 2, 5] in paths
@test [7, 8] in paths      
@test [4, 2, 6, 10] in paths
@test [7, 11] in paths

#test longest path algorithms
@test longest_path(g, 2) == [2, 6, 10]
@test longest_paths(g) == [[4, 2, 6, 10]]

end;