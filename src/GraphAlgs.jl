
# File: GraphAlgs.jl

# Depth-first search, returns edge classification using EdgeClass, as well as the discovery and finish time for each vertex.
"""
dfs(g)

Perform a depth-first traversal of input graph `g`.

# Arguments
Required:
- `g::AbstractGraph` : input graph.

This function returns the classification of each edge in graph `g`, as well as the order in which vertices are
first discovered during a depth-first search traversal, and when the processing from that vertex is completed
during the depth-first traverlsa.  According to the vertex discovery and finish times, each edge in `g` will be 
classified as one of:
 - *tree edge* : Any collection of edges in `g` that form a forest. Every vertex is either a single-vertex tree 
 with respect to such a collection, or is part of some larger tree through its connection to another vertex via a 
 tree edge. This collection is not unique defined on `g`.
 - *back edge* : Given a collection of tree edges, back edges are those edges that connect some descendent vertex 
 in a tree to an ancestor vertex in the same tree.
 - *forward edge* : Given a collection of tree edges, forward edges are those that are incident from an ancestor 
 in a tree, and incident to an descendent in the same tree.
 - *cross edge* : Given a collection of tree edges, cross edges are those that are adjacent between vertices in 
 two different trees, or between vertices in two different subtrees in the same tree.

```julia-repl
julia> edges, discover, finish = dfs(g)
```
"""
function dfs(g::AbstractGraph{T}) where T
    time = 0
    # discover and finish times
    d = zeros(Int, nv(g))
    f = zeros(Int, nv(g))
    edge_type = Dict{Edge,EdgeClass}()
    for s in vertices(g)
        if d[s] == 0  # undiscovered
            # a closure, shares variable space w/ outer function
            function dfs_visit(s)
                d[s] = time += 1  # discovered
                for n in neighbors(g, s)
                    if d[n] == 0 # encounted a undiscovered vertex
                        edge_type[Edge(s,n)] = tree_edge
                        dfs_visit(n)
                    elseif f[n] == 0 # encountered a discovered but unfinished vertex
                        edge_type[Edge(s,n)] = back_edge
                    else  # encountered a finished vertex
                        if d[s] < d[n]
                            edge_type[Edge(s,n)] = forward_edge
                        else # d[s] > d[n]
                            edge_type[Edge(s,n)] = cross_edge
                        end
                    end
                end
                f[s] = time += 1  # finished
            end # end closure
            dfs_visit(s)  # call the closure
        end
    end
    return edge_type, d, f
end # end dfs

# In a DFS of a DAG, sorting the vertices according to their finish times in the DFS will yeild a topological sorting of the 
# DAG vertices. 
 """
    topological_sort(g; <keyword arguments>)

Perform a topoloical sort on graph `g`, returning the weakly connected components of the graph, each in topological sort order.
If the `sort` keyword agrument is supplied, the components will be sorted according to their size, in either ascending or 
descending order.  If two or more components have the same size, the one with the smallest vertex ID in the first position of the 
topological sort will appear first.

# Arguments
Required:
- `g::AbstractGraph` : input graph.

Keyword:
- `sort::String` : sort weakly connected components according to their size, allowable 
strings: `ascending`, `descending`.
"""
function topological_sort(g::AbstractGraph{T}; sort::String="") where T
    edges_type, d, f = dfs(g)
    topo_order = sortperm(f, rev=true)
    wcc = weakly_connected_components(g)
    if sort == "descending"
        sort!(wcc, lt = (x,y) -> size(x) != size(y) ? size(x) > size(y) : x[1] < y[1]) # order components by size, if same size, by lower index
    elseif sort == "ascending"
        sort!(wcc, lt = (x,y) -> size(x) != size(y) ? size(x) < size(y) : x[1] < y[1]) # order components by size, if same size, by lower index
    end
    reorder = [] 
    for component in wcc
        sort!(component, lt = (x,y) -> indexin(x, topo_order)[1] < indexin(y, topo_order)[1]) # topological sort within each component 
        for i in component
            push!(reorder, i) # add verteix indicies to the end of the reorder array
        end
    end
    return wcc
