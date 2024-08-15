import 'package:buoy/friends/bloc/friends_bloc.dart';
import 'package:buoy/locate/model/location.dart';
import 'package:buoy/locate/view/widgets/activity_chip.dart';
import 'package:buoy/locate/view/widgets/battery_chip.dart';
import 'package:buoy/profile/repository/bloc/profile_bloc.dart';
import 'package:buoy/rides/bloc/ride_bloc.dart';
import 'package:buoy/rides/model/ride.dart';
import 'package:buoy/shared/models/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

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
        SliverToBoxAdapter(
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
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Hero(
                            tag: friend.id!,
                            child: CircleAvatar(
                              radius: 30.0,
                              foregroundImage: friend.photoUrl != null
                                  ? CachedNetworkImageProvider(friend.photoUrl!)
                                  : null,
                              child: const Icon(
                                Icons.person_rounded,
                                color: Colors.white,
                                size: 30.0,
                              ),
                            ),
                          ),
                          const Gutter(),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: Row(
                                    // mainAxisAlignment:
                                    //     MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        flex: 2,
                                        child: Text(
                                          friend.firstName ?? 'Unknown',
                                          maxLines: 2,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall,
                                        ),
                                      ),
                                      const GutterSmall(),
                                      if (location.activity != null)
                                        Flexible(
                                          child: SizedBox(
                                              height: 34,
                                              child: ActivityChip(
                                                  activity: location.activity)),
                                        ),
                                      const GutterSmall(),
                                      if (location.batteryLevel != null)
                                        Flexible(
                                          child: SizedBox(
                                              height: 30,
                                              child: BatteryChip(
                                                  batteryLevel:
                                                      location.batteryLevel)),
                                        ),
                                    ],
                                  ),
                                ),
                                const GutterSmall(),
                                Flexible(
                                  child: Row(
                                    children: [
                                      const Icon(Icons.share_arrival_time,
                                          size: 14.0),
                                      const SizedBox(width: 6.0),
                                      Text.rich(
                                        TextSpan(
                                            text: 'Last seen: ',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.bold),
                                            children: [
                                              TextSpan(
                                                text: timeago.format(
                                                    DateTime.parse(
                                                        location.timeStamp)),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    .copyWith(
                                                        fontStyle:
                                                            FontStyle.italic),
                                              ),
                                            ]),
                                      ),
                                    ],
                                  ),
                                ),
                                const GutterSmall(),
                                Flexible(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.location_pin,
                                        color: Theme.of(context).primaryColor,
                                        size: 14.0,
                                      ),
                                      const GutterTiny(),
                                      Flexible(
                                        child: Text(
                                          location.locationString ??
                                              'Unknown Location',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const GutterSmall(),
                                const Gutter(),
                              ],
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                                onPressed: () {
                                  context.read<RideBloc>().add(CreateRide(Ride(
                                        senderIds: [
                                          context
                                              .read<ProfileBloc>()
                                              .state
                                              .user!
                                              .id!
                                        ],
                                        receiverIds: [friend.id!],
                                      )));
                                  Navigator.of(context).pop(true);
                                },
                                style: FilledButton.styleFrom(
                                  // fixedSize: const Size.fromWidth(100),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(24.0)),
                                ),
                                icon: Icon(
                                  PhosphorIcons.motorcycle(
                                      PhosphorIconsStyle.fill),
                                  // color: Colors.white,
                                  size: 20.0,
                                ),
                                label: const Text(
                                  'Ride Request',
                                )),
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
