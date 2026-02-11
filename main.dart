import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

// --- 1. Entry Point ---
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TasbeehProvider()),
      ],
      child: const ProTasbeehApp(),
    ),
  );
}

// --- 2. State Management (The Brain) ---
class TasbeehProvider with ChangeNotifier {
  int _count = 0;
  int _target = 33;
  int _round = 0;
  bool _vibration = true;
  List<String> _history = [];

  TasbeehProvider() {
    _loadData();
  }

  int get count => _count;
  int get target => _target;
  int get round => _round;
  bool get vibration => _vibration;
  List<String> get history => _history;

  void increment() {
    _count++;
    if (_vibration) HapticFeedback.lightImpact();
    
    // Check if target reached
    if (_count >= _target) {
      if (_vibration) HapticFeedback.heavyImpact();
      _round++;
      _addToHistory();
      _count = 0;
    }
    _saveData();
    notifyListeners();
  }

  void reset() {
    if (_vibration) HapticFeedback.mediumImpact();
    _count = 0;
    _saveData();
    notifyListeners();
  }

  void setTarget(int newTarget) {
    _target = newTarget;
    _count = 0; // Reset count on target change
    _saveData();
    notifyListeners();
  }

  void toggleVibration(bool value) {
    _vibration = value;
    _saveData();
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    _saveData();
    notifyListeners();
  }

  void _addToHistory() {
    final now = DateTime.now();
    _history.insert(0, "Round $_round completed at ${now.hour}:${now.minute}");
    if (_history.length > 20) _history.removeLast(); // Keep only last 20
  }

  // Loading/Saving Data
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _count = prefs.getInt('count') ?? 0;
    _target = prefs.getInt('target') ?? 33;
    _round = prefs.getInt('round') ?? 0;
    _vibration = prefs.getBool('vibration') ?? true;
    _history = prefs.getStringList('history') ?? [];
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('count', _count);
    prefs.setInt('target', _target);
    prefs.setInt('round', _round);
    prefs.setBool('vibration', _vibration);
    prefs.setStringList('history', _history);
  }
}

// --- 3. The App Widget (Material You Setup) ---
class ProTasbeehApp extends StatelessWidget {
  const ProTasbeehApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp(
          title: 'Zama Tasbeeh Pro',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: lightDynamic ?? ColorScheme.fromSeed(seedColor: Colors.green),
            useMaterial3: true,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            colorScheme: darkDynamic ?? ColorScheme.fromSeed(seedColor: Colors.green, brightness: Brightness.dark),
            useMaterial3: true,
            brightness: Brightness.dark,
          ),
          themeMode: ThemeMode.system, // Follow system theme
          home: const MainScreen(),
        );
      },
    );
  }
}

// --- 4. Main Screen with Bottom Navigation ---
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const CounterPage(),
    const HistoryPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.touch_app),
            label: 'ذکر',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'تاریخچه',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'تنظیمات',
          ),
        ],
      ),
    );
  }
}

// --- 5. Page 1: Counter (The Tasbeeh) ---
class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TasbeehProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Zama Tasbeeh Pro'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('ټول دورونه: ${provider.round}', style: theme.textTheme.titleMedium),
            const SizedBox(height: 30),
            
            // The Big Circular Button
            SizedBox(
              width: 250,
              height: 250,
              child: Material(
                color: theme.colorScheme.primaryContainer,
                shape: const CircleBorder(),
                elevation: 10,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: provider.increment,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: provider.count / provider.target,
                        strokeWidth: 8,
                        backgroundColor: theme.colorScheme.onPrimaryContainer.withOpacity(0.2),
                        color: theme.colorScheme.primary,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${provider.count}',
                            style: theme.textTheme.displayLarge?.copyWith(
                              fontSize: 80,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          Text(
                            '/ ${provider.target}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            FloatingActionButton.extended(
              onPressed: provider.reset,
              icon: const Icon(Icons.refresh),
              label: const Text('بیا له سره'),
              backgroundColor: theme.colorScheme.errorContainer,
              foregroundColor: theme.colorScheme.onErrorContainer,
            ),
          ],
        ),
      ),
    );
  }
}

// --- 6. Page 2: History ---
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TasbeehProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('تاریخچه'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: provider.clearHistory,
          )
        ],
      ),
