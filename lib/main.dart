import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(TimerApp());
}

class TimerManager with ChangeNotifier {
  int seconds = 0;
  bool isRunning = false;
  Timer? _timer;

  void startTimer(int userInput) {
    if (userInput > 0 && !isRunning) {
      seconds = userInput;
      isRunning = true;

      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (seconds > 0) {
          seconds--;
        } else {
          stopTimer();
        }
        notifyListeners();
      });
    }
  }

  void stopTimer() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
      isRunning = false;
      notifyListeners();
    }
  }

  void resetTimer() {
    stopTimer();
    seconds = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Colors.white,
        fontFamily: 'SF Pro Display',
      ),
      home: const MyHomePage(title: 'EPs'),
      routes: {
        '/timer': (context) => TimerScreen(),
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Enter your timer',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/timer');
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Button',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final timerManager = Provider.of<TimerManager>(context);
    String formattedTime = _formatTime(timerManager.seconds);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'Timer',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              formattedTime,
              style: TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 48),
            ElevatedButton(
              onPressed: timerManager.isRunning ? null : () => _selectTime(context),
              child: Text(
                'Set Time',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                onPrimary: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: timerManager.isRunning ? null : () => timerManager.startTimer(timerManager.seconds),
                  child: Icon(Icons.play_arrow),
                  backgroundColor: Colors.green,
                ),
                SizedBox(width: 24),
                FloatingActionButton(
                  onPressed: timerManager.isRunning ? () => timerManager.stopTimer() : null,
                  child: Icon(Icons.stop),
                  backgroundColor: Colors.red,
                ),
                SizedBox(width: 24),
                FloatingActionButton(
                  onPressed: () => timerManager.resetTimer(),
                  child: Icon(Icons.refresh),
                  backgroundColor: Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _selectTime(BuildContext context) async {
    final timerManager = Provider.of<TimerManager>(context, listen: false);

    int? selectedTimeInSeconds = await showModalBottomSheet<int>(
      context: context,
      builder: (BuildContext context) {
        int? selectedTime;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoTimerPicker(
              mode: CupertinoTimerPickerMode.hms,
              onTimerDurationChanged: (Duration duration) {
                selectedTime = duration.inSeconds;
              },
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, selectedTime);
              },
              child: Text('Set'),
            ),
          ],
        );
      },
    );

    if (selectedTimeInSeconds != null) {
      timerManager.seconds = selectedTimeInSeconds;
    }
  }

  String _formatTime(int time) {
    int hours = time ~/ 3600;
    int minutes = (time % 3600) ~/ 60;
    int seconds = time % 60;

    String hoursStr = hours.toString().padLeft(2, '0');
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = seconds.toString().padLeft(2, '0');

    return '$hoursStr:$minutesStr:$secondsStr';
  }
}

class TimerApp extends StatelessWidget {
  const TimerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TimerManager(),
      child: const MyApp(),
    );
  }
}