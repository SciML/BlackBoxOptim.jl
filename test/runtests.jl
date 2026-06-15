using SciMLTesting
using SafeTestsets
using Random

# BlackBoxOptim's test suite is not cleanly folder-partitionable: the test files
# live flat in test/ (plus test/utilities and test/problems) and are enumerated by
# testset_normal.txt rather than discovered per-folder, and test/problems holds both
# real test units and shared helper code (common.jl, included only by the heavy
# manual problem suites). So this uses the explicit-args run_tests form: core_body
# lists the real Core test files, each run isolated in its own @safetestset module.
function core_body()
    # The suite has no per-file seeding and several stochastic tests assert on
    # optimizer outcomes (e.g. test_set_candidate's "found the injected optimum").
    # Those are sensitive to the global-RNG state inherited from all preceding
    # files, so the run is only reproducible if the RNG is pinned up front. Seed
    # once here so the whole Core run (and CI) is deterministic.
    Random.seed!(1234)

    @safetestset "Latin hypercube sampling" include("utilities/test_latin_hypercube_sampling.jl")
    @safetestset "Halton sequence" include("utilities/test_halton_sequence.jl")
    @safetestset "Assign ranks" include("utilities/test_assign_ranks.jl")

    @safetestset "Parameters" include("test_parameters.jl")
    @safetestset "Fitness" include("test_fitness.jl")
    @safetestset "Evaluator" include("test_evaluator.jl")
    @safetestset "Population" include("test_population.jl")
    @safetestset "Bimodal Cauchy distribution" include("test_bimodal_cauchy_distribution.jl")
    @safetestset "Search space" include("test_search_space.jl")
    @safetestset "Mutation operators" include("test_mutation_operators.jl")
    @safetestset "Crossover operators" include("test_crossover_operators.jl")
    @safetestset "Selectors" include("test_selectors.jl")
    @safetestset "Embedders" include("test_embedders.jl")
    @safetestset "Frequency adaptation" include("test_frequency_adaptation.jl")
    @safetestset "Archive" include("test_archive.jl")
    @safetestset "EpsBox archive" include("test_epsbox_archive.jl")
    @safetestset "Optimization result" include("test_optimizationresult.jl")

    @safetestset "Random search" include("test_random_search.jl")
    @safetestset "Differential evolution" include("test_differential_evolution.jl")
    @safetestset "Adaptive differential evolution" include("test_adaptive_differential_evolution.jl")
    @safetestset "Natural evolution strategies" include("test_natural_evolution_strategies.jl")

    @safetestset "BORG MOEA" include("test_borg_moea.jl")

    @safetestset "Tracing" include("test_tracing.jl")
    @safetestset "Top-level bboptimize" include("test_toplevel_bboptimize.jl")
    @safetestset "Smoketest bboptimize" include("test_smoketest_bboptimize.jl")

    @safetestset "Set candidate" include("test_set_candidate.jl")
    @safetestset "Max func evals" include("test_max_func_evals.jl")

    @safetestset "Problem" include("problems/test_problem.jl")
    @safetestset "Single objective problems" include("problems/test_single_objective.jl")

    @safetestset "Generating set search" include("test_generating_set_search.jl")
    @safetestset "Direct search with probabilistic descent" include("test_direct_search_with_probabilistic_descent.jl")
    return nothing
end

run_tests(;
    core = core_body,
    qa = (; env = joinpath(@__DIR__, "qa"), body = joinpath(@__DIR__, "qa", "qa.jl")),
    # Curated "All": run only Core. QA stays selectable by name but out of the
    # aggregate (it has its own CI lane).
    all = ["Core"],
)
