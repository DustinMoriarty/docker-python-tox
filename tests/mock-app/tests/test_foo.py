import pytest
from mock_app import foo

def test_foo():
    a = 1
    assert foo(a)==a
