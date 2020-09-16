# Simulation tests

# Test simulate() function
@testset "Simulation Tests" begin

include("test_degree_plan.jl")

# nobody can pass any class
set_passrates(dp.curriculum.courses, 0);
sim = simulate(dp, 1, simple_students(10), max_credits=6, performance_model=PassRate, enrollment_model=Enrollment, duration=4, duration_lock=false, stopouts=false);
@test length(sim.graduated_students) == 0

# everybody passes every class
set_passrates(dp.curriculum.courses, 1.0);
sim = simulate(dp, 1, simple_students(10), max_credits=6, performance_model=PassRate, enrollment_model=Enrollment, duration=4, duration_lock=false, stopouts=false);
@test length(sim.graduated_students) == 10

end;