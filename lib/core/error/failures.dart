import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  Failure([List propertires = const <dynamic>[]]) : super(propertires);
}

//General Failures
class ServerFailure extends Failure{}

class CacheFailure extends Failure{}
