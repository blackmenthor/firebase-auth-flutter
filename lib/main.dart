import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:web_firebase_auth/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
  FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      navigatorObservers: <NavigatorObserver>[observer],
      home: MyHomePage(
          title: 'Flutter Demo Home Page',
          analytics: analytics,
          observer: observer,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
    required this.title,
    required this.analytics,
    required this.observer,
  }) : super(key: key);

  final String title;
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  Future<void> _logout() async {
    await widget.analytics.logEvent(
      name: 'logout_clicked',
    );
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Auth Sample'),
      ),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SignInScreen(
                providerConfigs: [
                  EmailProviderConfiguration(),
                ]
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          }

          final user = snapshot.data;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Welcome ${user?.email}!',
                ),
                const SizedBox(
                  height: 16.0,
                ),
                Text(
                  'ID: ${user?.uid ?? '-'}',
                ),
                const SizedBox(
                  height: 8.0,
                ),
                Text(
                  'Email: ${user?.email ?? '-'}',
                ),
                const SizedBox(
                  height: 8.0,
                ),
                Text(
                  'Display Name: ${user?.displayName ?? '-'}',
                ),
                const SizedBox(
                  height: 32.0,
                ),
                MaterialButton(
                    color: Colors.blue,
                    textColor: Colors.white,
                    child: const Text(
                      'Logout',
                    ),
                    onPressed: _logout
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
