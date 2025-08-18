import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../repo/appwrite_repository.dart';
import 'package:dartz/dartz.dart';

class IsUserLoggedIn implements UseCase<bool, NoParams> {
  final AppwriteRepository appwriteRepository;

  IsUserLoggedIn(this.appwriteRepository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return appwriteRepository.isUserLoggedIn();
  }
}
