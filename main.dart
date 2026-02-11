import 'package:flutter/material.dart';

void main() {
  runApp(const TasbeehApp());
}

class TasbeehApp extends StatelessWidget {
  const TasbeehApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: const TasbeehHome(),
    );
  }
}

class TasbeehHome extends StatefulWidget {
  const TasbeehHome({super.key});

  @override
  State<TasbeehHome> createState() => _TasbeehHomeState();
}

class _TasbeehHomeState extends State<TasbeehHome> {
  int _counter = 0; // دلته شمېره ساتل کیږي

  // د شمېرې زیاتولو فنکشن
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  // د شمېرې صفر کولو فنکشن
  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('الکترونیکي تسبیح'),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'اوسنی ذکر:',
              style: TextStyle(fontSize: 24, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            // د شمېرې ښودلو برخه
            Text(
              '$_counter',
              style: const TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 50),
            // د ذکر تڼۍ
            ElevatedButton(
              onPressed: _incrementCounter,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'الله اکبر',
                style: TextStyle(fontSize: 30, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            // د ریسیټ (Reset) تڼۍ
            TextButton.icon(
              onPressed: _resetCounter,
              icon: const Icon(Icons.refresh, color: Colors.red),
              label: const Text(
                'بیا له سره',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
