import pytest

from scripts.increment_version import increment_version


@pytest.mark.parametrize(
    "version, release_type, expected",
    [
        ("0.0.2a", "alpha", "0.0.3a"),
        ("0.0.2a", "beta", "0.0.1b"),
        ("0.0.2a", "candidate", "0.0.1rc"),
        ("0.0.2a", "breaking", "1.0.0"),
        ("0.0.2a", "final", "0.0.3"),
        ("0.0.2", "alpha", "0.0.1a"),
        ("0.0.2b", "beta", "0.0.3b"),
        ("0.0.2rc", "candidate", "0.0.3rc"),
        ("1.0.0", "breaking", "2.0.0"),
        ("1.0.0", "final", "1.0.1"),
    ],
)
def test_increment_version(version, release_type, expected):
    assert increment_version(version, release_type) == expected
