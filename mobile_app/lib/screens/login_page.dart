import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../widgets/common_widgets.dart';
import 'shell.dart';

final userRole = ValueNotifier<String>('');

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  void _select(BuildContext ctx, String role) {
    userRole.value = role;
    Navigator.of(ctx).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, a, __) => const Shell(),
        transitionsBuilder: (_, a, __, child) =>
          FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBg(child: Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(children: [
          const SizedBox(height: 16),
          // ── Language Selector ──────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              DropdownButton<Locale>(
                value: context.locale,
                dropdownColor: kCard,
                icon: const Icon(Icons.language, color: kCyan, size: 20),
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: Locale('en'), child: Text('English', style: TextStyle(color: Colors.white, fontSize: 13))),
                  DropdownMenuItem(value: Locale('kn'), child: Text('ಕನ್ನಡ', style: TextStyle(color: Colors.white, fontSize: 13))),
                  DropdownMenuItem(value: Locale('hi'), child: Text('हिंदी', style: TextStyle(color: Colors.white, fontSize: 13))),
                  DropdownMenuItem(value: Locale('ml'), child: Text('മലയാളം', style: TextStyle(color: Colors.white, fontSize: 13))),
                  DropdownMenuItem(value: Locale('ta'), child: Text('தமிழ்', style: TextStyle(color: Colors.white, fontSize: 13))),
                ],
                onChanged: (Locale? locale) {
                  if (locale != null) context.setLocale(locale);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Logo & title ─────────────────────────────────────────────────
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [kGreen, kCyan],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
              boxShadow: [BoxShadow(color: kGreen.withOpacity(0.5), blurRadius: 30)],
            ),
            child: const Icon(Icons.eco_rounded, color: Colors.black, size: 42)),
          const SizedBox(height: 20),
          Text('app_title'.tr(),
            style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900),
            textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('app_subtitle'.tr(),
            style: const TextStyle(color: kW40, fontSize: 13)),
          const SizedBox(height: 48),

          // ── Role selector label ─────────────────────────────────────────
          Align(
            alignment: Alignment.centerLeft,
            child: Text('select_role'.tr(),
              style: const TextStyle(color: kCyan, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5))),
          const SizedBox(height: 16),

          // ── Farmer card ─────────────────────────────────────────────────
          _RoleCard(
            icon: Icons.agriculture_rounded,
            title: 'role_farmer_title'.tr(),
            subtitle: 'role_farmer_desc'.tr(),
            features: ['role_farmer_f1'.tr(), 'role_farmer_f2'.tr(), 'role_farmer_f3'.tr()],
            color: kGreen,
            onTap: () => _select(context, 'farmer'),
          ),
          const SizedBox(height: 16),

          // ── Officer card ──────────────────────────────────────────────
          _RoleCard(
            icon: Icons.manage_accounts_rounded,
            title: 'role_officer_title'.tr(),
            subtitle: 'role_officer_desc'.tr(),
            features: ['role_officer_f1'.tr(), 'role_officer_f2'.tr(), 'role_officer_f3'.tr()],
            color: kCyan,
            onTap: () => _select(context, 'officer'),
          ),

          const SizedBox(height: 16),
        ]),
      ))),
    ));
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final List<String> features;
  final Color color;
  final VoidCallback onTap;
  const _RoleCard({required this.icon, required this.title, required this.subtitle,
    required this.features, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
        boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 20, spreadRadius: 2)],
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.15),
            border: Border.all(color: color.withOpacity(0.4))),
          child: Icon(icon, color: color, size: 26)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
            style: TextStyle(color: color, fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(subtitle,
            style: const TextStyle(color: kW70, fontSize: 12)),
          const SizedBox(height: 10),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(f, style: const TextStyle(color: kW40, fontSize: 12)))),
        ])),
        Icon(Icons.arrow_forward_ios_rounded, color: color.withOpacity(0.6), size: 16),
      ]),
    ));
}
