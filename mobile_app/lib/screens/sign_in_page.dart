import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:easy_localization/easy_localization.dart';
import '../widgets/common_widgets.dart';
import 'login_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;

  void _next() {
    final email = _email.text.trim();
    if (email.isEmpty || !email.endsWith('@gmail.com')) {
      _showErr('err_invalid_gmail'.tr());
      return;
    }
    if (email.length < 6 || _pass.text.length < 6) {
      _showErr('err_too_short'.tr());
      return;
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, a, __) => const LoginPage(),
        transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _showErr(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: kRed, behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _googleSignIn() async {
    showDialog(
      context: context,
      builder: (ctx) => Center(
        child: GCard(
          pad: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.account_circle_outlined, color: kCyan, size: 40),
              const SizedBox(height: 16),
              Text('select_account'.tr(), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              _AccountItem(
                email: 'karthik.n@gmail.com', 
                onTap: () { Navigator.pop(ctx); _next(); }
              ),
              const SizedBox(height: 12),
              _AccountItem(
                email: 'rubber.expert@gmail.com', 
                onTap: () { Navigator.pop(ctx); _next(); }
               ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel', style: TextStyle(color: kW40))
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBg(child: Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Back Button ────────────────────────────────────────────────
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: kW70, size: 20)),
          const SizedBox(height: 32),

          // ── Title ──────────────────────────────────────────────────────
          Text('sign_in_title'.tr(),
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('Please sign in to continue', style: TextStyle(color: kW40, fontSize: 14)),
          const SizedBox(height: 40),

          // ── Inputs ─────────────────────────────────────────────────────
          _Input(label: 'email'.tr(), hint: 'Enter your email', controller: _email, icon: Icons.mail_outline_rounded),
          const SizedBox(height: 20),
          _Input(label: 'password'.tr(), hint: 'Enter your password', controller: _pass, icon: Icons.lock_outline_rounded, obscure: true),
          const SizedBox(height: 32),

          // ── Action ─────────────────────────────────────────────────────
          GBtn(label: 'sign_in_btn'.tr(), onTap: _loading ? null : _next, loading: _loading),
          const SizedBox(height: 24),

          // ── Divider ────────────────────────────────────────────────────
          Row(children: [
            Expanded(child: Container(height: 1, color: kW12)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('OR', style: TextStyle(color: kW12, fontSize: 12, fontWeight: FontWeight.bold))),
            Expanded(child: Container(height: 1, color: kW12)),
          ]),
          const SizedBox(height: 24),

          // ── Social ─────────────────────────────────────────────────────
          OBtn(icon: Icons.g_mobiledata_rounded, label: 'sign_in_google'.tr(), onTap: _loading ? null : _googleSignIn),
          
          const SizedBox(height: 48),
          
          // ── Next / Skip ────────────────────────────────────────────────
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _next,
              icon: Text('next'.tr(), style: const TextStyle(color: kCyan, fontWeight: FontWeight.bold)),
              label: const Icon(Icons.arrow_forward_rounded, color: kCyan, size: 18)),
          ),
        ]),
      )),
    ));
  }
}

class _Input extends StatelessWidget {
  final String label, hint;
  final TextEditingController controller;
  final IconData icon;
  final bool obscure;
  const _Input({required this.label, required this.hint, required this.controller, required this.icon, this.obscure = false});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: kCyan, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
      const SizedBox(height: 10),
      GCard(
        pad: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: kW12, fontSize: 14),
            border: InputBorder.none,
            icon: Icon(icon, color: kW40, size: 20),
          ),
        ),
      ),
    ]);
  }
}

class _AccountItem extends StatelessWidget {
  final String email;
  final VoidCallback onTap;
  const _AccountItem({required this.email, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BounceScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kW12),
        ),
        child: Row(children: [
          Container(
            width: 32, height: 32,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: kCyan),
            child: Center(child: Text(email[0].toUpperCase(), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 12),
          Text(email, style: const TextStyle(color: kW70, fontSize: 14)),
        ]),
      ),
    );
  }
}
