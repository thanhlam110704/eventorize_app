import 'package:eventorize_app/common/services/session_manager.dart';
import 'package:eventorize_app/features/auth/view_model/register_view_model.dart';
import 'package:eventorize_app/features/auth/view_model/login_view_model.dart';
import 'package:eventorize_app/features/auth/view_model/verify_view_model.dart';
import 'package:eventorize_app/features/auth/view_model/account_view_model.dart';
import 'package:eventorize_app/features/auth/view_model/detail_profile_view_model.dart';
import 'package:eventorize_app/features/auth/view_model/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:eventorize_app/router.dart';
import 'package:eventorize_app/common/services/dio_client.dart';
import 'package:eventorize_app/data/api/user_api.dart';
import 'package:eventorize_app/data/api/location_api.dart';
import 'package:eventorize_app/data/api/event_api.dart';
import 'package:eventorize_app/data/repositories/user_repository.dart';
import 'package:eventorize_app/data/repositories/location_repository.dart';
import 'package:eventorize_app/data/repositories/event_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:eventorize_app/common/services/location_cache.dart'; 

void setupDependencies() {
  final getIt = GetIt.instance;
  getIt.registerSingleton<DioClient>(DioClient());
  getIt.registerSingleton<UserApi>(UserApi(getIt<DioClient>()));
  getIt.registerSingleton<UserRepository>(UserRepository(getIt<UserApi>()));
  getIt.registerSingleton<LocationApi>(LocationApi(getIt<DioClient>()));
  getIt.registerSingleton<LocationRepository>(LocationRepository(getIt<LocationApi>()));
  getIt.registerSingleton<EventApi>(EventApi(getIt<DioClient>()));
  getIt.registerSingleton<EventRepository>(EventRepository(getIt<EventApi>()));
  getIt.registerSingleton<SessionManager>(SessionManager(getIt<UserRepository>()));
  getIt.registerSingleton<LocationCache>(LocationCache());
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
        ChangeNotifierProvider<SessionManager>(
          create: (_) => SessionManager(GetIt.instance<UserRepository>()),
        ),
        ChangeNotifierProvider<VerifyViewModel>(
          create: (_) => VerifyViewModel(GetIt.instance<UserRepository>()),
        ),
        ChangeNotifierProvider<LoginViewModel>(
          create: (_) => LoginViewModel(GetIt.instance<UserRepository>()),
        ),
        ChangeNotifierProvider<RegisterViewModel>(
          create: (_) => RegisterViewModel(GetIt.instance<UserRepository>()),
        ),
        ChangeNotifierProvider<AccountViewModel>(
          create: (_) => AccountViewModel(GetIt.instance<SessionManager>()),
        ),
        ChangeNotifierProvider<DetailProfileViewModel>(
          create: (_) => DetailProfileViewModel(
            GetIt.instance<UserRepository>(),
            GetIt.instance<LocationRepository>(),
          ),
        ),
        ChangeNotifierProvider<HomeViewModel>(
          create: (_) => HomeViewModel(
            GetIt.instance<EventRepository>(),
            GetIt.instance<SessionManager>(),
            GetIt.instance<LocationRepository>(),
          ),
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