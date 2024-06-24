import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:taximate/common/const/colors.dart';
import 'common/provider/router_provider.dart';

void main() {
  runApp(
    ProviderScope(
      child: _App(),
    ),
  );
}

class _App extends ConsumerWidget {
  const _App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      routerConfig: router,
      theme: ThemeData(
        fontFamily: 'GmarketSans',
        primarySwatch: Colors.orange,
        brightness: Brightness.light,
        primaryColor: Colors.orange,
        shadowColor: Colors.orange,
        buttonTheme: ButtonThemeData(
          buttonColor: PRIMARY_COLOR, // Button background color
          textTheme: ButtonTextTheme.primary, // Button text color
          hoverColor: PRIMARY_COLOR,
          focusColor: PRIMARY_COLOR,
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            overlayColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                if (states.contains(MaterialState.pressed)) {
                  return Colors.orange.withOpacity(0.2); // Pressed overlay color
                }
                return null; // Default overlay color
              },
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.orange),
            foregroundColor: MaterialStateProperty.all(Colors.white),
            overlayColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                if (states.contains(MaterialState.pressed)) {
                  return Colors.orange.withOpacity(0.2); // Change pressed color
                }
                return null; // Default overlay color
              },
            ),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.orange, // FAB background color
        ),
        appBarTheme: AppBarTheme(
          color: Colors.orange, // AppBar background color
          iconTheme: IconThemeData(color: Colors.white), // AppBar icon color
          actionsIconTheme: IconThemeData(color: Colors.white), // AppBar actions icon color
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.orange), // Focused input border color
          ),
          labelStyle: TextStyle(color: Colors.orange), // Input label color
        ),
        dialogTheme: DialogTheme(
          backgroundColor: Colors.white, // Dialog background color
          titleTextStyle: TextStyle(color: Colors.black), // Dialog title color
          contentTextStyle: TextStyle(color: Colors.black), // Dialog content color
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: Colors.orange,
          unselectedItemColor: Colors.grey,
        ),
        toggleButtonsTheme: ToggleButtonsThemeData(
          selectedColor: Colors.orange,
          fillColor: Colors.orange.withOpacity(0.2),
          hoverColor: Colors.orange.withOpacity(0.1),
          borderColor: Colors.orange,
          selectedBorderColor: Colors.orange,
          disabledBorderColor: Colors.grey,
          splashColor: Colors.orange.withOpacity(0.3),
        ),
      ),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('ko', 'KR'), // Korean
        // ... other locales your app supports
      ],
    );
  }
}
