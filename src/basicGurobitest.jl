using Gurobi

env = Gurobi.Env()

# set presolve to 0
setparam!(env, "Presolve", 0)

 # construct the model
model = gurobi_model(env;
    name = "lp_01", 
    f = ones(2), 
    A = [17. 15.; 15. 18.], 
    b = [117., 132.],
    lb = [6., 8.])

 # run optimization
optimize(model)

 # show results
sol = get_solution(model)
println("soln = $(sol)")

objv = get_objval(model)
println("objv = $(objv)")
