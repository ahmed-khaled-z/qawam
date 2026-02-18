import '../../injection_container.dart';
import 'presentation/cubit/bottom_nav_cubit.dart';

//call this function in ServiceLocator.setup() function
void injectBottomNav() {
  // cubit only — bottom nav doesn't need use case/repo/data source
  getIt.registerFactory(() => BottomNavCubit());
}
