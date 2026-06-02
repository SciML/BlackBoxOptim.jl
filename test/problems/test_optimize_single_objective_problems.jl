include("common.jl")

@testset "Optimize single objective problems in 5, 10, and 30 dimensions with DE" begin
    simple_problems = ["Sphere", "Schwefel2.22", "Schwefel2.22"]
    @testset "Simple problem $pr" for pr in simple_problems
        p = BlackBoxOptim.example_problems[pr]

        @test fitness_for_opt(p, 5, 20, 5.0e3, :de_rand_1_bin) < 0.01
        @test fitness_for_opt(p, 5, 20, 5.0e3, :de_rand_1_bin_radiuslimited) < 0.01

        @test fitness_for_opt(p, 10, 20, 1.0e4, :de_rand_1_bin) < 0.01
        @test fitness_for_opt(p, 10, 20, 1.0e4, :de_rand_1_bin_radiuslimited) < 0.01

        @test fitness_for_opt(p, 30, 25, 3.0e4, :de_rand_1_bin) < 0.01
        @test fitness_for_opt(p, 30, 25, 3.0e4, :de_rand_1_bin_radiuslimited) < 0.01
    end

    @testset "Schwefel1.2" begin
        problem = "Schwefel1.2"
        p = BlackBoxOptim.example_problems[problem]
        @test fitness_for_opt(p, 5, 20, 5.0e3, :de_rand_1_bin_radiuslimited) < 0.01
        @test fitness_for_opt(p, 10, 50, 5.0e4, :de_rand_1_bin_radiuslimited) < 0.01

        #DE/rand/1/bin seems to have troubles...
        @test fitness_for_opt(p, 30, 50, 2.0e5, :de_rand_1_bin_radiuslimited) < 10.0
        @test fitness_for_opt(p, 30, 50, 2.0e5, :adaptive_de_rand_1_bin) < 10.0
        @test fitness_for_opt(p, 30, 50, 2.0e5, :adaptive_de_rand_1_bin_radiuslimited) < 10.0
    end

    @testset "Rosenbrock" begin
        problem = "Rosenbrock"
        p = BlackBoxOptim.example_problems[problem]
        @test fitness_for_opt(p, 5, 20, 1.0e4, :de_rand_1_bin_radiuslimited) < 100.0
        @test fitness_for_opt(p, 10, 20, 5.0e4, :de_rand_1_bin_radiuslimited) < 100.0
        @test fitness_for_opt(p, 30, 40, 2.0e5, :de_rand_1_bin_radiuslimited) < 100.0

        @test fitness_for_opt(p, 30, 40, 2.0e5, :adaptive_de_rand_1_bin) < 100.0
        @test fitness_for_opt(p, 30, 40, 2.0e5, :adaptive_de_rand_1_bin_radiuslimited) < 100.0

        @test fitness_for_opt(p, 50, 40, 3.0e5, :adaptive_de_rand_1_bin_radiuslimited) < 100.0
    end
end
