using SciMLTesting, BlackBoxOptim, Test
using JET

run_qa(
    BlackBoxOptim;
    # Genuine Aqua findings tracked in
    # https://github.com/SciML/BlackBoxOptim.jl/issues/268 — kept @test_broken so
    # the QA group is green and each flips to "unexpectedly passing" once fixed.
    aqua_broken = (
        :ambiguities,        # 6 ambiguities (population/bboptimize/fitness)
        :unbound_args,       # 6 methods with unbound type parameters
        :stale_deps,         # Requires declared but not loaded
    ),
    # JET reports genuine errors on newer Julia versions (undefined bindings
    # such as BlackBoxOptim.Math / .worker / .population_type / .EMPTY_DICT /
    # .warn / .sub_problem) tracked in
    # https://github.com/SciML/BlackBoxOptim.jl/issues/268. Julia 1.10's QA
    # environment no longer reports them, so keep the broken marker only where
    # JET still finds those package issues.
    jet_broken = VERSION >= v"1.11",
    reexports_allow = (
        :Individual, :ParamBounds, :Parameters, :ParamsDict, :minimum,
    ),
    api_docs_kwargs = (;
        # Exported Base.minimum overload; its documentation is owned by Base.
        rendered_ignore = (:minimum,),
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
