import 'package:buoy/core/system/bottom_nav_bar.dart';
import 'package:buoy/core/system/main_sliver_app_bar.dart';
import 'package:buoy/profile/repository/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gutter/flutter_gutter.dart';

import '../../friends/bloc/friends_bloc.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: const BottomNavBar(),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ProfileError) {
              return Center(child: Text(state.message));
            }
            if (state is ProfileLoaded) {
              return CustomScrollView(
                slivers: [
                  MainSliverAppBar(),
                  SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          ListTile(
                            leading: CircleAvatar(
                                child: const Icon(
                                    Icons.person_pin_circle_rounded)),
                            title: Text(state.user.name!),
                            subtitle: Text(state.user.email!),
                          ),
                          Gutter(),
                          Wrap(
                            spacing: 8.0,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Icon(Icons.groups, size: 18.0),
                              Text(
                                'Friends',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
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
                                  return const Center(
                                      child: Text('No Friends'));
                                } else {
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: state.friends.length,
                                    itemBuilder: (context, index) {
                                      return Card(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0, vertical: 8.0),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 26,
                                                foregroundImage: state
                                                            .friends[index]
                                                            .photoUrl !=
                                                        null
                                                    ? NetworkImage(state
                                                        .friends[index]
                                                        .photoUrl!)
                                                    : null,
                                                child: state.friends[index]
                                                            .photoUrl ==
                                                        null
                                                    ? const Icon(
                                                        Icons.person_rounded,
                                                        color: Colors.white,
                                                        size: 48.0,
                                                      )
                                                    : null,
                                              ),
                                              Gutter(),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    state.friends[index].name!,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                  Text(state
                                                      .friends[index].email!),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }
                              }
                              return Center(
                                  child: Text('Something Went Wrong...'));
                            },
                          )
                          // ListTile(
                          //   leading: const Icon(Icons.location_on_rounded),
                          //   title: Text(state.profile.location),
                          // ),
                          // ListTile(
                          //   leading: const Icon(Icons.data_usage_rounded),
                          //   title: Text(state.profile.dataUsage.toString()),
                          // ),
                          // ListTile(
                          //   leading: const Icon(Icons.settings_rounded),
                          //   title: Text('Settings'),
                          //   onTap: () {
                          //     Navigator.pushNamed(context, '/settings');
                          //   },
                          // ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
            return Container();
          },
        ));
  }
}
