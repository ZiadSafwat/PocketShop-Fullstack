import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttermart/presentation/search/presentation/bloc/search_bloc.dart';
import 'package:fluttermart/presentation/search/presentation/bloc/search_event.dart';

import '../../presentation/home/presentation/bloc/home_bloc.dart' as home;

class AppFunction {
  static void updatePrevPages(BuildContext context, String productId,
      bool addOrRemove, userWishlistId) {
    try {
      BlocProvider.of<home.HomeBloc>(context).add(
        home.UpdateWishlistLocal(
          itemId: productId,
          addOrRemove: addOrRemove,
        ),
      );
    } catch (e) {
     print ('///////////////////home///////////////////');
     print (e);
    }
    try {
      BlocProvider.of<SearchBloc>(context).add(SearchUpdateFavEvent(
        productId,
        userWishlistId,
        addOrRemove,
        true,(){}
      ));
    } catch (e) {
      print ('///////////////////search///////////////////');
      print (e);
    }
  }
}
