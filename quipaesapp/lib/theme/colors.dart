import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Brand ──────────────────────────────────────────────────────────────
  static const primary      = Color(0xFF1E293B);
  static const primaryDark  = Color(0xFF1565C0);
  static const primaryLight = Color(0xFF42A5F5);

  // ── Backgrounds ────────────────────────────────────────────────────────
  static const background     = Color(0xFFBACFE0);
  static const surface        = Colors.white;
  static const backgroundDark = Color(0xFF0F1923);
  static const surfaceDark    = Color(0xFF1A2535);
  
  // ── Semantic ───────────────────────────────────────────────────────────
  static const income   = Color(0xFF2E7D32);
  static const expense  = Color(0xFFC62828);
  static const transfer = Color(0xFF6A1B9A);
  static const warning  = Color(0xFFE65100);

  static const incomeLight   = Color(0xFFA5D6A7);
  static const expenseLight  = Color(0xFFEF9A9A);

  // ── Categories ─────────────────────────────────────────────────────────
  static const categoryFood      = Color(0xFFEF6C00);
  static const categoryLeisure   = Color(0xFF7B1FA2);
  static const categoryBills     = Color(0xFF1976D2);
  static const categorySavings   = Color(0xFF388E3C);
  static const categoryHealth    = Color(0xFFD32F2F);
  static const categoryTransport = Color(0xFF00838F);
  static const categoryFreelance = Color(0xFF558B2F);
  static const categorySalary    = Color(0xFF1565C0);
  static const categoryOther     = Color(0xFF546E7A);

  // ── Chart palette (ordered) ────────────────────────────────────────────
  static const List<Color> chartPalette = [
    categoryFood,
    categoryLeisure,
    categoryBills,
    categorySavings,
    categoryHealth,
    categoryTransport,
    categoryOther,
  ];
}
