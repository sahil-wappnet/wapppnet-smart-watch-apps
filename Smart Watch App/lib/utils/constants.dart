import 'package:flutter/material.dart';
import 'package:watch_connectivity_example/model/workout_model.dart';
import 'package:workout/workout.dart';

List<WorkoutModel> listOfWorkouts = [
    WorkoutModel(
      workOutTitle: 'Walking',
      workoutIcon:const Icon(Icons.directions_walk),
      workOutType: ExerciseType.walking,
    ),
    WorkoutModel(
      workOutTitle: 'Running',
      workoutIcon: const Icon(Icons.directions_run),
      workOutType: ExerciseType.running,
    ),
    WorkoutModel(
      workOutTitle: 'Badminton',
      workoutIcon: null,
      workOutType: ExerciseType.badminton,
    ),
    WorkoutModel(
      workOutTitle: 'Basketball',
      workoutIcon: null,
      workOutType: ExerciseType.basketball,
    ),
    WorkoutModel(
      workOutTitle: 'Cricket',
      workoutIcon: null,
      workOutType: ExerciseType.cricket,
    ),
    WorkoutModel(
      workOutTitle: 'Dancing',
      workoutIcon: null,
      workOutType: ExerciseType.dancing,
    ),
    WorkoutModel(
      workOutTitle: 'Paddling',
      workoutIcon: null,
      workOutType: ExerciseType.paddling,
    ),
    WorkoutModel(
      workOutTitle: 'Biking',
      workoutIcon: null,
      workOutType: ExerciseType.biking,
    ),
    WorkoutModel(
      workOutTitle: 'Tennis',
      workoutIcon: null,
      workOutType: ExerciseType.tennis,
    ),
  ];