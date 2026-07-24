import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const PomodoroApp());
}

class PomodoroApp extends StatelessWidget {
  const PomodoroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pomodoro 25+5 / 50+10',
      theme: ThemeData.dark(),
      home: const PomodoroScreen(),
    );
  }
}

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  // false = ২৫+৫ মিনিট মোড, true = ৫০+১০ মিনিট মোড
  bool _is50MinMode = false;

  // বর্তমান মোডের ওয়ার্ক ও ব্রেক টাইম (সেকেন্ডে)
  int get workTimeSeconds => (_is50MinMode ? 50 : 25) * 60;
  int get breakTimeSeconds => (_is50MinMode ? 10 : 5) * 60;

  late int _timeLeft;
  bool _isRunning = false;
  bool _isWorkTime = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timeLeft = workTimeSeconds;
  }

  // মোড পরিবর্তনের ফাংশন (২৫+৫ ↔ ৫০+১০)
  void _toggleMode() {
    _timer?.cancel();
    setState(() {
      _is50MinMode = !_is50MinMode;
      _isRunning = false;
      _isWorkTime = true;
      _timeLeft = workTimeSeconds;
    });
  }

  void _startTimer() {
    if (_timer != null) _timer!.cancel();
    setState(() => _isRunning = true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _isWorkTime = !_isWorkTime;
          _timeLeft = _isWorkTime ? workTimeSeconds : breakTimeSeconds;
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isWorkTime = true;
      _timeLeft = workTimeSeconds;
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro Timer'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ১. মোড পরিবর্তন করার বাটন (উপরে থাকবে)
            GestureDetector(
              onTap: _toggleMode,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade800,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.blueAccent, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.swap_horiz, color: Colors.blueAccent),
                    const SizedBox(width: 8),
                    Text(
                      _is50MinMode ? 'মোড: ৫০+১০ মিনিট (বদলান)' : 'মোড: ২৫+৫ মিনিট (বদলান)',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 35),

            // ২. কাজের সময় / বিরতির সময় ট্যাগ
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: _isWorkTime ? Colors.redAccent : Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _isWorkTime ? 'কাজ করার সময় (Work)' : 'বিরতির সময় (Break)',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),

            // ৩. বড় টাইমার টেক্সট (এটি চাপ দিলেও মোড চেঞ্জ হবে)
            GestureDetector(
              onTap: _toggleMode,
              child: Text(
                _formatTime(_timeLeft),
                style: const TextStyle(fontSize: 76, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '💡 টাইমারের ওপর ট্যাপ করে ২৫/৫০ মিনিট সুইচ করুন',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 40),

            // ৪. কন্ট্রোল বাটন (স্টার্ট/পজ/রিসেট)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 64,
                  icon: Icon(_isRunning ? Icons.pause_circle_filled : Icons.play_circle_fill),
                  color: Colors.blueAccent,
                  onPressed: _isRunning ? _pauseTimer : _startTimer,
                ),
                const SizedBox(width: 20),
                IconButton(
                  iconSize: 48,
                  icon: const Icon(Icons.replay),
                  color: Colors.grey,
                  onPressed: _resetTimer,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
