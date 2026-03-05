import 'package:get_it/get_it.dart';

import 'data/data_sources/feature_request_remote_data_source.dart';
import 'data/repositories/feature_request_repository_impl.dart';
import 'domain/repositories/feature_request_repository.dart';
import 'domain/use_cases/stream_my_feature_requests_use_case.dart';
import 'domain/use_cases/submit_feature_request_use_case.dart';
import 'presentation/cubit/feature_request_cubit.dart';

void injectFeatureRequest() {
  final getIt = GetIt.instance;

  getIt.registerFactory(
    () => FeatureRequestCubit(submitUseCase: getIt(), streamUseCase: getIt()),
  );

  getIt.registerLazySingleton(() => SubmitFeatureRequestUseCase(getIt()));
  getIt.registerLazySingleton(() => StreamMyFeatureRequestsUseCase(getIt()));

  getIt.registerLazySingleton<FeatureRequestRepository>(
    () => FeatureRequestRepositoryImpl(remote: getIt()),
  );

  getIt.registerLazySingleton<FeatureRequestRemoteDataSource>(
    () => FeatureRequestRemoteDataSourceImpl(),
  );
}
