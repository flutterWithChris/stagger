import 'package:buoy/core/errors/failure.dart';
import 'package:buoy/features/block/data/data_sources/block_record_data_source.dart';
import 'package:buoy/features/block/domain/repository/block_repository.dart';
import 'package:buoy/features/block/entitities/block_record.dart';
import 'package:dartz/dartz.dart';

class GetBlockedUsersUsecase {
  final BlockRecordRepository blockRecordRepository;

  GetBlockedUsersUsecase(this.blockRecordRepository);

  Future<Either<ServerFailure, List<BlockRecordEntity>>> call() async {
    try {
      return await blockRecordRepository.getBlockedUsers();
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
