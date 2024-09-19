import 'package:buoy/core/errors/failure.dart';
import 'package:buoy/features/block/data/data_sources/block_record_data_source.dart';
import 'package:buoy/features/block/data/models/block_record.dart';
import 'package:buoy/features/block/domain/repository/block_repository.dart';
import 'package:buoy/features/block/entitities/block_record.dart';
import 'package:dartz/dartz.dart';

class BlockUserUsecase {
  final BlockRecordRepository blockRecordRepository;

  BlockUserUsecase(this.blockRecordRepository);

  Future<Either<ServerFailure, BlockRecordEntity>> call(String userId) async {
    try {
      return await blockRecordRepository.blockUser(userId).then((value) {
        return value.fold((l) => Left(l), (r) => Right(r));
      });
    } catch (e) {
      rethrow;
    }
  }
}
