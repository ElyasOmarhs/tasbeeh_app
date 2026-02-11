import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TasbeehProvider()),
      ],
      child: const TasbeehApp(),
    ),
  );
}

// -------------------- LOGIC (PROVIDER) --------------------
class TasbeehProvider extends ChangeNotifier {
  int _count = 0;
  List<String> _history = [];

  int get count => _count;
  List<String> get history => _history;

  TasbeehProvider() {
    _loadData();
  }

  void increment() {
    _count++;
    _saveData();
    notifyListeners();
  }

  void reset() {
    if (_count > 0) {
      _history.insert(0, "${DateTime.now().toString().split('.')[0]} - مجموع: $_count");
      if (_history.length > 10) _history.removeLast();
    }
    _count = 0;
    _saveData();
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    _saveData();
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('counter', _count);
    prefs.setStringList('history', _history);
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _count = prefs.getInt('counter') ?? 0;
    _history = prefs.getStringList('history') ?? [];
    notifyListeners();
  }
}

// -------------------- UI (APP DESIGN) --------------------
class TasbeehApp extends StatelessWidget {
  const TasbeehApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'الکترونیکي تسبیح',
      theme: ThemeData(
        // دلته مو یو ثابت شین رنګ ورکړ، چې په هر موبایل کې ښکلی ښکاري
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TasbeehProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الکترونیکي تسبیح'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryPage()));
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('اوسنی ذکر', style: TextStyle(fontSize: 24, color: Colors.grey)),
            const SizedBox(height: 20),
            
            Text(
              '${provider.count}',
              style: TextStyle(
                fontSize: 100,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            
            const SizedBox(height: 50),
            
            SizedBox(
              width: 200,
              height: 200,
              child: ElevatedButton(
                onPressed: provider.increment,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  elevation: 5,
                ),
                child: const Text('سبحان الله', style: TextStyle(fontSize: 28)),
              ),
            ),
            
            const SizedBox(height: 30),
            
            TextButton.icon(
              onPressed: provider.reset,
              icon: const Icon(Icons.refresh, color: Colors.red),
              label: const Text('نوې دوره', style: TextStyle(color: Colors.red, fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TasbeehProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تاریخچه'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: provider.clearHistory,
          )
        ],
      ),
      body: provider.history.isEmpty
          ? const Center(child: Text('تاریخچه خالي ده'))
          : ListView.builder(
              itemCount: provider.history.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.check_circle_outline, color: Colors.green),
                  title: Text(provider.history[index]),
                );
              },
            ),
    );
  }
}
