using Convex
using Test
using ECOS
using SCS
using GLPKMathProgInterface

function isinstalled(pkg)
    for path in Base.DEPOT_PATH
        if isdir(joinpath(path, pkg))
            return true
        elseif isdir(joinpath(path, "packages", pkg))
            return true
        end
    end
    return false
end

solvers = Any[]

#push!(solvers, ECOSSolver(verbose=0))
#push!(solvers, GLPKSolverMIP())
push!(solvers, SCSSolver(verbose=0, eps=1e-5))

if isinstalled("Gurobi")
    using Gurobi
    push!(solvers, GurobiSolver(OutputFlag=0))
end

if isinstalled("Mosek")
    using Mosek
    push!(solvers, MosekSolver(LOG=0))
end

for slv in solvers
    global solver = slv
    println("Running tests with $(solver):")
    include("runtests_single_solver.jl")
end

