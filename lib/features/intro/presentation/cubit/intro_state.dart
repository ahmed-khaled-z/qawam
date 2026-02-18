import 'package:equatable/equatable.dart';

class IntroState extends Equatable {
  final int currentPage;
  final bool isCompleted;

  const IntroState({
    this.currentPage = 0,
    this.isCompleted = false,
  });

  bool get isLastPage => currentPage == 2;

  IntroState copyWith({
    int? currentPage,
    bool? isCompleted,
  }) {
    return IntroState(
      currentPage: currentPage ?? this.currentPage,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [currentPage, isCompleted];
}
