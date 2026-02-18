import '../../domain/use_cases/intro_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'intro_state.dart';

class IntroCubit extends Cubit<IntroState> {
  final IntroUseCase introUseCase;

  IntroCubit({required this.introUseCase})
      : super(const IntroState(status: IntroStatus.initial));

  Future<void> fetchData() async {
    emit(state.copyWith(status: IntroStatus.loading));

    final result = await introUseCase.call();

    result.fold(
      (exception) => emit(
        state.copyWith(
          status: IntroStatus.error,
          errorMessage: exception.toString(),
        ),
      ),
      (_) => emit(
        state.copyWith(
          status: IntroStatus.loaded,
          errorMessage: null,
        ),
      ),
    );
  }
}
