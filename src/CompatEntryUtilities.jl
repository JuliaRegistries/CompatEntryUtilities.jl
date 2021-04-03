module CompatEntryUtilities

import Pkg

export semver_spec_string

@static if Base.VERSION >= v"1.7-"
    const VersionRange = Pkg.Versions.VersionRange
    const VersionSpec = Pkg.Versions.VersionSpec
else
    const VersionRange = Pkg.Types.VersionRange
    const VersionSpec = Pkg.Types.VersionSpec
end

function semver_spec_string(r::Pkg.Versions.VersionRange)
    m, n = r.lower.n, r.upper.n
    if (m, n) == (0, 0)
        return "≥0"
    elseif m == 0
        throw(ArgumentError("This version range cannot be represented using SemVer notation"))
    elseif n == 0
        return string("≥", join(r.lower.t, "."),)
    else
        return string(join(r.lower.t[1:m], "."), " - ", join(r.upper.t[1:n], "."))
    end
end

function semver_spec_string(spec::Pkg.Versions.VersionSpec)
    ranges = spec.ranges
    isempty(ranges) && return "1 - 0"
    specs = semver_spec_string.(ranges)
    return join(specs, ", ")
end

end # module
