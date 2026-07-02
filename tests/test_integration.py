"""Integration tests.

They talk to a RUNNING instance of the application over HTTP, which itself
talks to a running MySQL container - so a passing run proves the whole chain
(browser -> Flask -> SQLAlchemy -> MySQL) works.

Target URL is taken from the APP_URL environment variable
(default http://localhost:5000). For the local podman deployment use:

    APP_URL=http://localhost:8080 pytest tests/test_integration.py -v
"""
import os
import re

import requests

BASE_URL = os.environ.get("APP_URL", "http://localhost:5000")


def _get_csrf_token(session, html=None):
    if html is None:
        html = session.get(BASE_URL + "/", timeout=10).text
    match = re.search(r'name="csrf_token"[^>]*value="([^"]+)"', html)
    assert match, "CSRF token not found on the page"
    return match.group(1)


def test_index_is_up_and_shows_student_and_college():
    response = requests.get(BASE_URL + "/", timeout=10)
    assert response.status_code == 200
    assert "Ivan" in response.text
    assert "Algebra Bernays University" in response.text


def test_conversion_is_stored_in_the_database():
    session = requests.Session()
    token = _get_csrf_token(session)

    response = session.post(
        BASE_URL + "/",
        data={"csrf_token": token, "celsius": "100", "submit": "Convert"},
        timeout=10,
    )
    assert response.status_code == 200
    assert "212.0" in response.text  # converted value rendered from the DB

    # A FRESH request (new client, no session) must still show the conversion:
    # the row really lives in MySQL, it is not just echoed back to the sender.
    fresh = requests.get(BASE_URL + "/", timeout=10)
    assert "212.0" in fresh.text
