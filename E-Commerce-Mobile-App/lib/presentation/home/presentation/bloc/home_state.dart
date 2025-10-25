part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {

  final HomeEntity homeData;

  const HomeLoaded(this.homeData);

  @override
  List<Object> get props => [homeData];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object> get props => [message];
}



class FavLoading extends HomeState {
  final String itemId;

  const FavLoading(this.itemId);

  @override
  List<Object> get props => [itemId];
}

class FavLoaded extends HomeState{
  final String itemId;

  const FavLoaded(this.itemId);

  @override
  List<Object> get props => [itemId];
}
class FavError extends HomeState {
  final String message;

  const FavError(this.message);

  @override
  List<Object> get props => [message];
}

