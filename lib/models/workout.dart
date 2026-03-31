
abstract class Workout {
  int get totalDuration;
}

class TabataWorkout extends Workout {
  final int work;
  final int rest;
  final int rounds;

  TabataWorkout({required this.work, required this.rest, required this.rounds});

  @override
  int get totalDuration => (work + rest) * rounds;
}

class EmomWorkout extends Workout {
  final int every;
  final int rounds;

  EmomWorkout({required this.every, required this.rounds});

  @override
  int get totalDuration => every * rounds;
}
