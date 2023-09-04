def increment_version(version, release_type):
    # Split the version number into parts
    parts = version.split(".")

    # Increment the appropriate part of the version number
    if release_type == "a":
        if "a" in parts[-1]:
            alpha_part = parts[-1][:-1]
            parts[-1] = str(int(alpha_part) + 1) + "a"
        else:
            parts[-1] = "1a"
    elif release_type == "b":
        if "b" in parts[-1]:
            beta_part = parts[-1][:-1]
            parts[-1] = str(int(beta_part) + 1) + "b"
        else:
            parts[-1] = "1b"
    elif release_type == "rc":
        if "rc" in parts[-1]:
            rc_part = parts[-1][:-2]
            parts[-1] = str(int(rc_part) + 1) + "rc"
        else:
            parts[-1] = "1rc"
    elif release_type == "post":
        if "post" in parts[-1]:
            post_part = parts[-1][:-4]
            parts[-1] = str(int(post_part) + 1) + "post"
        else:
            parts[-1] = "1post"
    elif release_type == "dev":
        if "dev" in parts[-1]:
            dev_part = parts[-1][:-3]
            parts[-1] = str(int(dev_part) + 1) + "dev"
        else:
            parts[-1] = "1dev"
    elif release_type == "final":
        parts[-1] = str(
            int(
                parts[-1]
                .split("a")[0]
                .split("b")[0]
                .split("rc")[0]
                .split("post")[0]
                .split("dev")[0]
            )
            + 1
        )
    else:
        raise ValueError(f"Invalid release type: {release_type}")

    return ".".join(parts)
