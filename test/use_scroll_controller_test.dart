import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/src/framework.dart';
import 'package:flutter_hooks/src/hooks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mock.dart';

void main() {
  testWidgets('useScrollController returns a controller', (tester) async {
    final rebuilder = ValueNotifier(0);
    ScrollController controller;

    await tester.pumpWidget(HookBuilder(
      builder: (context) {
        controller = useScrollController();
        useValueListenable(rebuilder);
        return Container();
      },
    ));

    expect(controller, isNotNull);
    controller.addListener(() {});

    // rebuild hook
    final firstController = controller;
    rebuilder.notifyListeners();
    await tester.pumpAndSettle();
    expect(identical(controller, firstController), isTrue,
        reason: 'Controllers should be identical after rebuilds');

    // pump another widget so that the old one gets disposed
    await tester.pumpWidget(Container());

    expect(() => controller.addListener(null), throwsA((FlutterError error) {
      return error.message.contains('disposed');
    }));
  });

  testWidgets('respects initial offset property', (tester) async {
    final rebuilder = ValueNotifier(0);
    ScrollController controller;
    const initialOffset = 0.1;
    var targetOffset = initialOffset;

    await tester.pumpWidget(HookBuilder(
      builder: (context) {
        controller = useMemoized(
            () => ScrollController(initialScrollOffset: targetOffset));
        useEffect(() {
          return controller.dispose;
        }, [controller]);
        useValueListenable(rebuilder);
        return SizedBox(
          width: 100,
          height: 200,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: SingleChildScrollView(
              controller: controller,
              child: Column(
                children: List.generate(
                  20,
                  (index) => SizedBox(
                      height: 30,
                      child: Text('$index', textDirection: TextDirection.ltr)),
                ),
              ),
            ),
          ),
        );
      },
    ));
    await tester.pumpAndSettle();
    expect(controller.offset, targetOffset);

    // change offset and rebuild - the value of the controller shouldn't change
    targetOffset = .5;
    rebuilder.notifyListeners();
    await tester.pumpAndSettle();
    expect(controller.offset, initialOffset);
  });

  testWidgets('respects initial value property', (tester) async {
    final rebuilder = ValueNotifier(0);
    const initialValue = TextEditingValue(
      text: 'foo',
      selection: TextSelection.collapsed(offset: 2),
    );
    var targetValue = initialValue;
    TextEditingController controller;

    await tester.pumpWidget(HookBuilder(
      builder: (context) {
        controller = useTextEditingController.fromValue(targetValue);
        useValueListenable(rebuilder);
        return Container();
      },
    ));

    expect(controller.value, targetValue);

    // similar to above - the value should not change after a rebuild
    targetValue = const TextEditingValue(text: 'another');
    rebuilder.notifyListeners();
    await tester.pumpAndSettle();
    expect(controller.value, initialValue);
  });
}
