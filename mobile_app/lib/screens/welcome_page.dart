import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../widgets/common_widgets.dart';
import 'sign_in_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _accepted = false;

  void _proceed() {
    if (!_accepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('please_accept_tc'.tr()),
          backgroundColor: kRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, a, __) => const SignInPage(),
        transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBg(child: Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        child: Column(children: [
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
          const Spacer(),
          // ── Logo ────────────────────────────────────────────────────────
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [kGreen, kCyan]),
              boxShadow: [BoxShadow(color: kGreen.withOpacity(0.4), blurRadius: 40)],
            ),
            child: const Icon(Icons.eco_rounded, color: Colors.black, size: 52)),
          const SizedBox(height: 48),

          // ── Title ───────────────────────────────────────────────────────
          Text('welcome_title'.tr(),
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, height: 1.2),
            textAlign: TextAlign.center),
          const SizedBox(height: 64),

          // ── T&C ─────────────────────────────────────────────────────────
          GCard(
            pad: const EdgeInsets.all(12),
            child: CheckboxListTile(
              value: _accepted,
              onChanged: (v) => setState(() => _accepted = v ?? false),
              title: Text('accept_tc'.tr(), style: const TextStyle(color: kW70, fontSize: 13)),
              activeColor: kGreen,
              checkColor: Colors.black,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
          
          const Spacer(),
          
          // ── Proceed Button ─────────────────────────────────────────────
          BounceScale(
            onTap: _proceed,
            child: Container(
              width: 70, height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _accepted 
                  ? const LinearGradient(colors: [kGreen, kCyan])
                  : const LinearGradient(colors: [kW12, kW12]),
                boxShadow: _accepted 
                  ? [BoxShadow(color: kGreen.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))]
                  : [],
              ),
              child: Icon(Icons.arrow_forward_rounded, 
                color: _accepted ? Colors.black : kW40, size: 32),
            ),
          ),
        ]),
      )),
    ));
  }
}
