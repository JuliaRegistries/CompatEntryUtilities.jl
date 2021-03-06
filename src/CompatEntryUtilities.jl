module CompatEntryUtilities

import Pkg

export semver_spec_string

@static if Base.VERSION >= v"1.7-"
    const PKG_VERSIONS = Pkg.Versions
else
    const PKG_VERSIONS = Pkg.Types
end

function _check_result(spec::PKG_VERSIONS.VersionSpec, str::String)
    spec_from_str = try
        PKG_VERSIONS.semver_spec(str)
    catch
        @error("Encountered an error while checking the result", spec, str)
        rethrow()
    end
    result_is_correct = spec == spec_from_str
    if !result_is_correct
        msg = "`Pkg.Versions.semver_spec(str)` is not equal to the original `spec`"
        @error(msg, spec, str, spec_from_str)
        throw(ErrorException(msg))
    end
    return nothing
end

function _fix_zero(s::String)
    if s === "0.0.0"
        return "0"
    end
    return s
end

function _semver_spec_string(r::PKG_VERSIONS.VersionRange)::String
    m, n = r.lower.n, r.upper.n

    if (m, n) == (0, 0)
        return "≥0"
    end

    if ((m, n) == (3, 3)) && (r.lower == r.upper)
        # "=a.b.c"
        return string("=", _fix_zero(join(r.lower.t, "."))) 
    end

    if ((m, n) == (3, 1)) && (r.lower.t[1] == r.upper.t[1]) && (r.lower.t[1] ≥ 1)
        # "^a.b.c", where a ≥ 1
        #  "a.b.c", where a ≥ 1
        return _fix_zero(join(r.lower.t[1:m], ".")) 
    end

    if (m !=0 ) && (n == 0)
        # "≥a.b.c"
        return string("≥", _fix_zero(join(r.lower.t[1:m], ".")))
    end

    if (m !=0 ) && (n != 0)
        # "a.b.c - x.y.z" 
        return string(join(r.lower.t[1:m], "."), " - ", join(r.upper.t[1:n], "."))
    end

    msg = "This version range cannot be represented using SemVer notation"
    @error(msg, r, r.lower, r.upper)
    throw(ArgumentError(msg))
end

"""
    semver_spec_string(spec::Pkg.Versions.VersionSpec)::String

Returns `str::AbstractString` such that `Pkg.Versions.semver_spec(str) == spec`.
"""
function semver_spec_string(spec::PKG_VERSIONS.VersionSpec)
    if isempty(spec.ranges)
        result_string = "1 - 0"
    else
        spec_strings = _semver_spec_string.(spec.ranges)
        result_string = join(spec_strings, ", ")
    end
    _check_result(spec, result_string)
    return result_string
end

end # module
