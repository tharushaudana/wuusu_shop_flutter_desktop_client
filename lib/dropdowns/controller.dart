class DropDownSelectorController {
  var onResetListener = null;

  onReset(cb) {
    onResetListener = cb;
  }

  reset() {
    if (onResetListener == null) return;
    onResetListener();
  }
}
