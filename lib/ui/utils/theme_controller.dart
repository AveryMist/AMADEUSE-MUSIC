import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:palette_generator/palette_generator.dart';
import '/utils/helper.dart';

class ThemeController extends GetxController {
  final primaryColor = Colors.deepPurple[400].obs;
  final textColor = Colors.white24.obs;
  final themedata = Rxn<ThemeData>();

  /// The method channel for setting the title bar color on Windows.
  final platform = const MethodChannel('win_titlebar_color');
  String? currentSongId;
  late Brightness systemBrightness;

  ThemeController() {
    systemBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;

    primaryColor.value =
        Color(Hive.box('appPrefs').get("themePrimaryColor") ?? 4278199603);

    // Initialiser avec un thème par défaut pour éviter les valeurs null
    themedata.value = _createThemeData(null, ThemeType.dark);

    changeThemeModeType(
        ThemeType.values[Hive.box('appPrefs').get("themeModeType") ?? 0]);

    _listenSystemBrightness();

    super.onInit();
  }

  void _listenSystemBrightness() {
    final platformDispatcher = WidgetsBinding.instance.platformDispatcher;
    platformDispatcher.onPlatformBrightnessChanged = () {
      systemBrightness = platformDispatcher.platformBrightness;
      changeThemeModeType(
          ThemeType.values[Hive.box('appPrefs').get("themeModeType")],
          sysCall: true);
    };
  }

  void changeThemeModeType(dynamic value, {bool sysCall = false}) {
    if (value == ThemeType.system) {
      themedata.value = _createThemeData(
          null,
          systemBrightness == Brightness.light
              ? ThemeType.light
              : ThemeType.dark);
    } else {
      // Supprimer la condition sysCall pour forcer la mise à jour
      themedata.value = _createThemeData(
          value == ThemeType.dynamic
              ? _createMaterialColor(primaryColor.value!)
              : null,
          value);
    }
    // Forcer la mise à jour de l'interface
    themedata.refresh();
    setWindowsTitleBarColor(themedata.value!.scaffoldBackgroundColor);
  }

  void setTheme(ImageProvider imageProvider, String songId) async {
    if (songId == currentSongId) return;
    PaletteGenerator generator = await PaletteGenerator.fromImageProvider(
        ResizeImage(imageProvider, height: 200, width: 200));

    final paletteColor = generator.dominantColor ??
        generator.darkMutedColor ??
        generator.darkVibrantColor ??
        generator.lightMutedColor ??
        generator.lightVibrantColor;

    if (paletteColor == null) return;

    primaryColor.value = paletteColor.color;
    textColor.value = paletteColor.bodyTextColor;

    if (GetPlatform.isDesktop) {
      final hsl = HSLColor.fromColor(paletteColor.color);
      primaryColor.value = hsl.withSaturation(
        (hsl.saturation * 1.2).clamp(0.0, 1.0)
      ).withLightness(
        hsl.lightness < 0.5 ? 0.15 : hsl.lightness * 0.8
      ).toColor();
    } else {
      if (paletteColor.color.computeLuminance() > 0.10) {
        primaryColor.value = paletteColor.color.withLightness(0.10);
        textColor.value = Colors.white54;
      }
    }

    final MaterialColor primarySwatch = _createMaterialColor(primaryColor.value!);
    themedata.value = _createThemeData(primarySwatch, ThemeType.dynamic,
        textColor: textColor.value,
        titleColorSwatch: _createMaterialColor(textColor.value));
    currentSongId = songId;
    Hive.box('appPrefs').put("themePrimaryColor", (primaryColor.value!).value);
    // Forcer la mise à jour de l'interface
    themedata.refresh();
    setWindowsTitleBarColor(themedata.value!.scaffoldBackgroundColor);

    if (GetPlatform.isDesktop) {
      _triggerColorChangeAnimation();
    }
  }

  void _triggerColorChangeAnimation() {
    printINFO("Color theme changed - triggering desktop animations");
  }

