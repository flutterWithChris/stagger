import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'coach_marks_state.dart';

class CoachMarksCubit extends Cubit<CoachMarksState> {
  CoachMarksCubit() : super(CoachMarksInitial());
  void loadCoachMarks(BuildContext context) => _onLoadCoachMarks(context);
  void fabCoachmarkShown() => _onFabCoachmarkShown();

  void _onLoadCoachMarks(BuildContext context) async {
    emit(CoachMarksLoading());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool fabCoachmarkShown = prefs.getBool('fabCoachmarkShown') ?? false;
    emit(CoachMarksLoaded(
      fabCoachmarkShown,
    ));
  }

  void _onFabCoachmarkShown() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('fabCoachmarkShown', true);
    emit(const CoachMarksLoaded(
      true,
    ));
  }
}
