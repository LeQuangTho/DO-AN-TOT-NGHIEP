import 'package:flutter_cahoi_barbershop/core/apis/api.dart';
import 'package:flutter_cahoi_barbershop/core/services/auth_service.dart';
import 'package:flutter_cahoi_barbershop/core/services/booking_service.dart';
import 'package:flutter_cahoi_barbershop/core/services/post_service.dart';
import 'package:flutter_cahoi_barbershop/core/services/role_service.dart';
import 'package:flutter_cahoi_barbershop/core/services/shared_preferences_service.dart';
import 'package:flutter_cahoi_barbershop/core/services/task_service.dart';
import 'package:flutter_cahoi_barbershop/core/services/user_service.dart';
import 'package:flutter_cahoi_barbershop/core/services/youtube_service.dart';
import 'package:flutter_cahoi_barbershop/core/state_models/admin_model/hr_model.dart';
import 'package:flutter_cahoi_barbershop/core/state_models/admin_model/product_model.dart';
import 'package:flutter_cahoi_barbershop/core/state_models/auth_model.dart';
import 'package:flutter_cahoi_barbershop/core/state_models/booking_model.dart';
import 'package:flutter_cahoi_barbershop/core/state_models/history_model.dart';
import 'package:flutter_cahoi_barbershop/core/state_models/home_page_model.dart';
import 'package:flutter_cahoi_barbershop/core/state_models/story_model.dart';
import 'package:flutter_cahoi_barbershop/core/state_models/stylist_model/report_task_model.dart';
import 'package:flutter_cahoi_barbershop/ui/utils/store_secure.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  //APIs - Services
  locator.registerLazySingleton(() => YoutubeService());
  locator.registerLazySingleton(() => StoreSecure());
  locator.registerLazySingleton(() => SharedPreferencesService());
  locator.registerLazySingleton(() => AuthenticationService());
  locator.registerLazySingleton(() => UserService());
  locator.registerLazySingleton(() => TaskService());
  locator.registerLazySingleton(() => BookingService());
  locator.registerLazySingleton(() => RoleService());
  locator.registerLazySingleton(() => PostService());

  //Api
  locator.registerLazySingleton(() => Api());

  //ViewModels
  locator.registerFactory(() => BookingModel());
  locator.registerFactory(() => AuthModel());
  locator.registerFactory(() => HomePageModel());
  locator.registerFactory(() => HistoryModel());
  locator.registerFactory(() => HRModel());
  locator.registerFactory(() => ProductModel());
  locator.registerFactory(() => StoryModel());
  locator.registerFactory(() => ReportTaskModel());
}
