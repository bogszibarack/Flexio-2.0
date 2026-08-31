import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

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

  bool _isResolving = false;
  String? _status;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isResolving) {
      return;
    }

    final code = capture.barcodes
        .map((barcode) => barcode.rawValue ?? "")
        .firstWhere((value) => value.trim().length >= 8, orElse: () => "");

    if (code.isEmpty) {
      return;
    }

    await _resolve(code);
  }

  Future<void> _resolve(String code) async {
    setState(() {
      _isResolving = true;
      _status = "Termék keresése: $code";
    });

    final food = await ref.read(foodRepositoryProvider).resolveBarcode(code);

    if (!mounted) {
      return;
    }

    if (food != null) {
      Navigator.pop(context, food);
      return;
    }

    setState(() {
      _isResolving = false;
      _status = "Ezt a vonalkódot nem találjuk. Vedd fel kézzel a csomagolás adataival.";
    });

    final created = await Navigator.push<FoodItem>(
      context,
      MaterialPageRoute(
        builder: (context) => ManualFoodView(barcode: code),
      ),
    );

    if (created != null && mounted) {
      Navigator.pop(context, created);
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

    if (code == null || code.length < 8 || !mounted) {
      return;
    }

    await _resolve(code);
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
