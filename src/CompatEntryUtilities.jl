module CompatEntryUtilities

import Pkg

export semver_spec_string

@static if Base.VERSION >= v"1.7-"
    const PKG_VERSIONS = Pkg.Versions
else
    const PKG_VERSIONS = Pkg.Types
end

function _check_result(spec::PKG_VERSIONS.VersionSpec, str::String)
    spec_from_str = PKG_VERSIONS.semver_spec(str)
    result_is_correct = spec == spec_from_str
    if !result_is_correct
        msg = "`Pkg.Versions.semver_spec(str)` is not equal to the original `spec`"
        @error(msg, spec, str, spec_from_str)
        throw(ErrorException(msg))
    end
    return nothing
end

function _semver_spec_string(r::PKG_VERSIONS.VersionRange)
    m, n = r.lower.n, r.upper.n
    if (m, n) == (0, 0)
        return "≥0"::String
    elseif m == 0
        throw(ArgumentError("This version range cannot be represented using SemVer notation"))
    elseif n == 0
        return string("≥", join(r.lower.t, "."),)::String
    else
        return string(join(r.lower.t[1:m], "."), " - ", join(r.upper.t[1:n], "."))::String
    end
end

"""
    semver_spec_string(spec::Pkg.Versions.VersionSpec)

Returns `str::AbstractString` such that `Pkg.Versions.semver_spec(str) == spec`.
"""
function semver_spec_string(spec::PKG_VERSIONS.VersionSpec)
    if isempty(spec.ranges)
        result_string = "1 - 0"::String
    else
        spec_strings = _semver_spec_string.(spec.ranges)::Vector{String}
        result_string = join(spec_strings, ", ")::String
    end
    _check_result(spec, result_string)
    return result_string
end

end # module