end

# transpose of DAG
"""
    gad(g)

Returns the transpose of directed acyclic graph (DAG) `g`, i.e., a DAG identical to `g`, except the direction
of all edges is reversed.  If `g` is not a DAG, and error is thrown.

# Arguments
Required:
- `g::SimpleDiGraph` : input graph.
"""
function gad(g::AbstractGraph{T}) where T
    @assert typeof(g) == SimpleDiGraph{T}
    return SimpleDiGraph(transpose(adjacency_matrix(g)))
end

# The set of all vertices in the graph reachable from vertex s
"""
    reachable_from(g, s)

Returns the the set of all vertices in `g` that are reachable from vertex `s`.

# Arguments
Required:
- `g::AbstractGraph` : acylic input graph. 
- `s::Int` : index of the source vertex in `g`.
"""
function reachable_from(g::AbstractGraph{T}, s::Int, vlist::Array=Array{Int64,1}()) where T
    for v in neighbors(g, s)
        if findfirst(isequal(v), vlist) == nothing  # v is not in vlist
            push!(vlist, v)
        end
        reachable_from(g, v, vlist)
    end
    return vlist
end

# The subgraph induced by vertex s and the vertices reachable from vertex s
"""
    reachable_from_subgraph(g, s)

Returns the subgraph induced by `s` in `g` (i.e., a graph object consisting of vertex 
`s` and all vertices reachable from vertex `s` in`g`), as well as a vector mapping the vertex
IDs in the subgraph to their IDs in the orginal graph `g`.

```julia-rep
    sg, vmap = reachable_from_subgraph(g, s)
````
"""
function reachable_from_subgraph(g::AbstractGraph{T}, s::Int) where T
    vertices = reachable_from(g, s)
    push!(vertices, s)  # add the source vertex to the reachable set
    induced_subgraph(g, vertices)
end

# The set of all vertices in the graph that can reach vertex s
"""
    reachable_to(g, t)

Returns the set of all vertices in `g` that can reach target vertex `t` through any path.

# Arguments
Required:
- `g::AbstractGraph` : acylic input graph. 
- `t::Int` : index of the target vertex in `g`. 
"""
function reachable_to(g::AbstractGraph{T}, t::Int) where T
    reachable_from(gad(g), t)  # vertices reachable from s in the transpose graph
 end

# The subgraph induced by vertex s and the vertices that can reach s
"""
    reachable_to_subgraph(g, t)

Returns a subgraph in `g` consisting of vertex `t` and all vertices that can reach 
vertex `t` in`g`, as well as a vector mapping the vertex IDs in the subgraph to their IDs 
in the orginal graph `g`.

# Arguments
Required:
- `g::AbstractGraph` : acylic graph. 
- `t::Int` : index of the target vertex in `g`. 

```julia-rep
    sg, vmap = reachable_to(g, t)
````
"""
function reachable_to_subgraph(g::AbstractGraph{T}, s::Int) where T
    vertices = reachable_to(g, s)
    push!(vertices, s)  # add the source vertex to the reachable set
    induced_subgraph(g, vertices)
end

# The set of all vertices reachable to and reachable from vertex s
"""
    reach(g, v)

Returns the reach of vertex `v` in `g`, ie., the set of all vertices in `g` that can 
reach vertex `v` and can be reached from `v`.

# Arguments
Required:
- `g::AbstractGraph` : acylic graph. 
- `v::Int` : index of a vertex in `g`. 
"""
function reach(g::AbstractGraph{T}, v::Int) where T
    union(reachable_to(g, v), reachable_from(g, v))
end

