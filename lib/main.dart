import 'package:eventorize_app/common/services/session_manager.dart';
import 'package:eventorize_app/features/auth/view_model/register_view_model.dart';
import 'package:eventorize_app/features/auth/view_model/login_view_model.dart';
import 'package:eventorize_app/features/auth/view_model/verify_view_model.dart';
import 'package:eventorize_app/features/auth/view_model/account_view_model.dart';
import 'package:eventorize_app/features/auth/view_model/profile_detail_view_model.dart';
import 'package:eventorize_app/features/auth/view_model/home_view_model.dart';
import 'package:eventorize_app/features/auth/view_model/favorite_view_model.dart';
import 'package:eventorize_app/features/auth/view_model/event_detail_view_model.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:eventorize_app/router.dart';
import 'package:eventorize_app/common/services/dio_client.dart';
import 'package:eventorize_app/data/api/user_api.dart';
import 'package:eventorize_app/data/api/location_api.dart';
import 'package:eventorize_app/data/api/event_api.dart';
import 'package:eventorize_app/data/api/favorite_api.dart';
import 'package:eventorize_app/data/repositories/user_repository.dart';
import 'package:eventorize_app/data/repositories/location_repository.dart';
import 'package:eventorize_app/data/repositories/event_repository.dart';
import 'package:eventorize_app/data/repositories/favorite_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:eventorize_app/common/services/location_cache.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerSingleton<DioClient>(DioClient());
  getIt.registerSingleton<UserApi>(UserApi(getIt<DioClient>()));
  getIt.registerSingleton<UserRepository>(UserRepository(getIt<UserApi>()));
  getIt.registerSingleton<LocationApi>(LocationApi(getIt<DioClient>()));
  getIt.registerSingleton<LocationRepository>(LocationRepository(getIt<LocationApi>()));
  getIt.registerSingleton<EventApi>(EventApi(getIt<DioClient>()));
  getIt.registerSingleton<EventRepository>(EventRepository(getIt<EventApi>()));
  getIt.registerSingleton<FavoriteApi>(FavoriteApi(getIt<DioClient>()));
  getIt.registerSingleton<FavoriteRepository>(FavoriteRepository(getIt<FavoriteApi>()));
  getIt.registerSingleton<SessionManager>(SessionManager(getIt<UserRepository>()));
  getIt.registerSingleton<LocationCache>(LocationCache());
  getIt.registerFactory<EventDetailViewModel>(
    () => EventDetailViewModel(eventRepository: getIt<EventRepository>()),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env/dev.env");
  setupDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FavoriteRepository>(
          create: (_) => getIt<FavoriteRepository>(),
        ),
        ChangeNotifierProvider<SessionManager>(
          create: (_) => getIt<SessionManager>(),
        ),
        ChangeNotifierProvider<VerifyViewModel>(
          create: (_) => VerifyViewModel(getIt<UserRepository>()),
        ),
        ChangeNotifierProvider<LoginViewModel>(
          create: (_) => LoginViewModel(getIt<UserRepository>()),
        ),
        ChangeNotifierProvider<RegisterViewModel>(
          create: (_) => RegisterViewModel(getIt<UserRepository>()),
        ),
        ChangeNotifierProvider<AccountViewModel>(
          create: (_) => AccountViewModel(getIt<SessionManager>()),
        ),
        ChangeNotifierProvider<ProfileDetailViewModel>(
          create: (_) => ProfileDetailViewModel(
            getIt<UserRepository>(),
            getIt<LocationRepository>(),
          ),
        ),
        ChangeNotifierProvider<HomeViewModel>(
          create: (_) => HomeViewModel(
            getIt<EventRepository>(),
            getIt<SessionManager>(),
            getIt<LocationRepository>(),
            getIt<FavoriteRepository>(),
          ),
        ),
        ChangeNotifierProvider<FavoriteViewModel>(
          create: (_) => FavoriteViewModel(
            getIt<FavoriteRepository>(),
            getIt<SessionManager>(),
          ),
        ),
        ChangeNotifierProvider<EventDetailViewModel>(
          create: (_) => getIt<EventDetailViewModel>(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Eventorize',
        theme: ThemeData(
          useMaterial3: true,
        ),
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}