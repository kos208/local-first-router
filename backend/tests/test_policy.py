from app.policy import cloud_allowed


def test_cloud_allowed_default():
    """Test that cloud is allowed by default."""
    messages = [{"role": "user", "content": "Hello, how are you?"}]
    assert cloud_allowed(messages) is True


def test_cloud_blocked_with_tag():
    """Test that #no_cloud tag blocks cloud routing."""
    messages = [{"role": "user", "content": "Tell me something #no_cloud"}]
    assert cloud_allowed(messages) is False


def test_cloud_blocked_in_system_message():
    """Test that #no_cloud in system message blocks cloud."""
    messages = [
        {"role": "system", "content": "Be helpful #no_cloud"},
        {"role": "user", "content": "Hello"}
    ]
    assert cloud_allowed(messages) is False


def test_cloud_allowed_similar_text():
    """Test that similar text without exact tag allows cloud."""
    messages = [{"role": "user", "content": "no cloud services please"}]
    assert cloud_allowed(messages) is True

