import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui' as ui;
import '../widgets/common_widgets.dart';
import '../providers/history_store.dart';
import 'predict_page.dart';
import 'history_page.dart';
import 'analytics_page.dart';
import 'disease_page.dart';
import 'about_page.dart';
import 'login_page.dart';

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _idx = 0;

  static const _officerPages = [PredictPage(), HistoryPage(), AnalyticsPage(), DiseasePage(), AboutPage()];
  static const _farmerPages  = [PredictPage(), HistoryPage(), DiseasePage(), AboutPage()];

  List<Widget> get _pages => userRole.value == 'officer' ? _officerPages : _farmerPages;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: userRole,
      builder: (_, role, __) {
        final isOfficer = role == 'officer';
        final clampedIdx = _idx.clamp(0, _pages.length - 1);
        if (clampedIdx != _idx) _idx = clampedIdx;

        return Scaffold(
          body: _pages[_idx],
          bottomNavigationBar: ClipRRect(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
              child: Container(
                decoration: BoxDecoration(
                  color: kCard.withOpacity(0.45),
                  border: const Border(top: BorderSide(color: kW12)),
                ),
            child: ListenableBuilder(
              listenable: HistoryStore(),
              builder: (_, __) => BottomNavigationBar(
                currentIndex: _idx,
                onTap: (i) => setState(() => _idx = i),
                backgroundColor: Colors.transparent,
                elevation: 0, type: BottomNavigationBarType.fixed,
                selectedItemColor: isOfficer ? kCyan : kGreen,
                unselectedItemColor: kW40,
                selectedFontSize: 11, unselectedFontSize: 11,
                items: [
                  BottomNavigationBarItem(icon: const Icon(Icons.camera_alt_outlined), activeIcon: const Icon(Icons.camera_alt), label: 'nav_predict'.tr()),
                  BottomNavigationBarItem(
                    icon: Stack(children: [
                      const Icon(Icons.history_outlined),
                      if (HistoryStore().records.isNotEmpty)
                        Positioned(right: 0, top: 0, child: Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(color: kGreen, shape: BoxShape.circle),
                        )),
                    ]),
                    activeIcon: const Icon(Icons.history), label: 'nav_history'.tr(),
                  ),
                  if (isOfficer)
                    BottomNavigationBarItem(icon: const Icon(Icons.bar_chart_outlined), activeIcon: const Icon(Icons.bar_chart), label: 'nav_analytics'.tr()),
                  BottomNavigationBarItem(icon: const Icon(Icons.biotech_outlined), activeIcon: const Icon(Icons.biotech), label: 'nav_diseases'.tr()),
                  BottomNavigationBarItem(icon: const Icon(Icons.info_outline), activeIcon: const Icon(Icons.info), label: 'nav_about'.tr()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
      },
    );
  }
}
