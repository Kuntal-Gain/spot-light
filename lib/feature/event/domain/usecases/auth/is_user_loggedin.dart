import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../repo/firebase_repository.dart';
import 'package:dartz/dartz.dart';

class IsUserLoggedIn implements UseCase<bool, NoParams> {
  final FirebaseRepository firebaseRepository;

  IsUserLoggedIn(this.firebaseRepository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return firebaseRepository.isUserLoggedIn();
  }
}
