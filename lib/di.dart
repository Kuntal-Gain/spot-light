import 'package:appwrite/appwrite.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:spot_time/feature/event/app/cubit/cred/cred_cubit.dart';

import 'core/network/appwrite_client.dart';
import 'feature/event/app/cubit/auth/auth_cubit.dart';
import 'feature/event/data/data_sources/remote_datasource.dart';
import 'feature/event/data/data_sources/remote_datasource_impl.dart';
import 'feature/event/data/repo/appwrite_repository.dart';
import 'feature/event/domain/repo/appwrite_repository.dart';
import 'feature/event/domain/usecases/auth/get_current_user.dart';
import 'feature/event/domain/usecases/auth/is_user_loggedin.dart';
import 'feature/event/domain/usecases/auth/login_with_email.dart';
import 'feature/event/domain/usecases/auth/logout_user.dart';
import 'feature/event/domain/usecases/auth/register_with_email.dart';

final sl = GetIt.instance;

void init() {
  /// [cubits]

  sl.registerFactory(
    () => CredCubit(
      getCurrentUser: sl.call(),
      loginWithEmail: sl.call(),
      registerWithEmail: sl.call(),
      logout: sl.call(),
    ),
  );

  sl.registerFactory(() => AuthCubit(
        isUserLoggedIn: sl.call(),
        getCurrentUser: sl.call(),
      ));

  // TODO: other cubits

  /// [usecases]
  sl.registerLazySingleton<GetCurrentUser>(() => GetCurrentUser(sl.call()));
  sl.registerLazySingleton<LoginWithEmail>(() => LoginWithEmail(sl.call()));
  sl.registerLazySingleton<RegisterWithEmail>(
      () => RegisterWithEmail(sl.call()));
  sl.registerLazySingleton<LogoutUser>(() => LogoutUser(sl.call()));
  sl.registerLazySingleton<IsUserLoggedIn>(() => IsUserLoggedIn(sl.call()));

  // TODO: other usecases

  /// [repository]
  sl.registerLazySingleton<AppwriteRepository>(
      () => AppwriteRepositoryImpl(remoteDataSource: sl.call()));
  sl.registerLazySingleton<RemoteDataSource>(
    () => RemoteDataSourceImpl(
      account: sl.call(),
      database: sl.call(),
      storage: sl.call(),
    ),
  );

  /// [externals]
  sl.registerLazySingleton<AppwriteClient>(() => AppwriteClient());

  sl.registerLazySingleton<Client>(() => sl<AppwriteClient>().client);

  sl.registerLazySingleton<Databases>(() => sl<AppwriteClient>().database);

  sl.registerLazySingleton<Account>(() => sl<AppwriteClient>().account);

  sl.registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage());
}
