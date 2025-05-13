
import 'package:eventorize_app/features/auth/view_model/home_view_model.dart';
import 'package:eventorize_app/features/auth/view_model/register_view_model.dart';
import 'package:eventorize_app/features/auth/view_model/login_view_model.dart';
import 'package:eventorize_app/features/auth/view_model/verify_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:eventorize_app/router.dart';
import 'package:eventorize_app/common/network/dio_client.dart';
import 'package:eventorize_app/data/api/user_api.dart';
import 'package:eventorize_app/data/repositories/user_repository.dart';
import 'package:get_it/get_it.dart';

void setupDependencies() {
  final getIt = GetIt.instance;
  if (!getIt.isRegistered<DioClient>()) {
    getIt.registerSingleton<DioClient>(DioClient());
  }
  if (!getIt.isRegistered<UserApi>()) {
    getIt.registerSingleton<UserApi>(UserApi(getIt<DioClient>()));
  }
  if (!getIt.isRegistered<UserRepository>()) {
    getIt.registerSingleton<UserRepository>(UserRepository(getIt<UserApi>()));
  }
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
        ChangeNotifierProvider<HomeViewModel>(
          create: (_) => HomeViewModel(GetIt.instance<UserRepository>()),
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