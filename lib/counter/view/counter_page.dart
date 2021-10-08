// Copyright (c) 2021, Very Good Ventures
// https://verygood.ventures
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dry_fire_shot_timer/counter/counter.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CounterCubit(),
      child: const CounterView(),
    );
  }
}

class CounterView extends StatefulWidget {
  const CounterView({Key? key}) : super(key: key);

  @override
  _CounterViewState createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  late CountDownController _controller;
  int _chosenDurationSeconds = 5;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _controller = CountDownController();
  }

  void _playSound() {
    // TODO(brandon): Not much of a shot timer beep, change the sound
    FlutterBeep.beep();
  }

  CircularCountDownTimer _buildCountDownTimer() {
    return CircularCountDownTimer(
      key: ValueKey(_chosenDurationSeconds),
      controller: _controller,
      height: 200,
      width: 200,
      fillColor: Theme.of(context).primaryColor,
      ringColor: Colors.white,
      isReverse: true,
      duration: _chosenDurationSeconds,
      isReverseAnimation: true,
      autoStart: false,
      onStart: () {
        setState(() {
          _isRunning = true;
        });
      },
      onComplete: () {
        _playSound();
        _controller.start();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dry Fire Shot Timer')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Spacer(),
            _buildCountDownTimer(),
            const Spacer(),
            if (!_isRunning)
              DurationChooser(
                currentDuration: _chosenDurationSeconds,
                onAddDuration: () {
                  setState(() {
                    _chosenDurationSeconds++;
                  });
                },
                onRemoveDuration: () {
                  setState(() {
                    _chosenDurationSeconds--;
                  });
                },
              ),
            const Spacer(),
            if (_isRunning)
              FloatingActionButton(
                onPressed: () {
                  _controller.pause();
                  setState(() {
                    _isRunning = false;
                  });
                },
                child: const Icon(Icons.stop),
              ),
            if (!_isRunning)
              FloatingActionButton(
                onPressed: () => _controller.start(),
                child: const Icon(Icons.play_arrow),
              ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class CounterText extends StatelessWidget {
  const CounterText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final count = context.select((CounterCubit cubit) => cubit.state);
    return Text('$count', style: theme.textTheme.headline1);
  }
}

class DurationChooser extends StatelessWidget {
  const DurationChooser({
    Key? key,
    required int currentDuration,
    required VoidCallback onAddDuration,
    required VoidCallback onRemoveDuration,
  })  : _currentDuration = currentDuration,
        _onAddDuration = onAddDuration,
        _onRemoveDuration = onRemoveDuration,
        super(key: key);

  final int _currentDuration;
  final VoidCallback _onAddDuration;
  final VoidCallback _onRemoveDuration;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FloatingActionButton(
          onPressed: _onRemoveDuration,
          child: const Icon(Icons.remove),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Text(_currentDuration.toString()),
        ),
        FloatingActionButton(
          onPressed: _onAddDuration,
          child: const Icon(Icons.add),
        ),
      ],
    );
  }
}
