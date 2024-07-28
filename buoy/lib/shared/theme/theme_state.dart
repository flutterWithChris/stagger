part of 'theme_cubit.dart';

abstract class ThemeState extends Equatable {
  final ThemeMode? themeMode;
  const ThemeState({this.themeMode = ThemeMode.system});

  @override
  List<Object?> get props => [themeMode];
}

class ThemeInitial extends ThemeState {}

class ThemeLoaded extends ThemeState {
  @override
  final ThemeMode? themeMode;

  const ThemeLoaded({this.themeMode});

  @override
  List<Object?> get props => [themeMode!];
}

class ThemeChanged extends ThemeState {}
