import 'package:dartz/dartz.dart';

import '../../features/number_trivia/domain/entities/number_trivia.dart';
import '../error/failures.dart';

abstract class UseCase<Type, Params>{
  Future<Either<Failure, Type>> call(Params params);
} 