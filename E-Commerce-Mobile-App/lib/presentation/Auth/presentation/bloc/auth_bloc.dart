import 'package:bloc/bloc.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/usecases/login_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final AuthCheckUseCase authCheckUseCase;
  final LogoutUseCase logoutUseCase;

  AuthBloc(
      {required this.logoutUseCase,
      required this.authCheckUseCase,
      required this.loginUseCase})
      : super(AuthInitial()) {
    on<LoginEvent>(_handleLoginEvent);
    on<AuthCheckEvent>(_authCheckEvent);
    on<LogoutEvent>(_logoutEvent);
  }
  Future<void> _authCheckEvent(
    AuthCheckEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await authCheckUseCase();
    result.fold(
      (failure) => emit(AuthFailure(error: _mapFailureToMessage(failure))),
      (loginEntity) => emit(AuthSuccess(loginEntity: loginEntity)),
    );
  }

  Future<void> _logoutEvent(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await logoutUseCase();
    result.fold(
      (failure) => emit(AuthFailure(error: _mapFailureToMessage(failure))),
      (state) => emit(AuthLogout(state: state)),
    );
  }

  Future<void> _handleLoginEvent(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await loginUseCase(event.email, event.password);
    result.fold(
      (failure) => emit(AuthFailure(error: _mapFailureToMessage(failure))),
      (loginEntity) => emit(AuthSuccess(loginEntity: loginEntity)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return (failure as ServerFailure).errMessage;
      case ConnectionFailure:
        return (failure as ConnectionFailure).errMessage;
      default:
        return 'Unexpected error';
    }
  }
}
