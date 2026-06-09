using BlackBoxOptim
using Aqua
using JET
using Test

@testset "Aqua" begin
    Aqua.test_all(BlackBoxOptim)
end

@testset "JET" begin
    JET.test_package(BlackBoxOptim; target_defined_modules = true)
end
