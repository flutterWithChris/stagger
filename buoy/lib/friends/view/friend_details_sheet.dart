import 'package:buoy/core/system/main_sliver_app_bar.dart';
import 'package:buoy/friends/bloc/friends_bloc.dart';
import 'package:buoy/locate/model/location.dart';
import 'package:buoy/locate/view/widgets/friend_location_card.dart';
import 'package:buoy/shared/models/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gutter/flutter_gutter.dart';

class FriendDetailsSheet extends StatelessWidget {
  final String friendId;
  final Location location;
  final ScrollController scrollController;
  const FriendDetailsSheet(
      {super.key,
      required this.friendId,
      required this.location,
      required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      shrinkWrap: true,
      slivers: [
        //MainSliverAppBar(),
        SliverFillRemaining(
          child: BlocBuilder<FriendsBloc, FriendsState>(
            builder: (context, state) {
              if (state is FriendsLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is FriendsError) {
                return const Center(child: Text('Error'));
              }
              if (state is FriendsLoaded) {
                User friend = state.friends.firstWhere(
                    (element) => element.id == friendId,
                    orElse: () => User());
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 24.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 48.0,
                        foregroundImage: friend.photoUrl != null
                            ? CachedNetworkImageProvider(friend.photoUrl!)
                            : null,
                        child: const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 48.0,
                        ),
                      ),
                      const Gutter(),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            friend.name!,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const GutterSmall(),
                          Wrap(
                            spacing: 6.0,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Icon(
                                Icons.location_pin,
                                color: Theme.of(context).primaryColor,
                                size: 18.0,
                              ),
                              Text(
                                '${location.latitude}, ${location.longitude}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          const GutterSmall(),
                          Wrap(
                            spacing: 6.0,
                            children: [
                              if (location.activity != null)
                                SizedBox(
                                    height: 34,
                                    child: ActivityChip(
                                        activity: location.activity)),
                              const GutterSmall(),
                              if (location.batteryLevel != null)
                                SizedBox(
                                    height: 32,
                                    child: BatteryChip(
                                        batteryLevel: location.batteryLevel)),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                );
              } else {
                return const Center(child: Text('Something Went Wrong...'));
              }
            },
          ),
        ),
      ],
    );
  }
}
