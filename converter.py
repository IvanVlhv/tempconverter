"""Pure conversion logic.

Kept in a separate module (outside app.py) so that unit tests can import it
without triggering the Flask app import, which connects to MySQL on startup.
"""


def celsius_to_fahrenheit(celsius: float) -> float:
    """Convert degrees Celsius to degrees Fahrenheit, rounded to 2 decimals."""
    return round((celsius * 1.8) + 32, 2)
