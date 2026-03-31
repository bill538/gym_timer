# Gym Timer - Development Progress

## Codebase Summary

The application is a Flutter-based workout timer with Chromecast integration.

**Key Components:**

*   **`main.dart`**: Sets up the application and the initial `SetupScreen`.
*   **`screens/setup_screen.dart`**: (Currently in `main.dart`) Displays a grid of workout types (Tabata, EMOM, etc.). This screen is the entry point for the user to choose a workout.
*   **`screens/active_timer_screen.dart`**: A visually appealing screen for the active timer, showing a progress ring, current round, and the next exercise. The data is currently hardcoded.
*   **`services/cast_service.dart`**: Manages the Chromecast connection and provides a method to send timer updates to the receiver.
*   **`widgets/workout_card.dart`**: A reusable card widget for the `SetupScreen`.
*   **`widgets/painters/timer_painter.dart`**: A `CustomPainter` to draw the timer progress ring.

**Dependencies:**

*   `flutter_chrome_cast`: For Chromecast support.
*   `wakelock_plus`: To keep the screen on during workouts.

## Next Steps

1.  **Refactor `SetupScreen`:**
    *   Move the `SetupScreen` class from `main.dart` to its own file: `lib/screens/setup_screen.dart`.
    *   Update `main.dart` to import the new file.

2.  **Implement Workout Data Models:**
    *   Create data models for different workout types (e.g., `TabataWorkout`, `EmomWorkout`). These models should hold the parameters for each workout (e.g., work time, rest time, rounds).
    *   Create a base `Workout` class or interface for these models to inherit from.

3.  **Implement Workout Configuration Screens:**
    *   For each workout type, create a configuration screen that allows the user to set the parameters (e.g., a `TabataSetupScreen`).
    *   Implement navigation from the `SetupScreen`'s `WorkoutCard`s to these configuration screens.

4.  **Develop Timer State Management:**
    *   Create a state management solution (e.g., using BLoC, Provider, or Riverpod) to handle the timer logic. This will manage the state of the timer (e.g., work, rest, finished), the current time, and the current round.
    *   The state management solution should be responsible for updating the UI of the `ActiveTimerScreen` and sending updates to the `CastService`.

5.  **Connect `ActiveTimerScreen` to State Management:**
    *   Replace the hardcoded data in `ActiveTimerScreen` with data from the timer state management solution.

6.  **Integrate `CastService`:**
    *   Connect the `CastService` to the timer state management solution to send real-time updates to the Chromecast receiver.

## Progress Update (2026-03-19)

*   Created and implemented navigation for Tabata and EMOM workout configuration screens.
*   Created `TabataSetupScreen` and `EmomSetupScreen` with input fields for workout parameters.
*   Created `MainScreen` to host the workout selection cards.
*   Created a reusable `WorkoutCard` widget.
*   Refactored `SetupScreen` into its own file at `lib/screens/setup_screen.dart` and updated `main.dart`.
*   Created initial workout data models in `lib/models/workout_model.dart`, including a base `Workout` class and specific `TabataWorkout` and `EmomWorkout` classes.

### Progress Update
- Implemented Timer BLoC for state management, including events, states, and the core BLoC logic.
