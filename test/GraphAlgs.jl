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
@test nv(g) == 12
@test ne(g) == 7

# test dfs
rtn = dfs(g);
@test rtn[1][Edge(2,5)] == tree_edge
@test rtn[1][Edge(2,6)] == tree_edge
@test rtn[1][Edge(6,10)] == tree_edge
@test rtn[1][Edge(4,2)] == cross_edge
@test rtn[1][Edge(7,8)] == tree_edge
@test rtn[1][Edge(7,11)] == tree_edge
@test rtn[1][Edge(2,3)] == tree_edge

# topological sort w/ no ordering by component size
@test topological_sort(g) == [[1], [4, 2, 6, 10, 5, 3], [7, 11, 8], [9], [12]]
# topological sort w/ ordering by component size in descenting order
@test topological_sort(g, sort = "descending") == [[4, 2, 6, 10, 5, 3], [7, 11, 8], [1], [9], [12]]
# topological sort w/ ordering by component size in ascending order
@test topological_sort(g, sort = "ascending") == [[1], [9], [12], [7, 11, 8], [4, 2, 6, 10, 5, 3]]

# test gad()
t = gad(g);
@test has_edge(t, 2, 3) == false
@test has_edge(t, 3, 2) == true
@test has_edge(t, 5, 2) == true
@test has_edge(t, 6, 2) == true
@test has_edge(t, 2, 4) == true
@test has_edge(t, 10, 6) == true
@test has_edge(t, 8, 7) == true
@test has_edge(t, 11, 7) == true

# test reachable_from()
@test sort!(reachable_from(g, 2)) == [3, 5, 6, 10]

# test reachable_from_subgraph()
rg = reachable_from_subgraph(g, 2);
@test nv(rg[1]) == 5
@test ne(rg[1]) == 4
@test sort!(rg[2]) == [2, 3, 5, 6, 10]

# test reachable_to()
@test sort!(reachable_to(g, 2)) == [4]

# test reachable_to_subgraph()
rt = reachable_to_subgraph(g, 2);
@test nv(rt[1]) == 2
@test ne(rt[1]) == 1
@test sort!(rt[2]) == [2, 4]

# test reach()
@test sort!(reach(g, 2)) == [3, 4, 5, 6, 10]

# test reach_subgraph()
r = reach_subgraph(g, 2);
@test nv(r[1]) == 6
@test ne(r[1]) == 5
@test sort!(r[2]) == [2, 3, 4, 5, 6, 10]

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