import "package:flutter/material.dart";
import "package:flutter_architecture/di/app_dependencies.dart";
import "package:flutter_architecture/main.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  testWidgets("Commandの保存後イベントを受け、Queryで二画面の表示を更新する", (tester) async {
    await tester.pumpWidget(CounterApp(createBloc: AppDependencies().createCounterBloc));
    await tester.pumpAndSettle();
    expect(find.text("0"), findsOneWidget);
    await tester.tap(find.text("Open another screen"));
    await tester.pumpAndSettle();
    await tester.tap(find.text("+1"));
    await tester.pumpAndSettle();
    expect(find.text("1"), findsOneWidget);
    expect(find.text("1", skipOffstage: false), findsNWidgets(2));
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text("1"), findsOneWidget);
    await tester.tap(find.text("+1"));
    await tester.pumpAndSettle();
    expect(find.text("2"), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
