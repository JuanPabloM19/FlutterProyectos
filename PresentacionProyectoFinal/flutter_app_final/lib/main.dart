import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_final/firebase_options.dart';
import 'package:flutter_app_final/providers/equipment_provider.dart';
import 'package:flutter_app_final/providers/event_provider.dart';
import 'package:flutter_app_final/providers/user_provider.dart';
import 'package:flutter_app_final/routes/routes.dart';
import 'package:flutter_app_final/providers/weather_provider.dart';
import 'package:flutter_app_final/utils/databaseHelper.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseFirestore.instance.clearPersistence();
  await DatabaseHelper().syncDataToFirebase();

  initializeDateFormatting().then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<auth.User?>(
      future: auth.FirebaseAuth.instance.authStateChanges().first,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = snapshot.data;
        final uid = user?.uid;

        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => WeatherProvider()),
            ChangeNotifierProvider(
                create: (context) => EventProvider()..setUserId(uid ?? '')),
            ChangeNotifierProvider(
                create: (context) => UserProvider()..loadUserData()),
            ChangeNotifierProvider(create: (context) => EquipmentProvider()),
          ],
          child: FutureBuilder<SharedPreferences>(
            future: SharedPreferences.getInstance(),
            builder: (context, prefsSnapshot) {
              if (!prefsSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              bool isAdmin = prefsSnapshot.data?.getBool('isAdmin') ?? false;

              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Material App',
                initialRoute: '/',
                routes: getAplicationRoutes(),
              );
            },
          ),
        );
      },
    );
  }
}
