import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/workout_day.dart';
import '../models/exercise.dart';
import '../models/set_data.dart';
import '../providers/workout_provider.dart';
import '../services/database_service.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  final WorkoutDay workoutDay;
  final int weekNumber;

  const ActiveWorkoutScreen({
    super.key,
    required this.workoutDay,
    required this.weekNumber,
  });

  @override
  ConsumerState<ActiveWorkoutScreen> createState() =>
      _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  int _currentExerciseIndex = 0;
  final Map<String, List<SetData>> _completedSets = {};

  Timer? _restTimer;
  int _restSecondsLeft = 0;
  bool _isResting = false;

  Exercise get _currentExercise =>
      widget.workoutDay.exercises[_currentExerciseIndex];

  bool get _isLastExercise =>
      _currentExerciseIndex == widget.workoutDay.exercises.length - 1;

  @override
  void dispose() {
    _restTimer?.cancel();
    _restTimer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await _showExitConfirmation(context);
        if (shouldPop == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.workoutDay.name} - In Progress'),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: _showExerciseInfo,
            ),
            TextButton(
              onPressed: () => _showExitConfirmation(context),
              child: const Text('End Workout'),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildProgressBar(),
            _buildExerciseNavigation(),
            if (_isResting) _buildRestTimerBar(),
            Expanded(child: _buildCurrentExercise()),
          ],
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress =
        (_currentExerciseIndex + 1) / widget.workoutDay.exercises.length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Theme.of(context).cardTheme.color,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Exercise ${_currentExerciseIndex + 1} of ${widget.workoutDay.exercises.length}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E88E5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withAlpha(25),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF1E88E5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseNavigation() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: widget.workoutDay.exercises.length,
        itemBuilder: (context, index) {
          final exercise = widget.workoutDay.exercises[index];
          final isCompleted = _completedSets.containsKey(exercise.id) &&
              _completedSets[exercise.id]!.length >= exercise.workingSets;
          final isCurrent = index == _currentExerciseIndex;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                setState(() {
                  _currentExerciseIndex = index;
                  _cancelRest();
                });
              },
              child: Container(
                width: 44,
                decoration: BoxDecoration(
                  color: isCurrent
                      ? const Color(0xFF1E88E5)
                      : isCompleted
                          ? const Color(0xFF4CAF50)
                          : Colors.white.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isCurrent ? Colors.white : Colors.white70,
                          ),
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRestTimerBar() {
    final minutes = _restSecondsLeft ~/ 60;
    final seconds = _restSecondsLeft % 60;
    final text = minutes > 0
        ? '$minutes:${seconds.toString().padLeft(2, '0')}'
        : '$seconds s';

    final totalRest = _currentExercise.restTimeInSeconds;
    final progress = (_restSecondsLeft / totalRest).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.black.withAlpha(102),
      child: Row(
        children: [
          const Icon(Icons.timer, color: Color(0xFFFB8C00)),
          const SizedBox(width: 8),
          const Text(
            'Rest',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFB8C00),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: Colors.white.withAlpha(25),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFFFB8C00)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: _cancelRest,
            child: const Text(
              'Skip',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentExercise() {
    final exercise = _currentExercise;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exercise.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildInfoChip(Icons.repeat, '${exercise.workingSets} sets'),
                  _buildInfoChip(
                      Icons.fitness_center, '${exercise.repRange} reps'),
                  _buildInfoChip(Icons.timer_outlined, exercise.restTime),
                  _buildInfoChip(
                    exercise.techniqueIcon,
                    exercise.techniqueDisplayName,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (exercise.notes.isNotEmpty)
                Text(
                  exercise.notes.first,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withAlpha(178),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildPreviousSetInfo(),
        const SizedBox(height: 16),
        ...List.generate(
          exercise.workingSets,
          (setIndex) => _buildSetCard(setIndex + 1),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E88E5).withAlpha(50),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF1E88E5)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF1E88E5),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviousSetInfo() {
    final result = DatabaseService.getLastSetForExercise(
      _currentExercise.id,
      1,
    );
    if (!result.isSuccess || result.data == null) {
      return const SizedBox.shrink();
    }

    final lastSet = result.data!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.history, size: 18, color: Colors.white70),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Last time: ${lastSet.weight} kg × ${lastSet.reps} reps @ RPE ${lastSet.rpe.toStringAsFixed(1)}',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetCard(int setNumber) {
    final exerciseId = _currentExercise.id;
    final completedSets = _completedSets[exerciseId] ?? [];
    final setData = completedSets.firstWhere(
      (s) => s.setNumber == setNumber,
      orElse: () => SetData(
        id: '',
        exerciseId: exerciseId,
        setNumber: setNumber,
        weight: 0,
        reps: 0,
        rpe: 0,
        timestamp: DateTime.now(),
      ),
    );
    final isCompleted = setData.id.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCompleted
              ? const Color(0xFF4CAF50).withAlpha(25)
              : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted
                ? const Color(0xFF4CAF50)
                : Colors.white.withAlpha(25),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCompleted
                    ? const Color(0xFF4CAF50)
                    : Colors.white.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white)
                    : Text(
                        '$setNumber',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: isCompleted
                  ? Text(
                      '${setData.weight} kg × ${setData.reps} reps @ RPE ${setData.rpe.toStringAsFixed(1)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : Text(
                      'Set $setNumber',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withAlpha(153),
                      ),
                    ),
            ),
            IconButton(
              onPressed: () => _logSet(setNumber, setData),
              icon: Icon(
                isCompleted ? Icons.edit : Icons.add_circle_outline,
                color: const Color(0xFF1E88E5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(76),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentExerciseIndex > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _currentExerciseIndex--;
                      _cancelRest();
                    });
                  },
                  child: const Text('Previous'),
                ),
              ),
            if (_currentExerciseIndex > 0) const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isLastExercise ? _finishWorkout : _nextExercise,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isLastExercise
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFF1E88E5),
                ),
                child:
                    Text(_isLastExercise ? 'Finish Workout' : 'Next Exercise'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _logSet(int setNumber, SetData existingData) {
    final weightController = TextEditingController(
      text: existingData.weight > 0 ? existingData.weight.toString() : '',
    );
    final repsController = TextEditingController(
      text: existingData.reps > 0 ? existingData.reps.toString() : '',
    );
    final notesController = TextEditingController(
      text: existingData.notes ?? '',
    );

    double rpe = existingData.rpe > 0
        ? existingData.rpe
        : (setNumber == _currentExercise.workingSets
            ? _currentExercise.lastSetRPE
            : _currentExercise.earlySetRPE);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Log Set $setNumber',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _currentExercise.name,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withAlpha(178),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: weightController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Weight (kg)',
                          prefixIcon: Icon(Icons.fitness_center),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: repsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Reps',
                          prefixIcon: Icon(Icons.repeat),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'RPE: ${rpe.toStringAsFixed(1)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Slider(
                  value: rpe,
                  min: 1,
                  max: 10,
                  divisions: 18,
                  label: rpe.toStringAsFixed(1),
                  onChanged: (value) {
                    setModalState(() {
                      rpe = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    prefixIcon: Icon(Icons.note_add_outlined),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final weight =
                          double.tryParse(weightController.text.trim()) ?? 0;
                      final reps =
                          int.tryParse(repsController.text.trim()) ?? 0;
                      if (weight > 0 && reps > 0) {
                        _saveSet(
                            setNumber,
                            weight,
                            reps,
                            rpe,
                            notesController.text.trim().isEmpty
                                ? null
                                : notesController.text.trim());
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Save Set'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveSet(
      int setNumber, double weight, int reps, double rpe, String? notes) async {
    final setData = SetData(
      id: const Uuid().v4(),
      exerciseId: _currentExercise.id,
      setNumber: setNumber,
      weight: weight,
      reps: reps,
      rpe: rpe,
      timestamp: DateTime.now(),
      notes: notes,
    );

    setState(() {
      final key = _currentExercise.id;
      _completedSets.putIfAbsent(key, () => []);
      _completedSets[key]!.removeWhere((s) => s.setNumber == setNumber);
      _completedSets[key]!.add(setData);
    });

    try {
      final result = await DatabaseService.saveSet(setData);
      if (!result.isSuccess && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save set: ${result.error}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error saving set. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }

    _startRestTimer();
  }

  void _startRestTimer() {
    _restTimer?.cancel();
    final totalSeconds = _currentExercise.restTimeInSeconds;
    setState(() {
      _restSecondsLeft = totalSeconds;
      _isResting = true;
    });

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restSecondsLeft <= 1) {
        timer.cancel();
        setState(() {
          _restSecondsLeft = 0;
          _isResting = false;
        });
      } else {
        setState(() {
          _restSecondsLeft--;
        });
      }
    });
  }

  void _cancelRest() {
    _restTimer?.cancel();
    setState(() {
      _isResting = false;
      _restSecondsLeft = 0;
    });
  }

  void _nextExercise() {
    if (!_isLastExercise) {
      setState(() {
        _currentExerciseIndex++;
        _cancelRest();
      });
    }
  }

  void _finishWorkout() async {
    final allSets = <SetData>[];
    _completedSets.forEach((_, sets) {
      allSets.addAll(sets);
    });

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Workout Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Great job! You completed ${allSets.length} sets.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(activeWorkoutProvider.notifier).clearActiveWorkout();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showExitConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Workout?'),
        content: const Text(
          'Are you sure you want to end this workout? Your progress will be saved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
              _finishWorkout();
            },
            child: const Text('End Workout'),
          ),
        ],
      ),
    );
  }

  void _showExerciseInfo() {
    final exercise = _currentExercise;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  exercise.muscleGroup,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withAlpha(153),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    exercise.techniqueIcon,
                    color: const Color(0xFF1E88E5),
                  ),
                  title: Text(
                    exercise.techniqueDisplayName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    exercise.technique,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                const SizedBox(height: 12),
                if (exercise.substitutionOptions.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Substitution Options:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ...exercise.substitutionOptions.map(
                        (sub) => Row(
                          children: [
                            const Icon(Icons.swap_horiz,
                                size: 16, color: Colors.white70),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                sub,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                if (exercise.notes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Coaching Notes:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...exercise.notes.map(
                    (note) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• $note',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
