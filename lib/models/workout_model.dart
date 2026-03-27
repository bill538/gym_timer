abstract class Workout {
  final String title;
  final String description;

  Workout({
    required this.title,
    required this.description,
  });
}

class TabataWorkout extends Workout {
  final int workSeconds;
  final int restSeconds;
  final int rounds;

  TabataWorkout({
    required String title,
    required String description,
    required this.workSeconds,
    required this.restSeconds,
    required this.rounds,
  }) : super(title: title, description: description);
}

class EmomWorkout extends Workout {
  final int intervalSeconds;
  final int rounds;

  EmomWorkout({
    required String title,
    required String description,
    required this.intervalSeconds,
    required this.rounds,
  }) : super(title: title, description: description);
}
