using CompatEntryUtilities
using Test

import Pkg

@static if Base.VERSION >= v"1.7-"
    const PKG_VERSIONS = Pkg.Versions
else
    const PKG_VERSIONS = Pkg.Types
end

const expected_exception_1 = ErrorException("`Pkg.Versions.semver_spec(str)` is not equal to the original `spec`")
const expected_exception_2 = Exception
const expected_exception_3 = ArgumentError("This version range cannot be represented using SemVer notation")


function roundtrip_semver_spec_string(str_1::AbstractString)
    spec_1 = PKG_VERSIONS.semver_spec(str_1)
    str_2 = semver_spec_string(spec_1)
    spec_2 = PKG_VERSIONS.semver_spec(str_2)
    str_3 = semver_spec_string(spec_2)
    spec_3 = PKG_VERSIONS.semver_spec(str_3)
    roundtrip_succeeded = (spec_1 == spec_2) && (spec_1 == spec_3) && (spec_2 == spec_3)
    if !roundtrip_succeeded
        @error("Roundtrip failed", str_1, str_2, str_3, spec_1, spec_2, spec_3)
    end
    return roundtrip_succeeded
end

@testset "_check_result" begin
    @test CompatEntryUtilities._check_result(PKG_VERSIONS.semver_spec("1"), "1") isa Nothing
    @test_throws expected_exception_1 CompatEntryUtilities._check_result(PKG_VERSIONS.semver_spec("2"), "1")
    # @test_throws expected_exception_2 
    CompatEntryUtilities._check_result(PKG_VERSIONS.semver_spec("1 - 0"), "=0.0.0")
end

@testset "semver_spec_string" begin
    @testset begin
        let
            lower = PKG_VERSIONS.VersionBound()
            upper = PKG_VERSIONS.VersionBound(1)
            r = PKG_VERSIONS.VersionRange(lower, upper)
            spec = PKG_VERSIONS.VersionSpec([r])
            @test_throws expected_exception_3 semver_spec_string(spec)
        end
    end

    @testset begin
        bases = ["0.0.3", "0.2.3", "1.2.3", "0.0", "0.2", "1.2", "0", "1"]
        specifiers = ["", "^", "~", "= ", ">= ", "≥ "]
        for specifier in specifiers
            for base in bases
                @test roundtrip_semver_spec_string("$(specifier)$(base)")
            end
            @test roundtrip_semver_spec_string(join(string.(Ref(specifier), bases), ", "))
        end
    end

    @testset begin
        bases = ["0.0.3", "0.2.3", "1.2.3", "0.2", "1.2", "1"]
        specifiers = ["< "]
        for specifier in specifiers
            for base in bases
                @test roundtrip_semver_spec_string("$(specifier)$(base)")
            end
            @test roundtrip_semver_spec_string(join(string.(Ref(specifier), bases), ", "))
        end
    end

    @testset begin
        strs = [
            # ranges
            "1.2.3 - 4.5.6",
            "0.2.3 - 4.5.6",
            "1.2 - 4.5.6",
            "1 - 4.5.6",
            "0.2 - 4.5.6",
            "0.2 - 0.5.6",
            "1.2.3 - 4.5",
            "1.2.3 - 4",
            "1.2 - 4.5",
            "1.2 - 4",
            "1 - 4.5",
            "1 - 4",
            "0.2.3 - 4.5",
            "0.2.3 - 4",
            "0.2 - 4.5",
            "0.2 - 4",
            "0.2 - 0.5",
            "0.2 - 0",

            # multiple ranges
            "1 - 2.3, 4.5.6 - 7.8.9",

            # other stuff
            "1 - 0",
            "2 - 1",
            ">= 0",
        ]

        for str in strs
            @test roundtrip_semver_spec_string(str)
        end
    end
end
