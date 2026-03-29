import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Model/user_model.dart';
import '../../../Services/api-service.dart';
// Ensure you have this model

abstract class HomeEvent {}
class LoadHomeData extends HomeEvent {}

abstract class HomeState {}
class HomeInitial extends HomeState {}
class HomeLoading extends HomeState {}
class HomeLoaded extends HomeState {
  final UserModel profile;
  HomeLoaded(this.profile);
}
class HomeError extends HomeState {}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ApiService _apiService = ApiService();

  HomeBloc() : super(HomeInitial()) {
    on<LoadHomeData>((event, emit) async {
      emit(HomeLoading());
      try {
        final data = await _apiService.getProfile();
        final profile = UserModel.fromMap(data);
        emit(HomeLoaded(profile));
      } catch (e) {
        emit(HomeError());
      }
    });
  }
}