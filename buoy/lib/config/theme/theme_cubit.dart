import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeInitial());
  void loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? theme = prefs.getString('theme');
    if (theme == null) {
      emit(const ThemeLoaded(themeMode: ThemeMode.system));
    } else {
      emit(ThemeLoaded(
          themeMode: theme == 'ThemeMode.system'
              ? ThemeMode.system
              : theme == 'ThemeMode.dark'
                  ? ThemeMode.dark
                  : ThemeMode.light));
    }
  }

  void changeBrightness(ThemeMode themeMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', themeMode.toString());
    emit(ThemeLoaded(themeMode: themeMode));
  }
}
