import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eventorize_app/data/api/shared_preferences_service.dart';
import 'package:eventorize_app/data/models/user.dart';
import 'package:eventorize_app/data/repositories/user_repository.dart';
import 'package:eventorize_app/common/network/dio_client.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final UserRepository userRepository;

  LoginBloc(this.userRepository) : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(LoginSubmitted event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    try {
      final result = await userRepository.login(
        email: event.email,
        password: event.password,
      );
      final user = result['user'] as User;
      final token = result['token'] as String;

      await SharedPreferencesService.saveToken(token);
      if (event.rememberMe) {
        await SharedPreferencesService.saveEmail(event.email);
      }

      emit(LoginSuccess(user: user));
    } catch (e) {
      String errorMessage = 'Login failed';
      if (e is ApiException) {
        errorMessage = e.message;
      } else {
        errorMessage = e.toString();
      }
      emit(LoginFailure(errorMessage));
    }
  }
}