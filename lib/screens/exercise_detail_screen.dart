import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../models/exercise.dart';
import '../models/workout_log.dart';
import '../providers/workout_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/constants.dart';

class ExerciseDetailScreen extends ConsumerStatefulWidget {
  final Exercise exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  ConsumerState<ExerciseDetailScreen> createState() =>
      _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends ConsumerState<ExerciseDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _repsController = TextEditingController();
  final _notesController = TextEditingController();
  int _selectedSet = 1;
  double _selectedRPE = 7.0;

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logs = ref
        .watch(workoutLogsProvider.notifier)
        .getLogsForExercise(widget.exercise.id);
    final weightUnit = ref.watch(weightUnitProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.fitness_center,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.exercise.muscleGroup,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              'Target Muscle Group',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildInfoRow('Sets',
                      '${widget.exercise.warmupSets} warmup + ${widget.exercise.workingSets} working'),
                  const SizedBox(height: 8),
                  _buildInfoRow('Reps', widget.exercise.repRange),
                  const SizedBox(height: 8),
                  _buildInfoRow('RPE',
                      '${widget.exercise.earlySetRPE} → ${widget.exercise.lastSetRPE}'),
                  const SizedBox(height: 8),
                  _buildInfoRow('Rest', widget.exercise.restTime),
                  if (widget.exercise.technique != 'N/A') ...[
                    const SizedBox(height: 8),
                    _buildInfoRow('Technique', widget.exercise.technique),
                  ],
                ],
              ),
            ),
          ),
          if (widget.exercise.technique != 'N/A') ...[
            const SizedBox(height: 16),
            Card(
              color: Colors.orange.withAlpha(25),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.flash_on,
                            color: Colors.orange, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          widget.exercise.technique,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppConstants.getTechniqueDescription(
                          widget.exercise.technique),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (widget.exercise.notes.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Exercise Notes',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...widget.exercise.notes.map((note) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ', style: TextStyle(fontSize: 16)),
                              Expanded(child: Text(note)),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Log Your Set',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      initialValue: _selectedSet,
                      decoration: const InputDecoration(
                        labelText: 'Set Number',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(
                        widget.exercise.workingSets,
                        (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text('Set ${index + 1}'),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() => _selectedSet = value!);
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _weightController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: InputDecoration(
                              labelText: 'Weight ($weightUnit)',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.fitness_center),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Invalid';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _repsController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Reps',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.repeat),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Invalid';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'RPE: ${_selectedRPE.toStringAsFixed(1)}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Slider(
                      value: _selectedRPE,
                      min: 6.0,
                      max: 10.0,
                      divisions: 8,
                      label: _selectedRPE.toStringAsFixed(1),
                      onChanged: (value) {
                        setState(() => _selectedRPE = value);
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                        border: OutlineInputBorder(),
                        hintText: 'How did it feel?',
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _logWorkout,
                        icon: const Icon(Icons.check),
                        label: const Text('Log Set'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (logs.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'History',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    ...logs.take(5).map((log) => _buildLogTile(log)),
                  ],
                ),
              ),
            ),
          ],
          if (widget.exercise.substitutionOptions.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alternative Exercises',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    ...widget.exercise.substitutionOptions
                        .map((option) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.swap_horiz,
                                    size: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(option),
                                ],
                              ),
                            )),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildLogTile(WorkoutLog log) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        child: Text('S${log.setNumber}'),
      ),
      title: Text('${log.weight} kg × ${log.reps} reps'),
      subtitle: Text('RPE ${log.rpe} • ${_formatDate(log.date)}'),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: () => _deleteLog(log.id),
      ),
    );
  }

  void _logWorkout() {
    if (!_formKey.currentState!.validate()) return;

    final currentWeek = ref.read(currentWeekProvider);
    final log = WorkoutLog(
      id: const Uuid().v4(),
      exerciseId: widget.exercise.id,
      exerciseName: widget.exercise.name,
      weekNumber: currentWeek,
      date: DateTime.now(),
      setNumber: _selectedSet,
      weight: double.parse(_weightController.text),
      reps: int.parse(_repsController.text),
      rpe: _selectedRPE,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    ref.read(workoutLogsProvider.notifier).addLog(log);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Set logged successfully!')),
    );

    _weightController.clear();
    _repsController.clear();
    _notesController.clear();
  }

  void _deleteLog(String logId) {
    ref.read(workoutLogsProvider.notifier).deleteLog(logId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Log deleted')),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
