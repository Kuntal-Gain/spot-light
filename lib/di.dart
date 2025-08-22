import 'package:appwrite/appwrite.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:spot_time/feature/event/app/cubit/cred/cred_cubit.dart';
import 'package:spot_time/feature/event/app/cubit/event/event_cubit.dart';
import 'package:spot_time/feature/event/domain/usecases/events/add_event_usecase.dart';
import 'package:spot_time/feature/event/domain/usecases/events/create_poll_usecase.dart';
import 'package:spot_time/feature/event/domain/usecases/events/send_message_usecase.dart';
import 'package:spot_time/feature/event/domain/usecases/events/vote_poll_usecase.dart';

import 'core/network/appwrite_client.dart';
import 'feature/event/app/cubit/auth/auth_cubit.dart';
import 'feature/event/app/cubit/chat/chat_cubit.dart';
import 'feature/event/app/cubit/poll/poll_cubit.dart';
import 'feature/event/data/data_sources/remote_datasource.dart';
import 'feature/event/data/data_sources/remote_datasource_impl.dart';
import 'feature/event/data/repo/appwrite_repository.dart';
import 'feature/event/domain/repo/appwrite_repository.dart';
import 'feature/event/domain/usecases/auth/get_current_user.dart';
import 'feature/event/domain/usecases/auth/is_user_loggedin.dart';
import 'feature/event/domain/usecases/auth/login_with_email.dart';
import 'feature/event/domain/usecases/auth/logout_user.dart';
import 'feature/event/domain/usecases/auth/register_with_email.dart';
import 'feature/event/domain/usecases/events/fetch_messages_usecase.dart';
import 'feature/event/domain/usecases/events/get_events_usecase.dart';
import 'feature/event/domain/usecases/events/get_single_event_usecase.dart';

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

  sl.registerFactory(
    () => AuthCubit(
      isUserLoggedIn: sl.call(),
      getCurrentUser: sl.call(),
    ),
  );

  sl.registerFactory(
    () => EventCubit(
      addEventUseCase: sl.call(),
      getEventsUseCase: sl.call(),
      getSingleEventUseCase: sl.call(),
    ),
  );

  sl.registerFactory(
    () => ChatCubit(
      fetchMessagesUsecase: sl.call(),
      sendMessageUsecase: sl.call(),
    ),
  );

  sl.registerFactory(
    () => PollCubit(
      createNewPollUsecase: sl.call(),
      votePollUsecase: sl.call(),
    ),
  );

  // TODO: other cubits

  /// [usecases]
  sl.registerLazySingleton<GetCurrentUser>(() => GetCurrentUser(sl.call()));
  sl.registerLazySingleton<LoginWithEmail>(() => LoginWithEmail(sl.call()));
  sl.registerLazySingleton<RegisterWithEmail>(
      () => RegisterWithEmail(sl.call()));
  sl.registerLazySingleton<LogoutUser>(() => LogoutUser(sl.call()));
  sl.registerLazySingleton<IsUserLoggedIn>(() => IsUserLoggedIn(sl.call()));

  sl.registerLazySingleton<AddEvent>(() => AddEvent(sl.call()));
  sl.registerLazySingleton<GetEvents>(() => GetEvents(sl.call()));
  sl.registerLazySingleton<GetSingleEvent>(() => GetSingleEvent(sl.call()));
  sl.registerLazySingleton<FetchMessagesUsecase>(
      () => FetchMessagesUsecase(sl.call()));
  sl.registerLazySingleton<SendMessage>(() => SendMessage(sl.call()));
  sl.registerLazySingleton<CreateNewPoll>(() => CreateNewPoll(sl.call()));
  sl.registerLazySingleton<VotePollUsecase>(() => VotePollUsecase(sl.call()));

  // TODO: other usecases

  /// [repository]
  sl.registerLazySingleton<AppwriteRepository>(
      () => AppwriteRepositoryImpl(remoteDataSource: sl.call()));
  sl.registerLazySingleton<RemoteDataSource>(
    () => RemoteDataSourceImpl(
      account: sl.call(),
      database: sl.call(),
      storage: sl.call(),
      realtime: sl.call(),
    ),
  );

  /// [externals]
  sl.registerLazySingleton<AppwriteClient>(() => AppwriteClient());

  sl.registerLazySingleton<Client>(() => sl<AppwriteClient>().client);

  sl.registerLazySingleton<Databases>(() => sl<AppwriteClient>().database);

  sl.registerLazySingleton<Account>(() => sl<AppwriteClient>().account);

  sl.registerLazySingleton<Realtime>(() => sl<AppwriteClient>().realtime);

  sl.registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage());
}
