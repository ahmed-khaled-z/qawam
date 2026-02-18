import 'package:dartz/dartz.dart';
import '../entities/profile.dart';

abstract class ProfileRepository {
  Future<Either<Exception, Profile>> getProfile();
  Future<Either<Exception, Profile>> saveProfile(Profile profile);
  Future<Either<Exception, void>> deleteAccount();
}
