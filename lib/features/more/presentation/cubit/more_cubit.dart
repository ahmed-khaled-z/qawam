import '../../domain/use_cases/more_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'more_state.dart';

class MoreCubit extends Cubit<MoreState> {
  final MoreUseCase moreUseCase;

  MoreCubit({required this.moreUseCase})
    : super(const MoreState(status: MoreStatus.initial));

  Future<void> fetchData() async {
    emit(state.copyWith(status: MoreStatus.loading));

    final result = await moreUseCase.call();

    result.fold(
      (exception) => emit(
        state.copyWith(
          status: MoreStatus.error,
          errorMessage: exception.toString(),
        ),
      ),
      (_) =>
          emit(state.copyWith(status: MoreStatus.loaded, errorMessage: null)),
    );
  }
}
