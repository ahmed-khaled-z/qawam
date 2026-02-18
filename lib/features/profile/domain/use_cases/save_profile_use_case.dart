import 'package:dartz/dartz.dart';
import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class SaveProfileUseCase {
  final ProfileRepository repository;

  SaveProfileUseCase(this.repository);

  Future<Either<Exception, Profile>> call(Profile profile) async {
    return await repository.saveProfile(profile);
  }
}
