part of 'hooks.dart';

/// Creates a [ScrollController]
///
/// To use a [ScrollController] with an optional initial scroll position or debug label, use
/// ```dart
/// final controller = useScrollController(initialScrollOffset: .1, debugLabel='My Debug Label');
/// ```
///
/// Changing the parameters after the widget has been built has no
/// effect whatsoever. To update the value in a callback, for instance after a
/// button was pressed, use the [ScrollController.animateTo] or
/// [ScrollController.jumpTo] methods. To have the [ScrollController]
/// reflect changing values, you can use [useEffect]. This example will update
/// the [ScrollController.offset] whenever a provided [ValueListenable]
/// changes:
/// ```dart
/// final controller = useScrollController();
/// final update = useValueListenable(myScrollPositionUpdates);
///
/// useEffect(() {
///   controller.animateTo(update);
///   return null; // we don't need to have a special dispose logic
/// }, [update]);
/// ```
///
/// See also:
/// - [ScrollController], which this hook creates.
ScrollController useScrollController(
        {double initialScrollOffset = 0,
        bool keepScrollOffset = true,
        String debugLabel,
        List<Object> keys}) =>
    Hook.use(_ScrollControllerHook(
        initialScrollOffset, keepScrollOffset, debugLabel, keys));

class _ScrollControllerHook extends Hook<ScrollController> {
  final double initialScrollOffset;
  final bool keepScrollOffset;
  final String debugLabel;

  _ScrollControllerHook(
      this.initialScrollOffset, this.keepScrollOffset, this.debugLabel,
      [List<Object> keys])
      : super(keys: keys);

  @override
  _ScrollControllerHookState createState() {
    return _ScrollControllerHookState();
  }
}

class _ScrollControllerHookState
    extends HookState<ScrollController, _ScrollControllerHook> {
  ScrollController _controller;

  @override
  void initHook() {
    print('ScrollOffset ${hook.initialScrollOffset}');
    print('Keep ${hook.keepScrollOffset}');
    _controller = ScrollController(
        initialScrollOffset: hook.initialScrollOffset,
        keepScrollOffset: hook.keepScrollOffset,
        debugLabel: hook.debugLabel);
  }

  @override
  ScrollController build(BuildContext context) => _controller;

  @override
  void dispose() => _controller?.dispose();
}
