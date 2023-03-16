class BoolState {
  bool _isEnabled = false;

  void enable() {
    _isEnabled = true;
  }

  void disable() {
    _isEnabled = false;
  }

  bool get isEnabled => _isEnabled;
  bool get isDisabled => !_isEnabled;
}
