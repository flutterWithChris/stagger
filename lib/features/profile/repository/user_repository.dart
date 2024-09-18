import 'package:buoy/core/errors/failure.dart';
import 'package:buoy/shared/models/user.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class UserRepository {
  final sb.SupabaseClient _client = sb.Supabase.instance.client;

  /// Create a new user
  Future<Either<Failure, User>> createUser({required User user}) async {
    try {
      final response =
          await _client.from('users').insert(user.toMap()).select();

      return Right(User.fromMap(response.first));
    } catch (e) {
      print(e);
      return Left(DatabaseFailure('Failed to create user'));
      print(e);
    }
  }

  /// Fetch a user by id
  Future<User?> getUserById(String id) async {
    final Map<String, dynamic> response =
        await _client.from('users').select().eq('id', id).single();

    // if (response.error != null) {
    //   throw response.error!;
    // }

    // Check if any data was returned
    // if (response.data == null || response.data.isEmpty) {
    //   print('User not found');
    //   throw Exception('User not found');

    //   return null;
    // }

    // // Check if more than one user was returned
    // if (response.data.length > 1) {
    //   print('Duplicate user IDs detected');
    //   throw Exception('Duplicate user IDs detected');
    // }

    return User.fromMap(response);
  }

  /// Fetch a user by email
  Future<User?> getUserByEmail(String email) async {
    try {
      final Map<String, dynamic> response =
          await _client.from('users').select().eq('email', email).single();

      return User.fromMap(response);
    } catch (e) {
      print(e);
      return null;
    }
  }

  /// Update a user
  Future<void> updateUser(User user) async {
    await _client.from('users').update(user.toMap()).eq('id', user.id!);
  }

  /// Delete a user
  Future<void> deleteUser(String id) async {
    try {
      await _client.from('users').delete().eq('id', id);
    } catch (e) {
      print(e);
    }
  }
}
