"""Unit tests for the pure conversion logic.

These run without any database or running application:
    pytest tests/test_unit.py -v
"""
import pytest

from converter import celsius_to_fahrenheit


@pytest.mark.parametrize(
    "celsius,expected",
    [
        (0, 32.0),        # freezing point of water
        (100, 212.0),     # boiling point of water
        (-40, -40.0),     # the point where both scales meet
        (37, 98.6),       # human body temperature
        (1, 33.8),
        (36.6, 97.88),    # value with rounding involved
    ],
)
def test_celsius_to_fahrenheit(celsius, expected):
    assert celsius_to_fahrenheit(celsius) == expected


def test_result_is_rounded_to_two_decimals():
    # 12.345 * 1.8 + 32 = 54.221 -> must be rounded to 54.22
    assert celsius_to_fahrenheit(12.345) == 54.22
