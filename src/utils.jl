_add_versions(v1::VersionNumber, v2::VersionNumber) = 
    VersionNumber(v1.major + v2.major, v1.minor + v2.minor, v1.patch + v2.patch)