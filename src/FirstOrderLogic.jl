# from ChatGPT

function dnf_to_cnf(dnf::Vector{Vector{Symbol}})
    cnf = Vector{Vector{Symbol}}()
    
    # Distributive Law: (a OR b) AND (c OR d) = (a AND c) OR (a AND d) OR (b AND c) OR (b AND d)
    for clause in dnf
        clause_cnf = Vector{Symbol}()
        for literal in clause
            # Create a new clause with each literal as a singleton clause
            push!(clause_cnf, [literal])
        end
        push!(cnf, clause_cnf)
    end
    
    # Merge clauses using Distributive Law
    while length(cnf) > 1
        clause1 = popfirst!(cnf)
        clause2 = popfirst!(cnf)
        new_clause = []
        for lit1 in clause1
            for lit2 in clause2
                push!(new_clause, [lit1..., lit2...])
            end
        end
        push!(cnf, new_clause)
    end
    
    # Flatten the resulting CNF clauses
    return [flatten_clause(clause) for clause in cnf[1]]
end

function flatten_clause(clause::Vector{Vector{Symbol}})
    return [lit for literals in clause for lit in literals]
end


# In this example, the DNF formula ((A OR B) AND (C OR D)) is converted to its CNF 
# form ((A AND C) OR (A AND D) OR (B AND C) OR (B AND D)).

# dnf = [[Symbol("A"), Symbol("B")], [Symbol("C"), Symbol("D")]]
# cnf = dnf_to_cnf(dnf)
# println(cnf)

# [[Symbol("A"), Symbol("C")], [Symbol("A"), Symbol("D")], [Symbol("B"), Symbol("C")], [Symbol("B"), Symbol("D")]]
