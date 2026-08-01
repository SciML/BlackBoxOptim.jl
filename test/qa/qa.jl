using BlackBoxOptim, JET, SciMLTesting, Test

# ExplicitImports can only check an extension module that actually exists, and an
# extension module only exists once its triggers are loaded. Without these `using`
# lines the ext/ sources are never scanned by QA at all.
using HTTP, JSON, Sockets

# ExplicitImports silently skips an extension that fails to load, so assert the
# extension modules actually exist rather than trusting a green run_qa.
@testset "Extensions loaded" begin
    for ext in (:BlackBoxOptimRealtimePlotServerExt,)
        @test Base.get_extension(BlackBoxOptim, ext) !== nothing
    end
end

run_qa(
    BlackBoxOptim;
    ei_kwargs = (;
        all_explicit_imports_are_public = (;
            ignore = (
                # BlackBoxOptim's own internals, reached from its own extension.
                # ExplicitImports treats an extension as a separate module, so these
                # read as non-public cross-module accesses even though they never
                # leave the package.
                :RealtimePlot, :hasnewdata, :printmsg, :replace_template_param,
            ),
        ),
    ),
)
