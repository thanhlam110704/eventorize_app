import 'package:eventorize_app/common/services/session_manager.dart';
import 'package:eventorize_app/features/auth/user_view_model/register_view_model.dart';
import 'package:eventorize_app/features/auth/user_view_model/login_view_model.dart';
import 'package:eventorize_app/features/auth/user_view_model/verify_view_model.dart';
import 'package:eventorize_app/features/auth/user_view_model/account_view_model.dart';
import 'package:eventorize_app/features/auth/user_view_model/profile_detail_view_model.dart';
import 'package:eventorize_app/features/auth/user_view_model/home_view_model.dart';
import 'package:eventorize_app/features/auth/user_view_model/favorite_view_model.dart';
import 'package:eventorize_app/features/auth/user_view_model/event_detail_view_model.dart';
import 'package:eventorize_app/features/auth/user_view_model/check_out_view_model.dart';
import 'package:eventorize_app/features/auth/user_view_model/payment_view_model.dart';
import 'package:eventorize_app/features/auth/user_view_model/ticket_view_model.dart';
import 'package:eventorize_app/features/auth/user_view_model/ticket_detail_view_model.dart';
import 'package:eventorize_app/features/auth/organization_view_model/select_org_view_model.dart';
import 'package:eventorize_app/features/auth/organization_view_model/org_info_view_model.dart';
import 'package:eventorize_app/features/auth/organization_view_model/event_list_view_model.dart';
import 'package:eventorize_app/features/auth/organization_view_model/edit_event_view_model.dart';
import 'package:eventorize_app/features/auth/organization_view_model/create_event_view_model.dart';
import 'package:eventorize_app/core/utils/datetime_convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:eventorize_app/router.dart';
import 'package:eventorize_app/common/services/dio_client.dart';
import 'package:eventorize_app/data/api/user_api.dart';
import 'package:eventorize_app/data/api/location_api.dart';
import 'package:eventorize_app/data/api/event_api.dart';
import 'package:eventorize_app/data/api/favorite_api.dart';
import 'package:eventorize_app/data/api/ticket_api.dart';
import 'package:eventorize_app/data/api/order_api.dart';
import 'package:eventorize_app/data/api/payment_api.dart';
import 'package:eventorize_app/data/api/organizer_api.dart';
import 'package:eventorize_app/data/repositories/user_repository.dart';
import 'package:eventorize_app/data/repositories/location_repository.dart';
import 'package:eventorize_app/data/repositories/event_repository.dart';
import 'package:eventorize_app/data/repositories/favorite_repository.dart';
import 'package:eventorize_app/data/repositories/ticket_repository.dart';
import 'package:eventorize_app/data/repositories/order_repository.dart';
import 'package:eventorize_app/data/repositories/payment_repository.dart';
import 'package:eventorize_app/data/repositories/organizer_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:eventorize_app/common/services/location_cache.dart';
import 'package:intl/date_symbol_data_local.dart';

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
  getIt.registerSingleton<TicketApi>(TicketApi(getIt<DioClient>()));
  getIt.registerSingleton<TicketRepository>(TicketRepository(getIt<TicketApi>()));
  getIt.registerSingleton<OrderApi>(OrderApi(getIt<DioClient>()));
  getIt.registerSingleton<OrderRepository>(OrderRepository(getIt<OrderApi>()));
  getIt.registerSingleton<PaymentApi>(PaymentApi(getIt<DioClient>()));
  getIt.registerSingleton<PaymentRepository>(PaymentRepository(getIt<PaymentApi>()));
  getIt.registerSingleton<OrganizerApi>(OrganizerApi(getIt<DioClient>()));
  getIt.registerSingleton<OrganizerRepository>(OrganizerRepository(getIt<OrganizerApi>()));
  getIt.registerSingleton<SessionManager>(SessionManager(getIt<UserRepository>()));
  getIt.registerSingleton<LocationCache>(LocationCache());
  getIt.registerSingleton<EventListViewModel>(
    EventListViewModel(
      eventRepository: getIt<EventRepository>(),
      sessionManager: getIt<SessionManager>(),
    ),
  );
  getIt.registerSingleton<EditEventViewModel>(
    EditEventViewModel(
      eventRepository: getIt<EventRepository>(),
      sessionManager: getIt<SessionManager>(),
      locationRepository: getIt<LocationRepository>(),
    ),
  );
  getIt.registerSingleton<CreateEventViewModel>(
    CreateEventViewModel(
      eventRepository: getIt<EventRepository>(),
      sessionManager: getIt<SessionManager>(),
      locationRepository: getIt<LocationRepository>(),
    ),
  );
  getIt.registerFactory<EventDetailViewModel>(
    () => EventDetailViewModel(
      eventRepository: getIt<EventRepository>(),
      ticketRepository: getIt<TicketRepository>(),
      organizerRepository: getIt<OrganizerRepository>(),
    ),
  );
  getIt.registerFactory<PaymentViewModel>(
    () => PaymentViewModel(
      paymentRepository: getIt<PaymentRepository>(),
    ),
  );
  getIt.registerFactory<TicketViewModel>(
    () => TicketViewModel(
      orderRepository: getIt<OrderRepository>(),
    ),
  );
  getIt.registerFactory<TicketDetailViewModel>(
    () => TicketDetailViewModel(
      orderRepository: getIt<OrderRepository>(),
    ),
  );
  getIt.registerFactory<SelectOrgViewModel>(
    () => SelectOrgViewModel(
      organizerRepository: getIt<OrganizerRepository>(),
      sessionManager: getIt<SessionManager>(),
    ),
  );
  getIt.registerFactory<OrgInfoViewModel>(
    () => OrgInfoViewModel(
      getIt<OrganizerRepository>(),
      getIt<SessionManager>(),
      getIt<LocationRepository>(),
    ),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi_VN', null);
  await DateTimeConverter.initialize();
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
        Provider<OrderRepository>(
          create: (_) => getIt<OrderRepository>(),
        ),
        Provider<PaymentRepository>(
          create: (_) => getIt<PaymentRepository>(),
        ),
        Provider<OrganizerRepository>(
          create: (_) => getIt<OrganizerRepository>(),
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
        ChangeNotifierProvider<CheckOutViewModel>(
          create: (_) => CheckOutViewModel(
            getIt<PaymentRepository>(),
            getIt<OrderRepository>(),
          ),
        ),
        ChangeNotifierProvider<PaymentViewModel>(
          create: (_) => getIt<PaymentViewModel>(),
        ),
        ChangeNotifierProvider<TicketViewModel>(
          create: (_) => getIt<TicketViewModel>(),
        ),
        ChangeNotifierProvider<TicketDetailViewModel>(
          create: (_) => getIt<TicketDetailViewModel>(),
        ),
        ChangeNotifierProvider<SelectOrgViewModel>(
          create: (_) => getIt<SelectOrgViewModel>(),
        ),
        ChangeNotifierProvider<OrgInfoViewModel>(
          create: (_) => getIt<OrgInfoViewModel>(),
        ),
        ChangeNotifierProvider<EventListViewModel>(
          create: (_) => getIt<EventListViewModel>(),
        ),
        ChangeNotifierProvider<EditEventViewModel>(
          create: (_) => getIt<EditEventViewModel>(),
        ),
        ChangeNotifierProvider<CreateEventViewModel>(
          create: (_) => getIt<CreateEventViewModel>(),
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