  ThemeData _createThemeData(MaterialColor? primarySwatch, ThemeType themeType,
      {MaterialColor? titleColorSwatch, Color? textColor}) {
    if (themeType == ThemeType.dynamic) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.light,
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.white.withOpacity(0.002),
            systemNavigationBarDividerColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.light,
            systemStatusBarContrastEnforced: false,
            systemNavigationBarContrastEnforced: true),
      );

      final baseTheme = ThemeData(
          useMaterial3: false,
          brightness: Brightness.dark,
          colorScheme: primarySwatch != null 
              ? ColorScheme.fromSwatch(
                  primarySwatch: primarySwatch,
                  brightness: Brightness.dark)
              : const ColorScheme.dark(),
          dialogBackgroundColor: primarySwatch?[700] ?? Colors.black,
          cardColor: primarySwatch?[600] ?? Colors.grey[800],
          primaryColorLight: primarySwatch?[400] ?? Colors.deepPurple,
          primaryColorDark: primarySwatch?[700] ?? Colors.black,
          canvasColor: primarySwatch?[700] ?? Colors.black,
          bottomSheetTheme: BottomSheetThemeData(
              backgroundColor: primarySwatch?[600] ?? Colors.grey[800],
              modalBarrierColor: primarySwatch?[400] ?? Colors.deepPurple),
          textTheme: TextTheme(
            titleLarge: const TextStyle(
                fontSize: 23, fontWeight: FontWeight.bold, color: Colors.white),
            titleMedium: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white),
            titleSmall: TextStyle(color: primarySwatch?[100] ?? Colors.white),
            bodyMedium: TextStyle(color: primarySwatch?[100] ?? Colors.white),
            labelMedium: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 23,
                color: textColor ?? primarySwatch?[50] ?? Colors.white),
            labelSmall: TextStyle(
                fontSize: 15,
                color: titleColorSwatch?[900] ?? primarySwatch?[100] ?? Colors.white,
                letterSpacing: 0,
                fontWeight: FontWeight.bold),
          ),
          indicatorColor: Colors.white,
          progressIndicatorTheme: ProgressIndicatorThemeData(
              linearTrackColor: (primarySwatch?[300] ?? Colors.deepPurple).computeLuminance() > 0.3
                  ? Colors.black54
                  : Colors.white70,
              color: textColor),
          navigationRailTheme: NavigationRailThemeData(
              backgroundColor: primarySwatch?[700] ?? Colors.black,
              selectedIconTheme: const IconThemeData(color: Colors.white),
              unselectedIconTheme: IconThemeData(color: primarySwatch?[100] ?? Colors.white),
              selectedLabelTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
              unselectedLabelTextStyle: TextStyle(
                  color: primarySwatch?[100] ?? Colors.white, fontWeight: FontWeight.bold)),
          sliderTheme: SliderThemeData(
            inactiveTrackColor: primarySwatch?[300] ?? Colors.grey,
            activeTrackColor: textColor,
            valueIndicatorColor: primarySwatch?[400] ?? Colors.deepPurple,
            thumbColor: Colors.white,
          ),
          textSelectionTheme: TextSelectionThemeData(
              cursorColor: primarySwatch?[200] ?? Colors.white,
              selectionColor: primarySwatch?[200] ?? Colors.white,
              selectionHandleColor: primarySwatch?[200] ?? Colors.white)
          );
      
      Color buttonBackground = primarySwatch?[500] ?? Colors.deepPurple;
      Color buttonForeground = buttonBackground.computeLuminance() > 0.5 ? Colors.black : Colors.white;
      Color buttonBorder = buttonForeground.withOpacity(0.5);
      return baseTheme.copyWith(
          textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(buttonBackground),
              foregroundColor: MaterialStateProperty.all(buttonForeground),
              side: MaterialStateProperty.all(BorderSide(color: buttonBorder, width: 1)),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            ),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: primarySwatch?[700] ?? Colors.black,
              foregroundColor: textColor ?? Colors.white),
      );
    } else if (themeType == ThemeType.dark) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.light,
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.white.withOpacity(0.002),
            systemNavigationBarDividerColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.light,
            systemStatusBarContrastEnforced: false,
            systemNavigationBarContrastEnforced: true),
      );
      final baseTheme = ThemeData(
          useMaterial3: false,
          brightness: Brightness.dark,
          canvasColor: Colors.black,
          primaryColor: Colors.black,
          primaryColorDark: Colors.black,
          primaryColorLight: Colors.grey[850],
          colorScheme: ColorScheme.fromSwatch(
              accentColor: Colors.grey[700], brightness: Brightness.dark),
          progressIndicatorTheme: ProgressIndicatorThemeData(
              color: Colors.grey[700], linearTrackColor: Colors.white),
          textTheme: const TextTheme(
              titleLarge: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
              titleMedium: TextStyle(
                fontWeight: FontWeight.bold,
              ),
              titleSmall: TextStyle(),
              labelMedium: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 23,
              ),
              labelSmall: TextStyle(
                  fontSize: 15, letterSpacing: 0, fontWeight: FontWeight.bold),
              bodyMedium: TextStyle(color: Colors.grey)),
          navigationRailTheme: const NavigationRailThemeData(
              backgroundColor: Colors.black,
              selectedIconTheme: IconThemeData(
                color: Colors.white,
              ),
              unselectedIconTheme: IconThemeData(color: Colors.white38),
              selectedLabelTextStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
              unselectedLabelTextStyle: TextStyle(
                  color: Colors.white38, fontWeight: FontWeight.bold)),
          bottomSheetTheme: const BottomSheetThemeData(
              backgroundColor: Colors.black, modalBarrierColor: Colors.black),
          sliderTheme: const SliderThemeData(
            inactiveTrackColor: Colors.white30,
            activeTrackColor: Colors.white,
            valueIndicatorColor: Colors.black38,
            thumbColor: Colors.white,
          ),
          textSelectionTheme: TextSelectionThemeData(
              cursorColor: Colors.grey[700],
              selectionColor: Colors.grey[700],
              selectionHandleColor: Colors.grey[700]),
          inputDecorationTheme: const InputDecorationTheme(
              focusColor: Colors.white,
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white))),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white));
      return baseTheme.copyWith(
          textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme));
    } else {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.dark,
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.white.withOpacity(0.002),
            systemNavigationBarDividerColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.dark,
            systemStatusBarContrastEnforced: false,
            systemNavigationBarContrastEnforced: false),
      );
      final baseTheme = ThemeData(
          useMaterial3: false,
          brightness: Brightness.light,
          canvasColor: Colors.white,
          colorScheme: ColorScheme.fromSwatch(
              accentColor: Colors.grey[400],
              brightness: Brightness.light),
          primaryColor: Colors.white,
          primaryColorLight: Colors.grey[300],
          progressIndicatorTheme: ProgressIndicatorThemeData(
              linearTrackColor: Colors.grey[700], color: Colors.grey[400]),
          textTheme: TextTheme(
              titleLarge: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
              titleMedium: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              titleSmall: const TextStyle(),
              labelMedium: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 23,
              ),
              labelSmall: const TextStyle(
                  fontSize: 15, letterSpacing: 0, fontWeight: FontWeight.bold),
              bodyMedium: TextStyle(color: Colors.grey[700])),
          navigationRailTheme: NavigationRailThemeData(
              backgroundColor: Colors.white,
              selectedIconTheme: const IconThemeData(color: Colors.black),
              unselectedIconTheme: IconThemeData(color: Colors.grey[800]),
              selectedLabelTextStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
              unselectedLabelTextStyle: TextStyle(
                  color: Colors.grey[800], fontWeight: FontWeight.bold)),
          bottomSheetTheme: const BottomSheetThemeData(
              backgroundColor: Colors.white, modalBarrierColor: Colors.white),
          sliderTheme: SliderThemeData(
            inactiveTrackColor: Colors.black38,
            activeTrackColor: Colors.grey[800],
            valueIndicatorColor: Colors.white38,
            thumbColor: Colors.grey[800],
          ),
          textSelectionTheme: TextSelectionThemeData(
              cursorColor: Colors.grey[400],
              selectionColor: Colors.grey[400],
              selectionHandleColor: Colors.grey[400]),
          dialogTheme: DialogThemeData(backgroundColor: Colors.grey[200]),
          inputDecorationTheme: const InputDecorationTheme(
              focusColor: Colors.black,
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black))),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black));
      return baseTheme.copyWith(
          textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme));
    }
  }

  MaterialColor _createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }

  Future<void> setWindowsTitleBarColor(Color color) async {
    if (!GetPlatform.isWindows) return;
    try {
      await Future.delayed(
          const Duration(milliseconds: 350),
          () async => await platform.invokeMethod('setTitleBarColor', {
                'r': color.red,
                'g': color.green,
                'b': color.blue,
              }));
    } on PlatformException catch (e) {
      printERROR("Failed to set title bar color: ${e.message}");
    }
  }
}

extension ComplementaryColor on Color {
  Color get complementaryColor => getComplementaryColor(this);
  Color getComplementaryColor(Color color) {
    int r = 255 - color.red;
    int g = 255 - color.green;
    int b = 255 - color.blue;
    return Color.fromARGB(color.alpha, r, g, b);
  }
}

extension ColorWithHSL on Color {
  HSLColor get hsl => HSLColor.fromColor(this);

  Color withSaturation(double saturation) {
    return hsl.withSaturation(clampDouble(saturation, 0.0, 1.0)).toColor();
  }

  Color withLightness(double lightness) {
    return hsl.withLightness(clampDouble(lightness, 0.0, 1.0)).toColor();
  }

  Color withHue(double hue) {
    return hsl.withHue(clampDouble(hue, 0.0, 360.0)).toColor();
  }
}

extension HexColor on Color {
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

enum ThemeType {
  dynamic,
  system,
  dark,
  light,
}
