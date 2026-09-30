import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../common/app_haptics.dart';
import '../../common/colo_extension.dart';
import '../../common_widget/round_button.dart';
import '../../data/models/food_item.dart';
import '../../data/providers.dart';
import 'manual_food_view.dart';

/// Vonalkód-olvasó. A feloldás létrája: helyi gyorsítótár, Supabase katalógus,
/// majd élő Open Food Facts hívás. Ha egyik sem tudja, kézi felvitel jön.
///
/// Szimulátoron a kamera nem működik, ezért van kézi kódbeviteli út is.
class BarcodeScanView extends ConsumerStatefulWidget {
  const BarcodeScanView({super.key});

  @override
  ConsumerState<BarcodeScanView> createState() => _BarcodeScanViewState();
}

class _BarcodeScanViewState extends ConsumerState<BarcodeScanView> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
    ],
  );

  final BarcodeScanGate _gate = BarcodeScanGate();
  String? _status;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isResolving => _gate.isBusy;

  Future<void> _onDetect(BarcodeCapture capture) async {
    final code =
        _gate.accept(capture.barcodes.map((barcode) => barcode.rawValue));
    if (code == null) {
      return;
    }
    await _resolve(code);
  }

  /// Hívás előtt a zárnak már foglaltnak kell lennie (lásd [BarcodeScanGate]).
  /// A zár a kézi felvitel teljes idejére érvényes, és a kamerát is
  /// leállítjuk: különben a háttérben futó olvasó ugyanazt a kódot újra
  /// észleli, és minden találatnál újabb kézi felviteli oldalt nyit.
  Future<void> _resolve(String code) async {
    setState(() {
      _status = "Termék keresése: $code";
    });
    await _stopCamera();

    FoodItem? food;
    try {
      food = await ref.read(foodRepositoryProvider).resolveBarcode(code);
    } on Object catch (error) {
      // Hálózati hiba: a kézi felvitel felé visszük, nem ragad be a zár.
      debugPrint("Vonalkód feloldása sikertelen: $error");
    }

    if (!mounted) {
      return;
    }

    if (food != null) {
      AppHaptics.scanned();
      Navigator.pop(context, food);
      return;
    }

    AppHaptics.warning();
    setState(() {
      _status = "Ezt a vonalkódot nem találjuk. Vedd fel kézzel a csomagolás adataival.";
    });

    final created = await Navigator.push<FoodItem>(
      context,
      MaterialPageRoute(
        builder: (context) => ManualFoodView(barcode: code),
      ),
    );

    if (!mounted) {
      return;
    }

    if (created != null) {
      Navigator.pop(context, created);
      return;
    }

    // Kézi felvitel megszakítva: újra lehet olvasni.
    setState(() {
      _gate.release();
      _status = null;
    });
    await _startCamera();
  }

  Future<void> _stopCamera() async {
    try {
      await _controller.stop();
    } catch (_) {
      // Nincs kamera (szimulátor) vagy már leállt - nincs teendő.
    }
  }

  Future<void> _startCamera() async {
    try {
      await _controller.start();
    } catch (_) {
      // Nincs kamera (szimulátor) - a kézi kódbevitel továbbra is működik.
    }
  }

  Future<void> _enterManually() async {
    final controller = TextEditingController();

    final code = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TColor.white,
        title: Text(
          "Vonalkód kézzel",
          style: TextStyle(
            color: TColor.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Például 5998200210014",
            hintStyle: TextStyle(color: TColor.gray, fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Mégse", style: TextStyle(color: TColor.gray)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(
              "Keresés",
              style: TextStyle(
                color: TColor.primaryColor1,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (code == null || !mounted) {
      return;
    }
    final accepted = _gate.accept([code]);
    if (accepted == null) {
      return;
    }
    await _resolve(accepted);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    // Szimulátoron nincs kamera, ezért ott azonnal a kézi bevitelt ajánljuk.
    const canScan = !kIsWeb;

    return Scaffold(
      backgroundColor: TColor.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: Colors.white),
        ),
        title: const Text(
          "Vonalkód beolvasása",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _controller.toggleTorch(),
            icon: const Icon(Icons.flash_on, color: Colors.white),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (canScan)
            MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
              errorBuilder: (context, error) => _cameraError(error),
            )
          else
            _cameraError(null),
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Container(
                  width: media.width * 0.72,
                  height: media.width * 0.44,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white70, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 30,
            child: Column(
              children: [
                if (_status != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      _status!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 12),
                    ),
                  ),
                if (_isResolving)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 14),
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                SizedBox(
                  height: 46,
                  child: RoundButton(
                    title: "Kód beírása kézzel",
                    onPressed: _enterManually,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cameraError(MobileScannerException? error) => Center(
        child: Padding
          (padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            error == null
                ? "Ezen a platformon nincs kamera. Írd be a kódot kézzel."
                : "A kamera nem elérhető: ${error.errorCode.name}. Ellenőrizd az engedélyt, vagy írd be a kódot kézzel. Szimulátoron nincs kamera, ehhez fizikai eszköz kell.",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
      );
}

/// A beolvasás zárja. Egyszerre egy kódot dolgozunk fel; amíg az tart (a
/// keresés és a kézi felvitel teljes ideje alatt), minden további észlelést
/// eldobunk. Ez akadályozza meg, hogy a kamera ugyanarra a kódra újra és újra
/// megnyissa a kézi felviteli oldalt.
class BarcodeScanGate {
  static const int minimumLength = 8;

  bool _busy = false;

  bool get isBusy => _busy;

  /// Az első érvényes kód, és a zár lefoglalása. `null`, ha foglalt, vagy
  /// nincs érvényes kód.
  String? accept(Iterable<String?> rawValues) {
    if (_busy) {
      return null;
    }
    for (final raw in rawValues) {
      final code = raw?.trim() ?? "";
      if (code.length >= minimumLength) {
        _busy = true;
        return code;
      }
    }
    return null;
  }

  void release() => _busy = false;
}
