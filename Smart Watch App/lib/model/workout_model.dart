import 'package:flutter/material.dart';
import 'package:workout/workout.dart';

class WorkoutModel{
  final String? workOutTitle;
  final Icon? workoutIcon;
  final ExerciseType? workOutType;

  WorkoutModel({required this.workOutTitle, required this.workoutIcon,required this.workOutType,});

}