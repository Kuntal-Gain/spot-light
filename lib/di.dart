import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:spot_time/feature/event/app/cubit/cred/cred_cubit.dart';
import 'package:spot_time/feature/event/app/cubit/event/event_cubit.dart';
import 'package:spot_time/feature/event/domain/usecases/auth/create_user_usecase.dart';
import 'package:spot_time/feature/event/domain/usecases/events/add_event_usecase.dart';
import 'package:spot_time/feature/event/domain/usecases/events/create_poll_usecase.dart';
import 'package:spot_time/feature/event/domain/usecases/events/send_message_usecase.dart';
import 'package:spot_time/feature/event/domain/usecases/events/vote_poll_usecase.dart';
import 'feature/event/app/cubit/auth/auth_cubit.dart';
import 'feature/event/app/cubit/chat/chat_cubit.dart';
import 'feature/event/app/cubit/poll/poll_cubit.dart';
import 'feature/event/data/data_sources/remote_datasource.dart';
import 'feature/event/data/data_sources/remote_datasource_impl.dart';
import 'feature/event/data/repo/firebase_repository_impl.dart';
import 'feature/event/domain/repo/firebase_repository.dart';
import 'feature/event/domain/usecases/auth/get_current_uid_usecase.dart';
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
      getCurrentUid: sl.call(),
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
  sl.registerLazySingleton<GetCurrentUid>(() => GetCurrentUid(sl.call()));
  sl.registerLazySingleton<CreateUserUseCase>(
      () => CreateUserUseCase(sl.call()));

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
  sl.registerLazySingleton<FirebaseRepository>(
      () => FirebaseRepositoryImpl(remoteDataSource: sl.call()));
  sl.registerLazySingleton<RemoteDataSource>(
    () => RemoteDataSourceImpl(
      firestore: sl.call(),
      auth: sl.call(),
      db: sl.call(),
    ),
  );

  /// [externals]
  /// [firestore]
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseDatabase>(() => FirebaseDatabase.instance);

  sl.registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage());
}
