import pytest

from scripts.increment_version import increment_version


def test_increment_alpha():
    assert increment_version("1.2.3", "a") == "1.2.1a"
    assert increment_version("1.2.3a", "a") == "1.2.4a"


def test_increment_beta():
    assert increment_version("1.2.3", "b") == "1.2.1b"
    assert increment_version("1.2.3b", "b") == "1.2.4b"


def test_increment_rc():
    assert increment_version("1.2.3", "rc") == "1.2.1rc"
    assert increment_version("1.2.3rc", "rc") == "1.2.4rc"


def test_increment_post():
    assert increment_version("1.2.3", "post") == "1.2.1post"
    assert increment_version("1.2.3post", "post") == "1.2.4post"


def test_increment_dev():
    assert increment_version("1.2.3", "dev") == "1.2.1dev"
    assert increment_version("1.2.3dev", "dev") == "1.2.4dev"


def test_increment_final():
    assert increment_version("1.2.3", "final") == "1.2.4"
    assert increment_version("1.2.3a", "final") == "1.2.4"
    assert increment_version("1.2.3b", "final") == "1.2.4"
    assert increment_version("1.2.3rc", "final") == "1.2.4"
    assert increment_version("1.2.3post", "final") == "1.2.4"
    assert increment_version("1.2.3dev", "final") == "1.2.4"


def test_invalid_release_type():
    with pytest.raises(ValueError):
        increment_version("1.2.3", "invalid")
