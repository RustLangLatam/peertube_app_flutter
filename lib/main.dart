import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peertube_app_flutter/pages/browser_page.dart';
import 'package:peertube_app_flutter/pages/channels_page.dart';
import 'package:peertube_app_flutter/pages/discover_page.dart';
import 'package:flutter/material.dart';
import 'package:peertube_app_flutter/pages/library_page.dart';
import 'package:peertube_app_flutter/pages/lives_page.dart';
import 'package:peertube_app_flutter/providers/api_provider.dart';
import 'package:system_theme/system_theme.dart';

String node = 'https://peertube.tv';

void main() async {
  HttpOverrides.global = MyHttpOverrides();

  WidgetsFlutterBinding.ensureInitialized();
  //
  await SystemTheme.accentColor.load();

  runApp(ProviderScope(
      overrides: [peerTubeApiProvider(apiBaseUrl: node)], child: const Home()));
}

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    BrowserScreen(node: node),
    DiscoverScreen(node: node),
    // ChannelsScreen(node: node),
    LivesScreen(node: node),
    LibraryScreen(node: node),
  ];

  @override
  Widget build(BuildContext context) {
    final accentcolor = SystemTheme.accentColor.accent;
    int r = accentcolor.red;
    int g = accentcolor.green;
    int b = accentcolor.blue;

    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(255, r, g, b),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(255, r, g, b),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: Scaffold(
        body: IndexedStack( // ✅ Keeps the state of each tab
          index: _selectedIndex,
          children: [
            BrowserScreen(node: node),
            DiscoverScreen(node: node),
            // ChannelsScreen(node: node),
            LivesScreen(node: node),
            LibraryScreen(node: node),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xFF1A1A1A),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.orange,
          unselectedItemColor: Colors.white70,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.video_library_outlined, size: 24),
              activeIcon: Icon(Icons.video_library, size: 26),
              label: "Browse",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined, size: 24),
              activeIcon: Icon(Icons.explore, size: 26),
              label: "Discover",
            ),
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.subscriptions_rounded, size: 24),
            //   activeIcon: Icon(Icons.subscriptions_rounded, size: 26),
            //   label: "Channels",
            // ),
            BottomNavigationBarItem(
              icon: Icon(Icons.podcasts_rounded, size: 24),
              activeIcon: Icon(Icons.podcasts_rounded, size: 26),
              label: "Live",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.video_library_rounded, size: 24),
              activeIcon: Icon(Icons.video_library_rounded, size: 26),
              label: "Library",
            ),
          ],
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate certificate, String hostName, int hostPort) => true;
  }
}
