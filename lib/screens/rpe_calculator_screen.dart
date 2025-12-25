import 'package:flutter/material.dart';

class RpeCalculatorScreen extends StatefulWidget {
  const RpeCalculatorScreen({super.key});

  @override
  State<RpeCalculatorScreen> createState() => _RpeCalculatorScreenState();
}

class _RpeCalculatorScreenState extends State<RpeCalculatorScreen> {
  double _currentRpe = 7.0;
  int _currentReps = 8;
  double _currentWeight = 100.0;

  final TextEditingController _weightController =
      TextEditingController(text: '100');
  final TextEditingController _repsController =
      TextEditingController(text: '8');

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  int get _repsInReserve => (10 - _currentRpe).round();

  double get _estimated1RM {
    final adjustedReps = _currentReps + _repsInReserve;
    return _currentWeight * (1 + adjustedReps / 30);
  }

  double _calculateWeightForRpe(double targetRpe) {
    final targetRir = (10 - targetRpe).round();
    final targetAdjustedReps = _currentReps + targetRir;
    return _estimated1RM / (1 + targetAdjustedReps / 30);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RPE Calculator'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Theme.of(context).colorScheme.primary.withAlpha(25),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'About RPE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'RPE (Rate of Perceived Exertion) is a scale from 1-10 that measures how hard an exercise feels. RPE 10 = maximum effort, RPE 7 = 3 reps in reserve.',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Performance',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _weightController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
                      prefixIcon: Icon(Icons.fitness_center),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _currentWeight = double.tryParse(value) ?? 100.0;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _repsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Reps',
                      prefixIcon: Icon(Icons.repeat),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _currentReps = int.tryParse(value) ?? 8;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'RPE: ${_currentRpe.toStringAsFixed(1)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _currentRpe,
                    min: 1,
                    max: 10,
                    divisions: 18,
                    label: _currentRpe.toStringAsFixed(1),
                    onChanged: (value) {
                      setState(() {
                        _currentRpe = value;
                      });
                    },
                  ),
                  Center(
                    child: Text(
                      'Reps in Reserve (RIR): $_repsInReserve',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            color: Theme.of(context).colorScheme.primary,
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'ESTIMATED 1RM',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
          ),
          Card(
            color: Theme.of(context).colorScheme.primary,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
              child: Text(
                '${_estimated1RM.toStringAsFixed(1)} kg',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Weight Recommendations for $_currentReps Reps',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildRpeTable(),
        ],
      ),
    );
  }

  Widget _buildRpeTable() {
    final rpeValues = [10.0, 9.5, 9.0, 8.5, 8.0, 7.5, 7.0, 6.5, 6.0];

    return Card(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(25),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'RPE',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'RIR',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Weight (kg)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          ...rpeValues.map((rpe) {
            final rir = (10 - rpe).toStringAsFixed(1);
            final weight = _calculateWeightForRpe(rpe);
            final isCurrent = rpe == _currentRpe;

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCurrent
                    ? Theme.of(context).colorScheme.primary.withAlpha(50)
                    : null,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade300,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      rpe.toStringAsFixed(1),
                      style: TextStyle(
                        fontWeight:
                            isCurrent ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      rir,
                      style: TextStyle(
                        fontWeight:
                            isCurrent ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      weight.toStringAsFixed(1),
                      style: TextStyle(
                        fontWeight:
                            isCurrent ? FontWeight.bold : FontWeight.normal,
                        color: isCurrent
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
