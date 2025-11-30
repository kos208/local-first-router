from app.router_service import parse_json_block


def test_parse_json():
    """Test JSON parsing from model responses."""
    txt = 'Here: {"answer":"hi","confidence":0.8}'
    p = parse_json_block(txt)
    assert p["answer"] == "hi"
    assert abs(p["confidence"] - 0.8) < 1e-6


def test_parse_json_malformed():
    """Test handling of malformed JSON."""
    txt = "This is not JSON"
    p = parse_json_block(txt)
    assert p["answer"] == "This is not JSON"
    assert p["confidence"] == 0.0


def test_parse_json_missing_fields():
    """Test handling of JSON with missing fields."""
    txt = '{"answer":"test"}'
    p = parse_json_block(txt)
    assert p["answer"] == "test"
    assert p["confidence"] == 0.0

