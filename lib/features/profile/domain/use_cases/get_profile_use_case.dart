import 'package:dartz/dartz.dart';
import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository repository;

  GetProfileUseCase(this.repository);

  Future<Either<Exception, Profile>> call() async {
    return await repository.getProfile();
  }
}
