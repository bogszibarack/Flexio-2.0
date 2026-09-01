import 'package:fitness/tool/screenshot_app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture $screenshotScreen screenshot', (tester) async {
    await initializeDateFormatting('hu');
    await tester.pumpWidget(const ProviderScope(child: ScreenshotApp()));
    await tester.pumpAndSettle();
    await Future<void>.delayed(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    await binding.convertFlutterSurfaceToImage();
    await binding.takeScreenshot(screenshotScreen);
  });
}
