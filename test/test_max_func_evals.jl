@testset "MaxFuncEvals" begin

# It was reported in an GitHub Issue that MaxFuncEvals doesn't have an effect 
# https://github.com/robertfeldt/BlackBoxOptim.jl/issues/157
# so we added a test to check this.

function rosenbrock2d(x)
    return (1.0 - x[1])^2 + 100.0 * (x[2] - x[1]^2)^2
end

mutable struct MyCounter
    count::Int
end

function myfit(c::MyCounter, fitness::Function)
    f(x) = begin
        c.count += 1
        fitness(x)
    end
    return f
end

MFE = 10
c = MyCounter(0)
res = bboptimize(myfit(c, rosenbrock2d); SearchRange = (-5.0, 5.0), NumDimensions = 2, MaxFuncEvals = MFE);
@test BlackBoxOptim.stop_reason(res) == "Max number of function evaluations ($MFE) reached"
@test MFE <= c.count <= (MFE+20) # Must be at least 10 but can be somewhat higher since might be several evaluations per step of the optimizer

MFE = 1042
c = MyCounter(0)
res = bboptimize(myfit(c, rosenbrock2d); SearchRange = (-5.0, 5.0), NumDimensions = 2, MaxFuncEvals = MFE);
@test BlackBoxOptim.stop_reason(res) == "Max number of function evaluations ($MFE) reached"
@test MFE <= c.count <= (MFE+20) # Must be at least 10 but can be somewhat higher since might be several evaluations per step of the optimizer

end

@testset "MaxStepsWithoutProgress (single objective)" begin
    flat_objective(x) = 1.0
    max_steps_without_progress = 3

    res = bboptimize(flat_objective;
        SearchRange = (-5.0, 5.0),
        NumDimensions = 2,
        Method = :random_search,
        MaxSteps = 10_000,
        MaxStepsWithoutProgress = max_steps_without_progress,
        TraceMode = :silent)

    @test BlackBoxOptim.stop_reason(res) == "No progress for more than $(max_steps_without_progress) iterations"
    @test BlackBoxOptim.iterations(res) == max_steps_without_progress + 2
end
