import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

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
  // false = 25+5 min mode, true = 50+10 min mode
  bool _is50MinMode = false;

  // Work and Break durations in seconds
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

  // Toggle between 25+5 and 50+10 modes
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
          // Play beep sound when timer finishes
          FlutterRingtonePlayer().playNotification();

          // Switch between Work and Break session
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
            // 1. Mode Switch Button
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
                      _is50MinMode ? 'Mode: 50+10 min (Switch)' : 'Mode: 25+5 min (Switch)',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 35),

            // 2. Work / Break Status Tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: _isWorkTime ? Colors.redAccent : Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _isWorkTime ? 'Work Session' : 'Break Time',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),

            // 3. Main Timer Text (Tapping switches mode)
            GestureDetector(
              onTap: _toggleMode,
              child: Text(
                _formatTime(_timeLeft),
                style: const TextStyle(fontSize: 76, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '💡 Tap timer or mode button to switch 25m / 50m',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 40),

            // 4. Control Buttons (Start / Pause / Reset)
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
