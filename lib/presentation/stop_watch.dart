import 'package:flutter/material.dart';
import 'dart:async';

class EnhancedStopWatch extends StatefulWidget {
  const EnhancedStopWatch({super.key});

  @override
  State<EnhancedStopWatch> createState() => _EnhancedStopWatchState();
}

class _EnhancedStopWatchState extends State<EnhancedStopWatch>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  int _milliseconds = 0;
  bool _isRunning = false;
  bool _isStarted = false;
  List<String> _laps = [];

  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  void _startTimer() {
    if (!_isRunning) {
      setState(() {
        _isStarted = true;
      });
      _isRunning = true;
      _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
        setState(() {
          _milliseconds += 10;
        });
      });
    }
  }

  void _pauseTimer() {
    if (_isRunning) {
      setState(() {
        _isRunning = false;
      });
      _timer?.cancel();
    }
  }

  void _cancelTimer() {
    _pauseTimer();
    setState(() {
      _milliseconds = 0;
      _laps.clear();
      _isStarted = false;
    });
  }

  void _recordLap() {
    if (_isRunning) {
      setState(() {
        final seconds = (_milliseconds / 1000).toStringAsFixed(2);
        _laps.insert(0, "Lap ${_laps.length + 1}: $seconds s");
      });
    }
  }

  String _formatTime(int milliseconds) {
    final seconds = (milliseconds / 1000).floor();
    final ms = (milliseconds % 1000).toString().padLeft(3, '0');
    return "$seconds.$ms";
  }

  Color _getBorderColor() {
    double progress = (_milliseconds / 60000) % 1;
    return HSVColor.fromAHSV(1, progress * 360, 0.8, 0.9).toColor();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFDEB71), // Light Peach
              Color(0xFFF8D800), // Gold
              Color(0xFFF06292), // Pink
              Color(0xFF9575CD), // Purple
              Color(0xFF64B5F6), // Light Blue
              Color(0xFF4DD0E1), // Cyan
              Color(0xFFAED581), // Light Green
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _glowController,
                    builder: (context, child) {
                      return Container(
                        width: 200 + _glowController.value * 10,
                        height: 200 + _glowController.value * 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _getBorderColor(),
                            width: 5.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _getBorderColor().withOpacity(0.6),
                              blurRadius: 15,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Text(
                    _formatTime(_milliseconds),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              if (_laps.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: _laps.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 4.0),
                        child: Text(
                          _laps[index],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 20),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: !_isStarted
                    ? ElevatedButton(
                        key: const ValueKey("start_button"),
                        onPressed: _startTimer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlueAccent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          "Start",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      )
                    : Row(
                        key: const ValueKey("control_buttons"),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _recordLap,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 5,
                            ),
                            child: const Text(
                              "Lap",
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: _isRunning ? _pauseTimer : _startTimer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _isRunning ? Colors.orange : Colors.lightBlue,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 5,
                            ),
                            child: Text(
                              _isRunning ? "Pause" : "Resume",
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: _cancelTimer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 5,
                            ),
                            child: const Text(
                              "Reset",
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
