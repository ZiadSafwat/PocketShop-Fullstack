import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fluttermart/presentation/product_detail_screen/data/datasources/product_detail_remote_data_source.dart';
import 'package:fluttermart/presentation/product_detail_screen/data/repositories/product_detail_repository_impl.dart';
import 'package:fluttermart/presentation/product_detail_screen/domain/repositories/product_detail_repository.dart';
import 'package:fluttermart/presentation/product_detail_screen/domain/usecases/get_product_detail.dart';
import 'package:fluttermart/presentation/product_detail_screen/presentation/bloc/product_detail_bloc.dart';
import 'package:fluttermart/presentation/search/presentation/bloc/search_bloc.dart';
import 'package:fluttermart/presentation/shopping_cart_screen/data/datasources/cart_remote_data_source.dart';
import 'package:fluttermart/presentation/shopping_cart_screen/data/repositories/cart_repository_impl.dart';
import 'package:fluttermart/presentation/shopping_cart_screen/domain/repositories/cart_repository.dart';
import 'package:fluttermart/presentation/shopping_cart_screen/domain/usecases/apply_promo_code.dart';
import 'package:fluttermart/presentation/shopping_cart_screen/domain/usecases/clear_cart.dart';
import 'package:fluttermart/presentation/shopping_cart_screen/domain/usecases/get_cart_items.dart';
import 'package:fluttermart/presentation/shopping_cart_screen/domain/usecases/remove_from_cart.dart';
import 'package:fluttermart/presentation/shopping_cart_screen/domain/usecases/update_quantity.dart';
import 'package:fluttermart/presentation/shopping_cart_screen/presentation/bloc/cart_bloc.dart';
 import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../../presentation/Auth/data/datasources/auth_local_data_source.dart';
import '../../presentation/Auth/data/datasources/auth_remote_data_source.dart';
import '../../presentation/Auth/data/repositories/auth_repository_impl.dart';
import '../../presentation/Auth/domain/repositories/auth_repository.dart';
import '../../presentation/Auth/domain/usecases/login_usecase.dart';
 import '../../presentation/Auth/presentation/bloc/auth_bloc.dart';
import '../../presentation/home/data/datasources/home_local_data_source.dart';
import '../../presentation/home/data/datasources/home_remote_data_source.dart';
import '../../presentation/home/data/repositories/home_repository_impl.dart';
import '../../presentation/home/domain/repositories/home_repository.dart';
import '../../presentation/home/domain/usecases/get_home_data.dart';
import '../../presentation/home/presentation/bloc/home_bloc.dart';
import '../../presentation/search/data/datasources/search_local_data_source.dart';
import '../../presentation/search/data/datasources/search_remote_data_source.dart';
import '../../presentation/search/data/repositories/search_repository_impl.dart';
import '../../presentation/search/domain/repositories/search_repository.dart';
import '../../presentation/search/domain/usercases/search_products.dart';
import '../connection/network_info.dart';
import '../databases/api/api_consumer.dart';
import '../databases/api/dio_consumer.dart';
import '../databases/cache/cache_helper.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Add Connectivity package registration
  sl.registerLazySingleton(() => Connectivity());

  // Register CacheHelper with async initialization
  sl.registerLazySingletonAsync<CacheHelper>(() async => await CacheHelper.create());

  // Ensure CacheHelper is initialized before dependent services
  await sl.isReady<CacheHelper>();

  // BLoC
  sl.registerFactory(() => AuthBloc(loginUseCase: sl(), authCheckUseCase: sl(),logoutUseCase: sl()));

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => AuthCheckUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
    networkInfo: sl(),
    remoteDataSource: sl(),
    localDataSource: sl(),
  ));

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
        () => AuthLocalDataSource(cache: sl()),
  );

  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton<ApiConsumer>(() => DioConsumer(dio: sl(),authLocalDataSource: sl()));

  // External
  sl.registerLazySingleton(() => Dio());



  //////////////////// Home feature //////////////////////
  sl.registerFactory(() => HomeBloc(
    getHomeData: sl(),
    removeRecentSearch: sl(),
    addTOFav: sl()
  ));


  sl.registerLazySingleton(() => GetHomeData(sl()));
  sl.registerLazySingleton(() => AddTOFav(sl()));
  sl.registerLazySingleton(() => RemoveRecentSearch(sl()));

  sl.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl(
    remoteDataSource: sl(),authLocalDataSource: sl(),
    localDataSource: sl(),
    networkInfo: sl(),
  ));


  sl.registerLazySingleton<HomeRemoteDataSource>(
        () => HomeRemoteDataSourceImpl(apiConsumer: sl()),
  );

  sl.registerLazySingleton<HomeLocalDataSource>(
        () => HomeLocalDataSourceImpl(cacheHelper: sl()),
  );


  //////////////////// product details feature //////////////////////

  sl.registerFactory(() => ProductDetailBloc(
      getProductDetail: sl(),addTOFav: sl(),
  ));

  sl.registerLazySingleton(() => GetProductDetail(sl()));
  sl.registerLazySingleton(() => AddTOFavPro(sl()));

  sl.registerLazySingleton< ProductDetailRepository>(() => ProductDetailRepositoryImpl(
      networkInfo: sl(),
      remoteDataSource: sl(),

  ));
  sl.registerLazySingleton<ProductDetailRemoteDataSource>(
        () => ProductDetailRemoteDataSourceImpl(dio : sl()),
  );
  ////////////////////////////////////////search/////////////////////////////////
  sl.registerFactory(() => SearchBloc( searchProducts: sl(),updateFavState: sl()));

  sl.registerLazySingleton(() => SearchProducts( sl()));
  sl.registerLazySingleton(() => UpdateFavState( sl()));

  sl.registerLazySingleton<SearchRepository>(() => SearchRepositoryImpl(
    remoteDataSource: sl(),
    localDataSource: sl(),
    networkInfo: sl(),
  ));

  sl.registerLazySingleton<SearchRemoteDataSource>(
        () => SearchRemoteDataSourceImpl(apiConsumer: sl()),
  );

  sl.registerLazySingleton<SearchLocalDataSource>(
        () => SearchLocalDataSourceImpl(cacheHelper: sl()),
  );

  // Cart Feature
  sl.registerFactory(() => CartBloc(
    getCartItems: sl(),
    removeFromCart: sl(),
    updateQuantity: sl(),
    clearCart: sl(),
    applyPromoCode: sl(),
  ));

  sl.registerLazySingleton(() => GetCartItems(sl()));
  sl.registerLazySingleton(() => RemoveFromCart(sl()));
  sl.registerLazySingleton(() => UpdateQuantity(sl()));
  sl.registerLazySingleton(() => ClearCart(sl()));
  sl.registerLazySingleton(() => ApplyPromoCode(sl()));

  sl.registerLazySingleton<CartRepository>(() => CartRepositoryImpl(
    remoteDataSource: sl(),
  ));

  sl.registerLazySingleton<CartRemoteDataSource>(() => CartRemoteDataSourceImpl(
    apiConsumer: sl(),
  ));
}