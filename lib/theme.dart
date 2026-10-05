import 'package:flutter/material.dart';

/// 白ベースの配色。初期版は独自のダーク配色を持たない。
class AppColors {
  AppColors._();

  static const background = Color(0xFFFFFFFF);

  /// まとまり（グループ）の面にだけ使う淡いグレー。
  static const subtle = Color(0xFFF5F6F8);

  /// 切り替えボタンの溝など、面の中の一段濃いグレー。
  static const track = Color(0xFFE9ECF0);
  static const hairline = Color(0xFFE3E6EB);
  static const border = Color(0xFFD5D9DF);

  static const text = Color(0xFF1F2937);

  /// 補足文字。白背景で 4.5:1 以上を保つ濃さにする。
  static const textSecondary = Color(0xFF4B5563);

  static const primary = Color(0xFF0B6E5F);

  /// 補助ボタン・選択中の面に使う淡い青。
  static const primarySoft = Color(0xFFE3F2EE);

  static const danger = Color(0xFFC42B2B);
  static const success = Color(0xFF0F7B5A);
  static const successSoft = Color(0xFFE5F4EE);
  static const caution = Color(0xFF9A5B00);
  static const cautionSoft = Color(0xFFFFF4E0);
}

/// 角丸の段階。大きなまとまりほど大きく、操作部品はピル型にする。
class AppRadius {
  AppRadius._();

  static const group = 22.0;
  static const inner = 16.0;
  static const pill = 999.0;
}

ThemeData buildTheme() {
  const scheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primarySoft,
    onPrimaryContainer: AppColors.primary,
    secondary: AppColors.primary,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.primarySoft,
    onSecondaryContainer: AppColors.primary,
    error: AppColors.danger,
    onError: Colors.white,
    surface: AppColors.background,
    onSurface: AppColors.text,
    surfaceContainerHighest: AppColors.subtle,
    surfaceContainerHigh: AppColors.subtle,
    surfaceContainer: AppColors.subtle,
    surfaceContainerLow: AppColors.background,
    surfaceContainerLowest: AppColors.background,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.border,
    outlineVariant: AppColors.hairline,
  );

  const pillShape = StadiumBorder();
  const buttonText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    splashFactory: InkSparkle.splashFactory,
    textTheme: const TextTheme(
      displaySmall: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: AppColors.text,
        height: 1.2,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: AppColors.text,
        height: 1.25,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
      bodyLarge: TextStyle(fontSize: 18, color: AppColors.text, height: 1.5),
      bodyMedium: TextStyle(fontSize: 17, color: AppColors.text, height: 1.5),
      bodySmall: TextStyle(
        fontSize: 15,
        color: AppColors.textSecondary,
        height: 1.45,
      ),
      labelLarge: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.text,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      centerTitle: true,
      toolbarHeight: 56,
      titleTextStyle: TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 58),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        textStyle: buttonText,
        shape: pillShape,
        disabledBackgroundColor: AppColors.track,
        disabledForegroundColor: AppColors.textSecondary,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 56),
        textStyle: buttonText,
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.border),
        shape: pillShape,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 48),
        foregroundColor: AppColors.primary,
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        shape: pillShape,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.hairline,
      thickness: 1,
      space: 1,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(28)),
      ),
      titleTextStyle: TextStyle(
        fontSize: 21,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      dragHandleColor: AppColors.border,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.subtle,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.inner),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.inner),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      labelStyle: const TextStyle(fontSize: 17, color: AppColors.textSecondary),
      hintStyle: const TextStyle(fontSize: 17, color: AppColors.textSecondary),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.text,
      shape: StadiumBorder(),
      contentTextStyle: TextStyle(fontSize: 17, color: Colors.white),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
    ),
  );
}
