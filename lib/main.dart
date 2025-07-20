import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/sadaka_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Create and initialize the provider
  final sadakaProvider = SadakaProvider();
  await sadakaProvider.loadItems();
  runApp(MyApp(sadakaProvider: sadakaProvider));
}

class MyApp extends StatelessWidget {
  final SadakaProvider sadakaProvider;
  const MyApp({super.key, required this.sadakaProvider});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: sadakaProvider,
      child: MaterialApp(
        title: 'Sadaka Planner',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
