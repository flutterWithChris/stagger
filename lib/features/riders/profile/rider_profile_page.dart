import 'package:buoy/core/system/bottom_nav_bar.dart';
import 'package:buoy/core/system/main_sliver_app_bar.dart';
import 'package:buoy/features/friends/bloc/friends_bloc.dart';
import 'package:buoy/features/riders/bloc/rider_profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gutter/flutter_gutter.dart';

class RiderProfilePage extends StatelessWidget {
  const RiderProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomNavBar(),
      body: BlocBuilder<RiderProfileBloc, RiderProfileState>(
        builder: (context, state) {
          if (state is RiderProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is RiderProfileError) {
            return Center(child: Text(state.message));
          }
          if (state is RiderProfileLoaded) {
            return CustomScrollView(
              slivers: [
                const MainSliverAppBar(),
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        ListTile(
                          leading: const CircleAvatar(
                              child: Icon(Icons.person_pin_circle_rounded)),
                          title: Text(state.rider.firstName!),
                          subtitle: Text(state.rider.email!),
                        ),
                        const Gutter(),
                        Wrap(
                          spacing: 8.0,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Icon(Icons.groups, size: 18.0),
                            Text(
                              'Friends',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const Gutter(),
                        BlocBuilder<FriendsBloc, FriendsState>(
                          builder: (context, state) {
                            if (state is FriendsLoading) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (state is FriendsError) {
                              return const Center(child: Text('Error'));
                            }
                            if (state is FriendsLoaded) {
                              if (state.friends.isEmpty) {
                                return const Center(child: Text('No friends'));
                              }
                              return Column(
                                children: [
                                  for (final friend in state.friends)
                                    ListTile(
                                      leading: const CircleAvatar(
                                          child: Icon(
                                              Icons.person_pin_circle_rounded)),
                                      title: Text(friend.firstName!),
                                      subtitle: Text(friend.email!),
                                    ),
                                ],
                              );
                            }
                            return const Center(
                                child: Text('Something went wrong...'));
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          return const Center(child: Text('Something went wrong...'));
        },
      ),
    );
  }
}
