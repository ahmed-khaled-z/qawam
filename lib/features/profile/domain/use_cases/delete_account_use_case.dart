import 'package:dartz/dartz.dart';
import '../repositories/profile_repository.dart';

class DeleteAccountUseCase {
  final ProfileRepository repository;

  DeleteAccountUseCase(this.repository);

  Future<Either<Exception, void>> call() async {
    return await repository.deleteAccount();
  }
}
