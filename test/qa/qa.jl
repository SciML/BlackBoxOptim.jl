using SciMLTesting, BlackBoxOptim, Test
using JET

run_qa(
    BlackBoxOptim;
    explicit_imports = true,
    # Genuine Aqua findings tracked in
    # https://github.com/SciML/BlackBoxOptim.jl/issues/268 — kept @test_broken so
    # the QA group is green and each flips to "unexpectedly passing" once fixed.
    aqua_broken = (
        :ambiguities,        # 6 ambiguities (population/bboptimize/fitness)
        :unbound_args,       # 6 methods with unbound type parameters
        :undefined_exports,  # BlackBoxOptim.Problems exported but flagged
        :stale_deps,         # Requires declared but not loaded
    ),
    # JET reports genuine errors (undefined bindings such as BlackBoxOptim.Math /
    # .worker / .population_type / .EMPTY_DICT / .warn / .sub_problem) tracked in
    # https://github.com/SciML/BlackBoxOptim.jl/issues/268 — keep @test_broken so the
    # QA group stays green and auto-flips to "unexpectedly passing" once fixed.
    jet_broken = true,
    api_docs_kwargs = (;
        ignore = (
            :DiffEvoOpt,
            :MaximizingFitnessScheme,
            :MinimizationProblemFamily,
            :MinimizingFitnessScheme,
            :Problems,
            :adaptive_de_rand_1_bin,
            :adaptive_de_rand_1_bin_radiuslimited,
            :best_candidate,
            :best_fitness,
            :capacity,
            :chain,
            :compare_optimizers,
            :deltas,
            :diameters,
            :dimdigits,
            :dxnes,
            :f_minimum,
            :fitness_eltype,
            :fitness_scheme,
            :fitness_scheme_type,
            :fixed_dim_problem,
            :flatten,
            :frequencies,
            :is_better,
            :is_minimizing,
            :is_worse,
            :isnafitness,
            :iteration_converged,
            :last_top_fitness,
            :lastrun,
            :maxs,
            :minimization_problem,
            :mins,
            :nafitness,
            :name,
            :numchildren,
            :numdims,
            :numobjectives,
            :numparents,
            :numruns,
            :objfunc,
            :opt_value,
            :parameters,
            :popsize,
            :problem,
            :rand_individuals_lhs,
            :range_for_dim,
            :ranges,
            :same_fitness,
            :save_fitness_history_to_csv_file,
            :search_space,
            :separable_nes,
            :symmetric_search_space,
            :xnes,
        ),
    ),
    ei_kwargs = (;
        # The top module dynamically `include`s problem/GUI files via `joinpath`,
        # so ExplicitImports cannot statically follow them and marks BlackBoxOptim
        # unanalyzable for the import-scope checks; allow it explicitly.
        no_stale_explicit_imports = (; allow_unanalyzable = (BlackBoxOptim,)),
        no_implicit_imports = (; allow_unanalyzable = (BlackBoxOptim,)),
        # Qualified accesses to names that are not declared public by their owner.
        all_qualified_accesses_are_public = (;
            ignore = (
                # Base internals used directly by BlackBoxOptim.
                Symbol("@deprecate_binding"), :Cartesian, :HasEltype, :HasLength,
                :IteratorEltype, :IteratorSize, :SizeUnknown, :Workqueues, :_div64,
                # SpatialIndexing internals used by the archive/dominance code.
                :HasID, :HasMBR, :Leaf, :Point, :Rect, :Region, :capacity,
                :children, :contains, :id, :idtrait, :intersects, :level, :load!,
                :mbr, :mbrtrait, :subtract!,
            ),
        ),
    ),
)
