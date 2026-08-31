import 'package:fitness/common_widget/round_button.dart';
import 'package:fitness/view/photo_progress/result_view.dart';
import 'package:flutter/material.dart';
import '../../common/colo_extension.dart';
import '../../common/common.dart';
import '../../common_widget/app_snackbar.dart';
import '../../common_widget/sheet_option.dart';
import 'photo_progress_store.dart';

class ComparisonView extends StatefulWidget {
  const ComparisonView({super.key});

  @override
  State<ComparisonView> createState() => _ComparisonViewState();
}

class _ComparisonViewState extends State<ComparisonView> {
  DateTime? _month1;
  DateTime? _month2;

  @override
  void initState() {
    super.initState();
    final months = PhotoProgressStore.months;
    if (months.length >= 2) {
      _month1 = months[1];
      _month2 = months[0];
    } else if (months.length == 1) {
      _month1 = months.first;
    }
  }

  String _label(DateTime? month) => month == null
      ? "Hónap kiválasztása"
      : dateToYearMonth(month);

  Future<void> _pickMonth(bool first) async {
    final months = PhotoProgressStore.months;
    if (months.isEmpty) {
      return;
    }

    final selected = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: TColor.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Material(
          color: TColor.white,
          child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                first ? "Első hónap" : "Második hónap",
                style: TextStyle(
                    color: TColor.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
            ),
            for (final month in months)
              SheetOption(
                title: _label(month),
                trailing: month == (first ? _month1 : _month2)
                    ? Icon(Icons.check, color: TColor.primaryColor1)
                    : null,
                onTap: () => Navigator.pop(context, month),
              ),
          ],
        ),
        ),
      ),
    );

    if (selected == null) {
      return;
    }

    setState(() {
      if (first) {
        _month1 = selected;
      } else {
        _month2 = selected;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: TColor.lightGray,
                borderRadius: BorderRadius.circular(10)),
            child: Image.asset(
              "assets/img/black_btn.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Text(
          "Összehasonlítás",
          style: TextStyle(
              color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      backgroundColor: TColor.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          children: [
            _monthRow(
              title: "Első hónap",
              value: _label(_month1),
              onPressed: () => _pickMonth(true),
            ),
            const SizedBox(height: 15),
            _monthRow(
              title: "Második hónap",
              value: _label(_month2),
              onPressed: () => _pickMonth(false),
            ),
            const Spacer(),
            RoundButton(
                title: "Összehasonlítás",
                onPressed: () {
                  if (_month1 == null || _month2 == null) {
                    showAppSnack(context,
                        message: "Válassz ki két hónapot.",
                        icon: Icons.info_outline);
                    return;
                  }
                  if (_month1 == _month2) {
                    showAppSnack(context,
                        message: "Két különböző hónap kell.",
                        icon: Icons.info_outline);
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResultView(
                        date1: _month1!,
                        date2: _month2!,
                      ),
                    ),
                  );
                }),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  Widget _monthRow({
    required String title,
    required String value,
    required VoidCallback onPressed,
  }) =>
      InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
          decoration: BoxDecoration(
              color: TColor.lightGray, borderRadius: BorderRadius.circular(15)),
          child: Row(
            children: [
              Image.asset("assets/img/date.png", width: 20, height: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style:
                            TextStyle(color: TColor.gray, fontSize: 11)),
                    Text(value,
                        style: TextStyle(
                            color: TColor.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: TColor.gray),
            ],
          ),
        ),
      );
}
