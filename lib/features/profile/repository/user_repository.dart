import 'package:buoy/core/constants.dart';
import 'package:buoy/core/errors/failure.dart';
import 'package:buoy/shared/models/user.dart';
import 'package:dartz/dartz.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
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
      await Sentry.captureException(e, stackTrace: StackTrace.current);
      scaffoldMessengerKey.currentState?.showSnackBar(
        getErrorSnackbar('Failed to create user'),
      );
      return Left(DatabaseFailure('Failed to create user'));
      print(e);
    }
  }

  /// Fetch a user by id
  Future<User?> getUserById(String id) async {
    try {
      final Map<String, dynamic> response =
          await _client.from('users').select().eq('id', id).single();

      return User.fromMap(response);
    } catch (e) {
      print(e);
      scaffoldMessengerKey.currentState?.showSnackBar(
        getErrorSnackbar('Failed to fetch user'),
      );
      await Sentry.captureException(e, stackTrace: StackTrace.current);
      return null;
    }
  }

  /// Fetch a user by email
  Future<User?> getUserByEmail(String email) async {
    try {
      final Map<String, dynamic> response =
          await _client.from('users').select().eq('email', email).single();

      return User.fromMap(response);
    } catch (e) {
      print(e);
      scaffoldMessengerKey.currentState?.showSnackBar(
        getErrorSnackbar('Failed to fetch user'),
      );
      await Sentry.captureException(e, stackTrace: StackTrace.current);
      return null;
    }
  }

  /// Update a user
  Future<void> updateUser(User user) async {
    try {
      await _client.from('users').update(user.toMap()).eq('id', user.id!);
    } catch (e) {
      print(e);
      scaffoldMessengerKey.currentState?.showSnackBar(
        getErrorSnackbar('Failed to update user'),
      );
      await Sentry.captureException(e, stackTrace: StackTrace.current);
    }
  }

  /// Delete a user
  Future<void> deleteUser(String id) async {
    try {
      await _client.from('users').delete().eq('id', id);
    } catch (e) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        getErrorSnackbar('Failed to delete user'),
      );
      await Sentry.captureException(e, stackTrace: StackTrace.current);
      print(e);
    }
  }
}
