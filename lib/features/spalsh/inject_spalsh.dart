import '../../injection_container.dart';
import 'presentation/cubit/spalsh_cubit.dart';

/// Call this function in ServiceLocator.setup() function
void injectSpalsh() {
  // cubit only — splash doesn't need use case/repo/data source
  getIt.registerFactory(() => SpalshCubit());
}
