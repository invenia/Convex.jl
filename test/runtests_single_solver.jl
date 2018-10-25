using Convex
using Test

tests = ["test_utilities.jl",
         "test_affine.jl",
         "test_lp.jl"]
tests_socp = ["test_socp.jl","test_params.jl"]
tests_sdp = ["test_sdp.jl"]
tests_exp = ["test_exp.jl"]
tests_int = ["test_int.jl"]
tests_exp_and_sdp = ["test_exp_and_sdp.jl"]
tests_complex = ["test_complex.jl"]

println("Running tests:")

for curtest in tests
    @info " Test: $(curtest)"
    include(curtest)
end

if can_solve_socp(get_default_solver())
    for curtest in tests_socp
        @info " Test: $(curtest)"
        include(curtest)
    end
end

if can_solve_sdp(get_default_solver())
    for curtest in tests_sdp
        @info " Test: $(curtest)"
        include(curtest)
    end
end

if can_solve_exp(get_default_solver())
    for curtest in tests_exp
        @info " Test: $(curtest)"
        include(curtest)
    end
end

if can_solve_sdp(get_default_solver()) && can_solve_exp(get_default_solver())
    for curtest in tests_exp_and_sdp
        @info " Test: $(curtest)"
        include(curtest)
    end
end

if can_solve_mip(get_default_solver())
	for curtest in tests_int
    @info " Test: $(curtest)"
    include(curtest)
	end
end

if can_solve_sdp(get_default_solver())
    for curtest in tests_complex
        @info " Test: $(curtest)"
        include(curtest)
    end
end
