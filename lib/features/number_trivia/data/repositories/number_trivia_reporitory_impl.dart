import 'package:dartz/dartz.dart';
import 'package:tdnumbers/core/error/failures.dart';
import 'package:tdnumbers/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:tdnumbers/features/number_trivia/domain/repositories/number_trivia_repository.dart';

class NumberTriviaRepositoryImplementation implements NumberTriviaRepository{
  @override
  Future<Either<Failure, NumberTrivia>> getConcreteNumberTrivia(int number) {
    // TODO: implement getConcreteNumberTrivia
    return null;
  }

  @override
  Future<Either<Failure, NumberTrivia>> getRandomNumberTrivia() {
    // TODO: implement getRandomNumberTrivia
    return null;
  }

}