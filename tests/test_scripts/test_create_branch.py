from unittest.mock import mock_open, patch

import pytest

from scripts.create_branch import (
    get_base_branch,
    get_current_version,
    select_branch_type,
    select_release_type,
)

# Mock data for pyproject.toml
MOCK_TOML_DATA = b"""
[tool.poetry]
version = "0.1.0"
"""


# Test for get_current_version function
def test_get_current_version():
    with patch("builtins.open", mock_open(read_data=MOCK_TOML_DATA)):
        version = get_current_version()
        assert version == "0.1.0"


# Test for select_branch_type function
@pytest.mark.parametrize(
    "input_value, expected_output",
    [("1", "feature"), ("2", "release"), ("3", "temp")],
)
def test_select_branch_type(input_value, expected_output):
    with patch("builtins.input", return_value=input_value):
        branch_type = select_branch_type()
        assert branch_type == expected_output


# Test for select_release_type function
@pytest.mark.parametrize(
    "input_value, expected_output",
    [("1", "final"), ("2", "a"), ("3", "b"), ("4", "rc"), ("5", "post"), ("6", "dev")],
)
def test_select_release_type(input_value, expected_output):
    with patch("builtins.input", return_value=input_value):
        release_type = select_release_type()
        assert release_type == expected_output


# Test for get_base_branch function
@pytest.mark.parametrize(
    "branch_type, expected_output",
    [("feature", "dev"), ("temp", "current_branch"), ("release", "dev")],
)
def test_get_base_branch(branch_type, expected_output):
    with patch("subprocess.getoutput", return_value="current_branch"):
        with patch("scripts.create_branch.select_release_type", return_value="final"):
            base_branch = get_base_branch(branch_type)
            assert base_branch == expected_output


# Additional tests can be added for the main function and other scenarios.
