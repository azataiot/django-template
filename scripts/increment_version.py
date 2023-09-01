def increment_version(version, release_type):
    # Split the version number into parts
    parts = version.split(".")

    # Increment the appropriate part of the version number
    if release_type == "alpha":
        if "a" in parts[-1]:
            alpha_part = parts[-1][:-1]
            parts[-1] = str(int(alpha_part) + 1) + "a"
        else:
            parts[-1] = "1a"
    elif release_type == "beta":
        if "b" in version:
            parts[-1] = str(int(parts[-1][1:]) + 1) + "b"
        else:
            parts[-1] = "1b"
    elif release_type == "candidate":
        if "rc" in version:
            parts[-1] = str(int(parts[-1][2:]) + 1) + "rc"
        else:
            parts[-1] = "1rc"
    elif release_type == "breaking":
        parts[0] = str(int(parts[0]) + 1)
        parts[1] = "0"
        parts[2] = "0"
    else:
        parts[-1] = str(int(parts[-1]) + 1)

    return ".".join(parts)
