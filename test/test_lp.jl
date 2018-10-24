using Convex
using Test

TOL = 1e-3

@testset "LP Atoms" begin

  @testset "abs atom" begin
    x = Variable()
    p = minimize(solver, abs(x), x<=-1)
    @test vexity(p) == ConvexVexity()
    solve!(p)
    @test p.optval ≈ 1 atol=TOL
    @test evaluate(abs(x)) ≈ 1 atol=TOL

    x = Variable(2,2)
    p = minimize(solver, sum(abs(x)), x[2,2]>=1, x[1,1]>=1, x>=0)
    @test vexity(p) == ConvexVexity()
    solve!(p)
    @test p.optval ≈ 2 atol=TOL
    @test evaluate(sum(abs(x))) ≈ 2 atol=TOL
  end

  @testset "maximum atom" begin
    x = Variable(10)
    a = rand(10, 1)
    p = minimize(solver, maximum(x), x >= a)
    @test vexity(p) == ConvexVexity()
    solve!(p)
    @test p.optval ≈ maximum(a) atol=TOL
    @test evaluate(maximum(x)) ≈ maximum(a) atol=TOL
  end

  @testset "minimum atom" begin
    x = Variable(1)
    a = rand(10, 10)
    p = maximize(solver, minimum(x), x <= a)
    @test vexity(p) == ConvexVexity()
    solve!(p)
    @test p.optval ≈ minimum(a) atol=TOL
    @test evaluate(minimum(x)) ≈ minimum(a) atol=TOL

    x = Variable(4, 4)
    y = Variable(4, 6)
    z = Variable(1)
    c = ones(4, 1)
    d = fill(2.0, (6, 1))
    constraints = [[x y] <= 2, z <= 0, z <= x, 2z >= -1]
    objective = sum(x + z) + minimum(y) + c' * y * d
    p = maximize(solver, objective, constraints)
    @test vexity(p) == ConvexVexity()
    solve!(p)
    @test p.optval ≈ 130 atol=TOL
    @test (evaluate(objective))[1] ≈ 130 atol=TOL
  end

  @testset "max atom" begin
    x = Variable(10, 10)
    y = Variable(10, 10)
    a = rand(10, 10)
    b = rand(10, 10)
    p = minimize(solver, maximum(max(x, y)), [x >= a, y >= b])
    @test vexity(p) == ConvexVexity()
    solve!(p)
    max_a = maximum(a)
    max_b = maximum(b)
    @test p.optval ≈ max(max_a, max_b) atol=TOL
    @test evaluate(maximum(max(x, y))) ≈ max(max_a, max_b) atol=TOL
  end

  @testset "min atom" begin
    x = Variable(10, 10)
    y = Variable(10, 10)
    a = rand(10, 10)
    b = rand(10, 10)
    p = maximize(solver, minimum(min(x, y)), [x <= a, y <= b])
    @test vexity(p) == ConvexVexity()
    solve!(p)
    min_a = minimum(a)
    min_b = minimum(b)
    @test p.optval ≈ min(min_a, min_b) atol=TOL
    @test evaluate(minimum(min(x, y))) ≈ min(min_a, min_b) atol=TOL
  end

  @testset "pos atom" begin
    x = Variable(3)
    a = [-2; 1; 2]
    p = minimize(solver, sum(pos(x)), [x >= a, x <= 2])
    @test vexity(p) == ConvexVexity()
    solve!(p)
    @test p.optval ≈ 3 atol=TOL
    @test evaluate(sum(pos(x))) ≈ 3 atol=TOL
  end

  @testset "neg atom" begin
    x = Variable(3)
    p = minimize(solver, 1, [x >= -2, x <= -2, neg(x) >= -3])
    @test vexity(p) == ConvexVexity()
    solve!(p)
    @test p.optval ≈ 1 atol=TOL
    @test evaluate(sum(neg(x))) ≈ -6 atol=TOL
  end

  @testset "sumlargest atom" begin
    x = Variable(2)
    p = minimize(solver, sumlargest(x, 2), x >= [1; 1])
    @test vexity(p) == ConvexVexity()
    solve!(p)
    @test p.optval ≈ 2 atol=TOL
    @test evaluate(sumlargest(x, 2)) ≈ 2 atol=TOL

    x = Variable(4, 4)
    p = minimize(solver, sumlargest(x, 3), x >= eye(4), x[1, 1] >= 1.5, x[2, 3] >= 2.1)
    @test vexity(p) == ConvexVexity()
    solve!(p)
    @test p.optval ≈ 4.6 atol=TOL
    @test evaluate(sumlargest(x, 2)) ≈ 3.6 atol=TOL
  end

  @testset "sumsmallest atom" begin
    x = Variable(4, 4)
    p = minimize(solver, sumlargest(x, 2), sumsmallest(x, 4) >= 1)
    @test vexity(p) == ConvexVexity()
    solve!(p)
    @test p.optval ≈ 0.5 atol=TOL
    @test evaluate(sumsmallest(x, 4)) ≈ 1 atol=TOL

    x = Variable(3, 2)
    p = maximize(solver, sumsmallest(x, 3), x >= 1, x <= 5, sumlargest(x, 3) <= 12)
    @test vexity(p) == ConvexVexity()
    solve!(p)
    @test p.optval ≈ 12 atol=TOL
    @test evaluate(sumsmallest(x, 3)) ≈ 12 atol=TOL
  end

  @testset "dotsort atom" begin
    x = Variable(4, 1)
    p = minimize(solver, dotsort(x, [1, 2, 3, 4]), sum(x) >= 7, x >= 0, x <= 2, x[4] <= 1)
    @test vexity(p) == ConvexVexity()
    solve!(p)
    @test p.optval ≈ 19 atol=TOL
    @test vec(x.value) ≈ [2; 2; 2; 1] atol=TOL
    @test evaluate(dotsort(x, [1, 2, 3, 4])) ≈ 19 atol=TOL

    x = Variable(2, 2)
    p = minimize(solver, dotsort(x, [1 2; 3 4]), sum(x) >= 7, x >= 0, x <= 2, x[2, 2] <= 1)
    @test vexity(p) == ConvexVexity()
    solve!(p)
    @test p.optval ≈ 19 atol=TOL
    @test evaluate(dotsort(x, [1, 2, 3, 4])) ≈ 19 atol=TOL
  end

  @testset "hinge loss atom" begin
    # TODO: @davidlizeng. We should finish this someday.
  end

  @testset "norm inf atom" begin
    x = Variable(3)
    p = minimize(solver, norm_inf(x), [-2 <= x, x <= 1])
    @test vexity(p) == ConvexVexity()
    solve!(p)
    @test p.optval ≈ 0 atol=TOL
    @test evaluate(norm_inf(x)) ≈ 0 atol=TOL
  end

  @testset "norm 1 atom" begin
    x = Variable(3)
    p = minimize(solver, norm_1(x), [-2 <= x, x <= 1])
    @test vexity(p) == ConvexVexity()
    solve!(p)
    @test p.optval ≈ 0 atol=TOL
    @test evaluate(norm_1(x)) ≈ 0 atol=TOL
  end

end
