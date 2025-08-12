import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Events
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

class ToggleThemeEvent extends ThemeEvent {
  const ToggleThemeEvent();
}

class LoadThemeEvent extends ThemeEvent {
  const LoadThemeEvent();
}

// States
abstract class ThemeState extends Equatable {
  const ThemeState();

  @override
  List<Object?> get props => [];
}

class ThemeInitial extends ThemeState {
  const ThemeInitial();
}

class ThemeLoaded extends ThemeState {
  final bool isDarkMode;

  const ThemeLoaded({required this.isDarkMode});

  @override
  List<Object?> get props => [isDarkMode];
}

// Bloc
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _themeKey = 'theme_mode';
  
  ThemeBloc() : super(const ThemeInitial()) {
    on<ToggleThemeEvent>(_toggleTheme);
    on<LoadThemeEvent>(_loadTheme);
    
    // Automatically load theme when bloc is created
    add(const LoadThemeEvent());
  }

  Future<void> _toggleTheme(
    ToggleThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    
    // If we're still in initial state, load the current theme first
    if (state is ThemeInitial) {
      final isDarkMode = prefs.getBool(_themeKey) ?? false;
      emit(ThemeLoaded(isDarkMode: isDarkMode));
      return;
    }
    
    // Get current theme from state or fallback to preferences
    final currentTheme = state is ThemeLoaded 
        ? (state as ThemeLoaded).isDarkMode 
        : prefs.getBool(_themeKey) ?? false;
    
    final newTheme = !currentTheme;
    
    await prefs.setBool(_themeKey, newTheme);
    emit(ThemeLoaded(isDarkMode: newTheme));
  }

  Future<void> _loadTheme(
    LoadThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDarkMode = prefs.getBool(_themeKey) ?? false;
      emit(ThemeLoaded(isDarkMode: isDarkMode));
    } catch (e) {
      // Fallback to light mode if there's an error
      emit(const ThemeLoaded(isDarkMode: false));
    }
  }
} 