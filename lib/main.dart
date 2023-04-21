import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wuusu_shop_client/screens/home.dart';
import 'package:wuusu_shop_client/storage.dart';
import './screens/login.dart';
import 'apicall.dart';

Storage storage = Storage();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? mode = await storage.read("thememode");

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeModeNotifier(mode ?? 'light'),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wuusu Fashion Desktop Client',
      theme: Provider.of<ThemeModeNotifier>(context).isDarkMode
          ? ThemeData.dark()
          : ThemeData(
              primarySwatch: Colors.blue,
            ),
      home: const MyHomePage(title: 'Wuusu Fashion Desktop Client'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String themeMode = 'dark';

  ApiCall apiCall = ApiCall();

  Future<Map?> checkIsLogged() async {
    String? token = await storage.read("token");

    if (token == null) return null;

    apiCall.setToken(token);

    try {
      Map? data = await apiCall.get("/me").call();
      return data!["user"];
    } catch (e) {
      return null;
    }

    //return {};
  }

  @override
  Widget build(BuildContext bcontext) {
    return SizedBox(
      width: 400,
      height: 300,
      child: Scaffold(
        body: FutureBuilder(
          future: checkIsLogged(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              Map? user = snapshot.data;

              if (user != null) {
                return HomeScreen(
                  apiCall: apiCall,
                  user: user,
                );
              } else {
                return LoginScreen();
              }
            }
          },
        ),
      ),
    );
  }
}

class ThemeModeNotifier extends ChangeNotifier {
  Storage storage = Storage();

  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  ThemeModeNotifier(String savedThemeMode) {
    //setSavedThemeMode();
    _isDarkMode = savedThemeMode == 'dark';
  }

  void toggleThemeMode() {
    _isDarkMode = !_isDarkMode;
    storage.save('thememode', _isDarkMode ? 'dark' : 'light');
    notifyListeners();
  }

  void setSavedThemeMode() async {
    String? mode = await storage.read("thememode");

    if (mode == null) return;

    _isDarkMode = mode == 'dark';
    notifyListeners();
  }
}