# Subgraph induced by the reach of a vertex
"""
    reach_subgraph(g, v)

Returns a subgraph in `g` consisting of vertex `v ` and all vertices that can reach `v`, as 
well as all vertices that `v` can reach.  In addition, a vector is returned that maps the 
vertex IDs in the subgraph to their IDs in the orginal graph `g`.

# Arguments
Required:
- `g::AbstractGraph` : acylic graph. 
- `v::Int` : index of a vertex in `g`. 

```julia-rep
    sg, vmap = reachable_to(g, v)
````
"""
function reach_subgraph(g::AbstractGraph{T}, v::Int) where T
    vertices = reach(g, v)
    push!(vertices, v)  # add the source vertex to the reachable set
    induced_subgraph(g, vertices)
end

# find all paths in a graph
"""
    all_paths(g)

 Enumerate all of the unique paths in acyclic graph `g`, where a path in this case must include a 
 source vertex (a vertex with in-degree zero) and a different sink vertex (a vertex with out-degree 
 zero).  I.e., a path is this case must contain at least two vertices.  This function returns 
 an array of these paths, where each path consists of an array of vertex IDs.

 # Arguments
Required:
- `g::AbstractGraph` : acylic graph. 

```julia-repl
julia> paths = all_paths(g)
```
"""
function all_paths(g::AbstractGraph{T}) where T
    # check that g is acyclic
    if is_cyclic(g)
        error("all_paths(): input graph has cycles")
    end
    que = Queue{Array}()
    paths = Array[]
    sinks = Int[]
    for v in vertices(g)
        if (length(outneighbors(g,v)) == 0) && (length(inneighbors(g,v)) > 0) # consider only sink vertices with a non-zero in-degree
            push!(sinks, v)
        end
    end
    for v in sinks
        enqueue!(que, [v])
        while !isempty(que) # work backwards from sink v to all sources reachable to v in BFS fashion
            x = dequeue!(que)
            for (i, u) in enumerate(inneighbors(g, x[1]))
                if i == 1
                    insert!(x, 1, u)  # prepend vertx u to array x, first neighbor
                else
                    x[1] = u # put new neighbor at the head of array, replacing an in-neighbor
                end
                if length(inneighbors(g, u)) == 0  # reached a source vertex, done with path
                    if !(x in paths)
                      push!(paths, x)
                    end
                else
                    enqueue!(que, copy(x))
                end
            end
        end
    end
    return paths
end

# The longest path from vertx s to any other vertex in a DAG G (not necessarily unique).
# Note: in a DAG G, longest paths in G = shortest paths in -G
"""
    longest_path(g, s)
    
The longest path from vertx s to any other vertex in a acyclic graph `g`.  The longest path
is not necessarily unique, i.e., there can be more than one longest path between two vertices.

 # Arguments
Required:
- `g::AbstractGraph` : acylic graph. 
- `s::Int` : index of the source vertex in `g`. 

```julia-repl
julia> path = longest_paths(g, s)
```
"""
function longest_path(g::AbstractGraph{T}, s::Int) where T
    if is_cyclic(g)
        error("longest_path(): input graph has cycles")
    end
    lp = Array{Edge}[]
    max = 0
    # shortest path from s to all vertices in -G
    for path in enumerate_paths(dijkstra_shortest_paths(g, s, -weights(g), allpaths=true))
        if length(path) > max
            lp = path
            max = length(path)
        end
    end
    return lp
end

# Find all fo the longest paths in an acyclic graph.
"""
    longest_paths(g)
    
Finds the set of longest paths in `g`, and returns an array of vertex arrays, where each vertex
array contains the vertices in a longest path.

 # Arguments
Required:
- `g::AbstractGraph` : acylic graph. 

```julia-repl
julia> paths = longest_paths(g)
```
"""
function longest_paths(g::AbstractGraph{T}) where T
    if is_cyclic(g)
        error("longest_paths(): input graph has cycles")
    end
    lps = Array[]
    max = 0
    paths = all_paths(g)
    for path in paths  # find length of longest path
        length(path) > max ? max = length(path) : nothing
    end
    for path in paths
        length(path) == max ? push!(lps, path) : nothing
    end
    return lps
end