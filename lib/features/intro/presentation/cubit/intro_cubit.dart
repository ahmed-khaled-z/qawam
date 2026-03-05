import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/intro_repository.dart';
import 'intro_state.dart';

class IntroCubit extends Cubit<IntroState> {
  final IntroRepository _repository;

  IntroCubit({required IntroRepository repository})
    : _repository = repository,
      super(const IntroState());

  void onPageChanged(int page) {
    emit(state.copyWith(currentPage: page));
  }

  Future<void> completeOnboarding() async {
    await _repository.completeOnboarding();
    emit(state.copyWith(isCompleted: true));
  }
}
