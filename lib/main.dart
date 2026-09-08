import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vire_langues/models/vire_langue.dart';
import 'package:vire_langues/models/serie.dart';
import 'package:vire_langues/models/progression.dart';
import 'package:vire_langues/screens/splash_screen.dart';
import 'package:vire_langues/services/notification_service.dart';
import 'package:vire_langues/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Hive
  await Hive.initFlutter();
  
  // Enregistrer les adapteurs
  Hive.registerAdapter(VireLangueAdapter());
  Hive.registerAdapter(SerieAdapter());
  Hive.registerAdapter(ProgressionAdapter());
  
  // Ouvrir les boîtes
  await Hive.openBox<VireLangue>('vire_langues');
  await Hive.openBox<Serie>('series');
  await Hive.openBox<Progression>('progression');
  
  // Initialiser les notifications
  await NotificationService().init();
  
  // Forcer l'orientation portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  // Masquer la barre de statut
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(
    const ProviderScope(
      child: VireLanguesApp(),
    ),
  );
}

class VireLanguesApp extends StatelessWidget {
  const VireLanguesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vire-Langues',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('fr', 'FR')],
      locale: const Locale('fr', 'FR'),
    );
  }
}
