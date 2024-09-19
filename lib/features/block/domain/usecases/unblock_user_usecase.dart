import 'package:buoy/core/errors/failure.dart';
import 'package:buoy/features/block/data/data_sources/block_record_data_source.dart';
import 'package:buoy/features/block/domain/repository/block_repository.dart';
import 'package:dartz/dartz.dart';

class UnblockUserUsecase {
  final BlockRecordRepository blockRecordRepository;

  UnblockUserUsecase(this.blockRecordRepository);

  Future<Either<ServerFailure, void>> call(String userId) async {
    try {
      return await blockRecordRepository.unblockUser(userId);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
