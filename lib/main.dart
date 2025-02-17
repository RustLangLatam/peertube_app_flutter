import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peertube_app_flutter/pages/browser_page.dart';
import 'package:peertube_app_flutter/pages/discover_page.dart';
import 'package:peertube_app_flutter/pages/library_page.dart';
import 'package:peertube_app_flutter/providers/api_provider.dart';
import 'package:system_theme/system_theme.dart';

// Define the base URL for the Peertube API
const String node = 'https://peertube.tv';

/// The main entry point of the application.
void main() async {
  // Set the global HTTP overrides to allow for insecure connections
  HttpOverrides.global = MyHttpOverrides();

  // Ensure that the Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load the system theme's accent color
  await SystemTheme.accentColor.load();

  // Create a new provider container
  final container = ProviderContainer(
    // Initialize providers here if needed
    overrides: [],
  );

  // Initialize the API providers with the base URL
  initializeApiProviders(container, baseUrl: node);

  // Run the application
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const PeertubeApp(),
    ),
  );
}

class PeertubeApp extends ConsumerStatefulWidget {
  const PeertubeApp({super.key});

  @override
  ConsumerState<PeertubeApp> createState() => _HomeState();
}

class _HomeState extends ConsumerState<PeertubeApp> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final accentColor = SystemTheme.accentColor.accent;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: accentColor,
      brightness: Theme.of(context).brightness,
    );

    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
      ),
      darkTheme: ThemeData(
        colorScheme: colorScheme,
      ),
      themeMode: ThemeMode.system,
      home: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            BrowserScreen(node: node),
            DiscoverScreen(node: node),
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
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
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