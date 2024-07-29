import 'package:buoy/friends/bloc/friends_bloc.dart';
import 'package:buoy/friends/view/friend_details_sheet.dart';
import 'package:buoy/locate/bloc/geolocation_bloc.dart';
import 'package:buoy/locate/model/location.dart';
import 'package:buoy/locate/view/widgets/friend_location_card.dart';
import 'package:buoy/profile/repository/bloc/profile_bloc.dart';
import 'package:buoy/rides/bloc/ride_bloc.dart';
import 'package:buoy/rides/bloc/rides_bloc.dart';
import 'package:buoy/rides/model/ride.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:collection/collection.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../activity/bloc/activity_bloc.dart';

class MainMap extends StatelessWidget {
  const MainMap({
    super.key,
    required this.mapController,
  });

  final AnimatedMapController? mapController;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GeolocationBloc, GeolocationState>(
      listener: (context, state) async {
        if (state is GeolocationLoaded || state is GeolocationUpdating) {}
      },
      builder: (context, state) {
        if (state is GeolocationLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is GeolocationLoaded || state is GeolocationUpdating) {
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              FlutterMap(
                mapController: mapController!.mapController,
                options: MapOptions(
                  initialCenter: LatLng(
                      state.bgLocation!.coords.latitude - 0.10,
                      state.bgLocation!.coords.longitude),
                  initialZoom: 10.0,
                  maxZoom: 18.0,
                  minZoom: 2.0,
                  cameraConstraint: CameraConstraint.contain(
                      bounds: LatLngBounds(const LatLng(-90.0, -180.0),
                          const LatLng(90.0, 180.0))),
                  interactionOptions: const InteractionOptions(),
                  // interactiveFlags: InteractiveFlag.pinchZoom |
                  //     InteractiveFlag.drag |
                  //     InteractiveFlag.doubleTapZoom |
                  //     InteractiveFlag.flingAnimation,
                  onTap: (tapPosition, point) {
                    if (context.read<RideBloc>().state is CreatingRide) {
                      context.read<RideBloc>().add(
                            UpdateRideDraft(
                              context.read<RideBloc>().state.ride!.copyWith(
                                meetingPoint: [
                                  point.latitude,
                                  point.longitude,
                                ],
                              ),
                            ),
                          );
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        Theme.of(context).brightness == Brightness.light
                            ? dotenv.get('MAPBOX_API_URL')
                            : dotenv.get(
                                'MAPBOX_API_DARK_URL',
                              ),
                    additionalOptions: {
                      'accessToken': dotenv.get('MAPBOX_MAGNOLIA'),
                      'id': 'mapbox/streets-v11',
                    },
                  ),
                  BlocBuilder<FriendsBloc, FriendsState>(
                    builder: (context, friendsState) {
                      if (friendsState is FriendsLoading) {
                        return const MarkerLayer(
                          markers: [],
                        );
                      }
                      if (friendsState is FriendsLoaded) {
                        return BlocBuilder<ProfileBloc, ProfileState>(
                          builder: (context, profileState) {
                            if (profileState is ProfileLoading) {
                              print('Profile Loading State...');
                              return const MarkerLayer(
                                markers: [],
                              );
                            }
                            if (profileState is ProfileLoaded) {
                              print('Profile: ${profileState.user.name}');
                              return BlocBuilder<FriendsBloc, FriendsState>(
                                builder: (context, friendsState) {
                                  if (friendsState is FriendsLoading) {
                                    print('Friends Loading State...');
                                    return const MarkerLayer(
                                      markers: [],
                                    );
                                  }
                                  if (friendsState is FriendsError) {
                                    return const MarkerLayer(
                                      markers: [],
                                    );
                                  }
                                  if (friendsState is FriendsLoaded) {
                                    if (friendsState.friends.isEmpty ||
                                        friendsState.locations.isEmpty) {
                                      return const MarkerLayer(
                                        markers: [],
                                      );
                                    }
                                    for (int i = 0;
                                        i < friendsState.locations.length;
                                        i++) {
                                      print(
                                          'showing location $i: ${friendsState.locations[i].latitude}');
                                    }

                                    return BlocBuilder<RidesBloc, RidesState>(
                                      builder: (context, ridesState) {
                                        if (ridesState is RidesLoading) {
                                          return const MarkerLayer(
                                            markers: [],
                                          );
                                        }
                                        if (ridesState is RidesError) {
                                          return const MarkerLayer(
                                            markers: [],
                                          );
                                        }

                                        return BlocConsumer<RideBloc,
                                            RideState>(
                                          listener: (context, state) {
                                            if (state is CreatingRide &&
                                                state.ride.meetingPoint ==
                                                    null) {
                                              print('Creating Ride State...');
                                              // Show bottom sheet to create ride
                                              showBottomSheet(
                                                context: context,
                                                // isScrollControlled: true,
                                                builder: (context) {
                                                  return const SelectDestinationSheet();
                                                },
                                              );
                                            }
                                          },
                                          builder: (context, rideState) {
                                            if (rideState is CreatingRide &&
                                                rideState.ride.meetingPoint !=
                                                    null) {
                                              return MarkerLayer(
                                                markers: [
                                                  /// User Location
                                                  /// Destination Location
                                                  Marker(
                                                    point: LatLng(
                                                        rideState.ride
                                                            .meetingPoint![0],
                                                        rideState.ride
                                                            .meetingPoint![1]),
                                                    child: PhosphorIcon(
                                                            PhosphorIcons.mapPin(
                                                                PhosphorIconsStyle
                                                                    .fill))
                                                        .animate(
                                                          onComplete:
                                                              (controller) =>
                                                                  controller.repeat(
                                                                      reverse:
                                                                          true),
                                                        )
                                                        .scale(
                                                            begin: const Offset(
                                                                1.0, 1.0),
                                                            end: const Offset(
                                                                1.6, 1.6),
                                                            duration:
                                                                1.618.seconds),
                                                  ),
                                                  Marker(
                                                    // anchorPos:
                                                    //     AnchorPos.align(AnchorAlign.top),
                                                    width: 32.0,
                                                    height: 32.0,
                                                    point: LatLng(
                                                        state.bgLocation!.coords
                                                            .latitude,
                                                        state.bgLocation!.coords
                                                            .longitude),
                                                    child: Stack(
                                                      clipBehavior: Clip.none,
                                                      alignment:
                                                          Alignment.center,
                                                      children: [
                                                        CircleAvatar(
                                                          radius: 30.0,
                                                          backgroundColor:
                                                              Theme.of(context)
                                                                  .splashColor,
                                                        )
                                                            .animate(
                                                              onComplete:
                                                                  (controller) =>
                                                                      controller
                                                                          .repeat(),
                                                            )
                                                            .fadeIn(
                                                                duration:
                                                                    800.ms)
                                                            .scale(
                                                                duration: 1.618
                                                                    .seconds)
                                                            .fadeOut(
                                                                delay: 800.ms),
                                                        InkWell(
                                                          onTap: () async {
                                                            await mapController?.animateTo(
                                                                dest: LatLng(
                                                                    state
                                                                        .bgLocation!
                                                                        .coords
                                                                        .latitude,
                                                                    state
                                                                        .bgLocation!
                                                                        .coords
                                                                        .longitude));
                                                          },
                                                          child: CircleAvatar(
                                                            backgroundColor:
                                                                Colors.white,
                                                            radius: 18.0,
                                                            child: CircleAvatar(
                                                              radius: 16.0,
                                                              // foregroundImage:
                                                              //     CachedNetworkImageProvider(
                                                              //   profileState.user
                                                              //           .photoUrl ??
                                                              //       '',
                                                              // ),
                                                              child: profileState
                                                                              .user
                                                                              .photoUrl ==
                                                                          null ||
                                                                      profileState
                                                                              .user
                                                                              .photoUrl ==
                                                                          ''
                                                                  // Show first and last initials if no photo
                                                                  ? Text(
                                                                      '${profileState.user.name![0]}${profileState.user.name!.split(' ').last[0]}',
                                                                      style: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .bodyMedium!
                                                                          .copyWith(
                                                                            color:
                                                                                Theme.of(context).scaffoldBackgroundColor,
                                                                            fontWeight:
                                                                                FontWeight.w800,
                                                                          ),
                                                                    )
                                                                  : null,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  if (friendsState
                                                          .friends.isNotEmpty &&
                                                      friendsState
                                                          .locations.isNotEmpty)
                                                    for (Location location
                                                        in friendsState
                                                            .locations)
                                                      Marker(
                                                        width: 100.0,
                                                        height: 100.0,
                                                        point: LatLng(
                                                            double.parse(
                                                                location
                                                                    .latitude),
                                                            double.parse(location
                                                                .longitude)),
                                                        child: Stack(
                                                          alignment:
                                                              Alignment.center,
                                                          children: [
                                                            CircleAvatar(
                                                              radius: 28.0,
                                                              backgroundColor:
                                                                  Theme.of(
                                                                          context)
                                                                      .splashColor,
                                                            )
                                                                .animate(
                                                                  onComplete: (controller) =>
                                                                      controller
                                                                          .repeat(),
                                                                )
                                                                .fadeIn(
                                                                    duration:
                                                                        800.ms)
                                                                .scale(
                                                                    duration: 1.618
                                                                        .seconds)
                                                                .fadeOut(
                                                                    delay:
                                                                        800.ms),
                                                            InkWell(
                                                              onTap: () async {
                                                                showBottomSheet(
                                                                  context:
                                                                      context,
                                                                  //       isScrollControlled: true,
                                                                  builder:
                                                                      (context) {
                                                                    return DraggableScrollableSheet(
                                                                        expand:
                                                                            false,
                                                                        maxChildSize:
                                                                            0.28,
                                                                        initialChildSize:
                                                                            0.28,
                                                                        minChildSize:
                                                                            0.13,
                                                                        builder:
                                                                            (context,
                                                                                controller) {
                                                                          return FriendDetailsSheet(
                                                                              friendId: friendsState.friends[1].id!,
                                                                              location: location,
                                                                              scrollController: controller);
                                                                        });
                                                                  },
                                                                );
                                                                await mapController
                                                                    ?.centerOnPoint(
                                                                  LatLng(
                                                                      double.parse(
                                                                          location
                                                                              .latitude),
                                                                      double.parse(
                                                                          location
                                                                              .longitude)),
                                                                );
                                                                // await mapController
                                                                //     ?.centerOnPoint(
                                                                //         LatLng(
                                                                //           double.parse(
                                                                //               location
                                                                //                   .latitude),
                                                                //           double.parse(
                                                                //               location
                                                                //                   .longitude),
                                                                //         ),
                                                                //         zoom: 14.0,
                                                                //         curve: Curves
                                                                //             .easeOutSine);
                                                              },
                                                              child:
                                                                  CircleAvatar(
                                                                backgroundColor:
                                                                    Colors
                                                                        .white,
                                                                radius: 18.0,
                                                                child:
                                                                    CircleAvatar(
                                                                  radius: 16.0,
                                                                  // foregroundImage:
                                                                  //     CachedNetworkImageProvider(
                                                                  //   friendsState
                                                                  //           .friends
                                                                  //           .firstWhere((friend) =>
                                                                  //               friend.id ==
                                                                  //               location.userId)
                                                                  //           .photoUrl ??
                                                                  //       '',
                                                                  // ),
                                                                  child: friendsState.friends.firstWhere((friend) => friend.id == location.userId).photoUrl ==
                                                                          null
                                                                      ? Text(friendsState
                                                                          .friends
                                                                          .firstWhere((friend) =>
                                                                              friend.id ==
                                                                              location.userId)
                                                                          .name!
                                                                          .toUpperCase())
                                                                      : null,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                ],
                                              );
                                            }
                                            return MarkerLayer(
                                              markers: [
                                                for (Ride ride
                                                    in ridesState.myRides ?? [])
                                                  Marker(
                                                    point: LatLng(
                                                        ride.meetingPoint![0],
                                                        ride.meetingPoint![1]),
                                                    child: InkWell(
                                                      onTap: () async {
                                                        print('Tapped ride');

                                                        showBottomSheet(
                                                          context: context,
                                                          builder: (context) {
                                                            return DraggableScrollableSheet(
                                                                expand: false,
                                                                maxChildSize:
                                                                    0.4,
                                                                initialChildSize:
                                                                    0.33,
                                                                minChildSize:
                                                                    0.13,
                                                                builder: (context,
                                                                    controller) {
                                                                  return RideDetailsSheet(
                                                                      ride:
                                                                          ride,
                                                                      scrollController:
                                                                          controller);
                                                                });
                                                          },
                                                        );

                                                        await mapController?.animateTo(
                                                            dest: LatLng(
                                                                ride.meetingPoint![
                                                                    0],
                                                                ride.meetingPoint![
                                                                    1]));
                                                      },
                                                      child: Stack(
                                                        alignment:
                                                            Alignment.center,
                                                        children: [
                                                          CircleAvatar(
                                                            radius: 200.0,
                                                            backgroundColor: Theme
                                                                    .of(context)
                                                                .colorScheme
                                                                .primaryContainer,
                                                          )
                                                              .animate(
                                                                onComplete:
                                                                    (controller) =>
                                                                        controller
                                                                            .repeat(),
                                                              )
                                                              .fade(
                                                                  begin: 0.0,
                                                                  end: 0.6,
                                                                  duration:
                                                                      800.ms)
                                                              .scale(
                                                                  begin:
                                                                      const Offset(
                                                                          1.0,
                                                                          1.0),
                                                                  end:
                                                                      const Offset(
                                                                          1.6,
                                                                          1.6),
                                                                  duration: 1.618
                                                                      .seconds)
                                                              .fadeOut(
                                                                  delay:
                                                                      800.ms),
                                                          PhosphorIcon(PhosphorIcons
                                                              .mapPinArea(
                                                                  PhosphorIconsStyle
                                                                      .fill)),
                                                        ],
                                                      ),
                                                    ),
                                                  ),

                                                /// User Location
                                                Marker(
                                                  // anchorPos:
                                                  //     AnchorPos.align(AnchorAlign.top),
                                                  width: 32.0,
                                                  height: 32.0,
                                                  point: LatLng(
                                                      state.bgLocation!.coords
                                                          .latitude,
                                                      state.bgLocation!.coords
                                                          .longitude),
                                                  child: Stack(
                                                    clipBehavior: Clip.none,
                                                    alignment: Alignment.center,
                                                    children: [
                                                      CircleAvatar(
                                                        radius: 30.0,
                                                        backgroundColor:
                                                            Theme.of(context)
                                                                .splashColor,
                                                      )
                                                          .animate(
                                                            onComplete:
                                                                (controller) =>
                                                                    controller
                                                                        .repeat(),
                                                          )
                                                          .fadeIn(
                                                              duration: 800.ms)
                                                          .scale(
                                                              duration:
                                                                  1.618.seconds)
                                                          .fadeOut(
                                                              delay: 800.ms),
                                                      InkWell(
                                                        onTap: () async {
                                                          await mapController?.animateTo(
                                                              dest: LatLng(
                                                                  state
                                                                      .bgLocation!
                                                                      .coords
                                                                      .latitude,
                                                                  state
                                                                      .bgLocation!
                                                                      .coords
                                                                      .longitude));
                                                        },
                                                        child: CircleAvatar(
                                                          backgroundColor:
                                                              Colors.white,
                                                          radius: 18.0,
                                                          child: CircleAvatar(
                                                            radius: 16.0,
                                                            // foregroundImage:
                                                            //     CachedNetworkImageProvider(
                                                            //   profileState.user
                                                            //           .photoUrl ??
                                                            //       '',
                                                            // ),
                                                            child: profileState
                                                                            .user
                                                                            .photoUrl ==
                                                                        null ||
                                                                    profileState
                                                                            .user
                                                                            .photoUrl ==
                                                                        ''
                                                                // Show first and last initials if no photo
                                                                ? Text(
                                                                    '${profileState.user.name![0]}${profileState.user.name!.split(' ').last[0]}',
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .bodyMedium!
                                                                        .copyWith(
                                                                          color:
                                                                              Theme.of(context).scaffoldBackgroundColor,
                                                                          fontWeight:
                                                                              FontWeight.w800,
                                                                        ),
                                                                  )
                                                                : null,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                if (friendsState
                                                        .friends.isNotEmpty &&
                                                    friendsState
                                                        .locations.isNotEmpty)
                                                  for (Location location
                                                      in friendsState.locations)
                                                    Marker(
                                                      width: 100.0,
                                                      height: 100.0,
                                                      point: LatLng(
                                                          double.parse(location
                                                              .latitude),
                                                          double.parse(location
                                                              .longitude)),
                                                      child: Stack(
                                                        alignment:
                                                            Alignment.center,
                                                        children: [
                                                          CircleAvatar(
                                                            radius: 28.0,
                                                            backgroundColor:
                                                                Theme.of(
                                                                        context)
                                                                    .splashColor,
                                                          )
                                                              .animate(
                                                                onComplete:
                                                                    (controller) =>
                                                                        controller
                                                                            .repeat(),
                                                              )
                                                              .fadeIn(
                                                                  duration:
                                                                      800.ms)
                                                              .scale(
                                                                  duration: 1.618
                                                                      .seconds)
                                                              .fadeOut(
                                                                  delay:
                                                                      800.ms),
                                                          InkWell(
                                                            onTap: () async {
                                                              showBottomSheet(
                                                                context:
                                                                    context,
                                                                //       isScrollControlled: true,
                                                                builder:
                                                                    (context) {
                                                                  return DraggableScrollableSheet(
                                                                      expand:
                                                                          false,
                                                                      maxChildSize:
                                                                          0.28,
                                                                      initialChildSize:
                                                                          0.28,
                                                                      minChildSize:
                                                                          0.13,
                                                                      builder:
                                                                          (context,
                                                                              controller) {
                                                                        return FriendDetailsSheet(
                                                                            friendId:
                                                                                friendsState.friends[1].id!,
                                                                            location: location,
                                                                            scrollController: controller);
                                                                      });
                                                                },
                                                              );
                                                              await mapController
                                                                  ?.centerOnPoint(
                                                                LatLng(
                                                                    double.parse(
                                                                        location
                                                                            .latitude),
                                                                    double.parse(
                                                                        location
                                                                            .longitude)),
                                                              );
                                                              // await mapController
                                                              //     ?.centerOnPoint(
                                                              //         LatLng(
                                                              //           double.parse(
                                                              //               location
                                                              //                   .latitude),
                                                              //           double.parse(
                                                              //               location
                                                              //                   .longitude),
                                                              //         ),
                                                              //         zoom: 14.0,
                                                              //         curve: Curves
                                                              //             .easeOutSine);
                                                            },
                                                            child: CircleAvatar(
                                                              backgroundColor:
                                                                  Colors.white,
                                                              radius: 18.0,
                                                              child:
                                                                  CircleAvatar(
                                                                radius: 16.0,
                                                                // foregroundImage:
                                                                //     CachedNetworkImageProvider(
                                                                //   friendsState.friends
                                                                //           .firstWhere((friend) =>
                                                                //               friend
                                                                //                   .id ==
                                                                //               location
                                                                //                   .userId)
                                                                //           .photoUrl ??
                                                                //       '',
                                                                // ),
                                                                child: friendsState
                                                                            .friends
                                                                            .firstWhere((friend) =>
                                                                                friend.id ==
                                                                                location
                                                                                    .userId)
                                                                            .photoUrl ==
                                                                        null
                                                                    ? Text(friendsState
                                                                        .friends
                                                                        .firstWhere((friend) =>
                                                                            friend.id ==
                                                                            location.userId)
                                                                        .name!
                                                                        .toUpperCase())
                                                                    : null,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    );
                                  }
                                  return const Center(
                                      child: Text('Something went wrong...'));
                                },
                              );
                            } else {
                              return const MarkerLayer(
                                markers: [],
                              );
                            }
                          },
                        );
                      }
                      print('Location Data: ${friendsState.locations}');
                      // Find matching ids in friend objects and location stream & print them
                      for (Location location in friendsState.locations) {
                        if (location.userId == friendsState.friends[1].id) {
                          print('Matching id: ${location.userId}');
                          print(
                              '${friendsState.friends[1].name} photo: ${friendsState.friends[1].photoUrl}');
                        }
                      }
                      // print(
                      //     'Location: ${location.coords.latitude}, ${location.coords.longitude}');
                      return const MarkerLayer(
                        markers: [],
                      );
                    },
                  )
                ],
              ),
              LayoutBuilder(builder: (context, constraints) {
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: constraints.maxHeight * 0.5,
                    minHeight: 0,
                    minWidth: constraints.maxWidth,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
                    child: CustomScrollView(
                      clipBehavior: Clip.antiAlias,
                      reverse: true,
                      shrinkWrap: true,
                      slivers: [
                        SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              BlocBuilder<RidesBloc, RidesState>(
                                builder: (context, state) {
                                  if (state is RidesLoading) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  if (state is RidesError) {
                                    return const Center(
                                      child: Text('Error'),
                                    );
                                  } else if (state is RidesLoaded) {
                                    if (state.myRides.isEmpty) {
                                      return const Center(
                                        child: Text('No Friends Online'),
                                      );
                                    }
                                    if (state.myRides.isEmpty) {
                                      return const Chip(
                                          label: Text('No Friends Added'));
                                    }
                                    return Column(
                                      children: [
                                        ...state.myRides.map((ride) {
                                          return RideDetailsCard(
                                              ride: ride,
                                              mapController: mapController!);
                                        }),
                                      ],
                                    );
                                  }
                                  return const Center(
                                    child: Text('Something Went Wrong...'),
                                  );
                                },
                              ),
                            ]
                                .animate(interval: 200.ms)
                                .fadeIn(
                                  duration: 400.ms,
                                  curve: Curves.easeOutSine,
                                )
                                .slideY(
                                  duration: 800.ms,
                                  begin: 18.0,
                                  end: 0.0,
                                  curve: Curves.easeOutQuint,
                                ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }),
              // LayoutBuilder(builder: (context, constraints) {
              //   return ConstrainedBox(
              //     constraints: BoxConstraints(
              //       maxHeight: constraints.maxHeight * 0.5,
              //       minHeight: 0,
              //       minWidth: constraints.maxWidth,
              //     ),
              //     child: Padding(
              //       padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
              //       child: CustomScrollView(
              //         clipBehavior: Clip.antiAlias,
              //         reverse: true,
              //         shrinkWrap: true,
              //         slivers: [
              //           SliverList(
              //             delegate: SliverChildListDelegate(
              //               [
              //                 BlocBuilder<FriendsBloc, FriendsState>(
              //                   builder: (context, state) {
              //                     if (state is FriendsLoading) {
              //                       return const Center(
              //                         child: CircularProgressIndicator(),
              //                       );
              //                     }
              //                     if (state is FriendsError) {
              //                       return const Center(
              //                         child: Text('Error'),
              //                       );
              //                     } else if (state is FriendsLoaded) {
              //                       if (state.locations.isEmpty) {
              //                         return const Center(
              //                           child: Text('No Friends Online'),
              //                         );
              //                       }
              //                       if (state.friends.isEmpty) {
              //                         return const Chip(
              //                             label: Text('No Friends Added'));
              //                       }
              //                       return Column(
              //                         children: [
              //                           ...state.friends.map((friend) {
              //                             Location? location = state.locations
              //                                 .singleWhereOrNull((element) =>
              //                                     element.userId == friend.id);

              //                             print(
              //                                 'location matched: ${location?.toJson().toString()}');
              //                             if (location == null) {
              //                               return const SizedBox();
              //                             }
              //                             return FriendLocationCard(
              //                               friend: friend,
              //                               name: friend.name!,
              //                               activity: location.activity,
              //                               batteryLevel: location.batteryLevel,
              //                               location: location,
              //                               locationString:
              //                                   '${location.city}, ${location.state}' ??
              //                                       'Unknown Location',
              //                               isOnline: true,
              //                               profilePhotoUrl: friend.photoUrl,
              //                               mapController: mapController!,
              //                             );
              //                           }),
              //                         ],
              //                       );
              //                     }
              //                     return const Center(
              //                       child: Text('Something Went Wrong...'),
              //                     );
              //                   },
              //                 ),
              //               ]
              //                   .animate(interval: 200.ms)
              //                   .fadeIn(
              //                     duration: 400.ms,
              //                     curve: Curves.easeOutSine,
              //                   )
              //                   .slideY(
              //                     duration: 800.ms,
              //                     begin: 18.0,
              //                     end: 0.0,
              //                     curve: Curves.easeOutQuint,
              //                   ),
              //             ),
              //           )
              //         ],
              //       ),
              //     ),
              //   );
              // }),
              Positioned(
                top: 0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 60,
                    //  width: 200,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 16.0),
                        child: Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: CircleAvatar(
                                radius: 20.0,
                                // foregroundImage: CachedNetworkImageProvider(
                                //     'https://scontent-ord5-2.xx.fbcdn.net/v/t1.6435-9/193213907_4419559838077181_2959395753433319266_n.jpg?_nc_cat=107&ccb=1-7&_nc_sid=09cbfe&_nc_ohc=wOk65qwQtM4AX-u5oOI&_nc_ht=scontent-ord5-2.xx&oh=00_AfBfuDGJuqIyOTavFvz2JUa7KosApfemDsxTMOf86LbnUg&oe=647BE024'),
                                child: Icon(
                                  Icons.person_pin_circle_rounded,
                                  color: Colors.white,
                                  size: 30.0,
                                  fill: 1.0,
                                ),
                              ),
                            ),
                            BlocBuilder<GeolocationBloc, GeolocationState>(
                              builder: (context, geoLocationState) {
                                if (geoLocationState is GeolocationLoading) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                if (geoLocationState is GeolocationError) {
                                  return const Center(
                                    child: Text('Error Getting Location'),
                                  );
                                }
                                if (geoLocationState is GeolocationLoaded) {
                                  return BlocBuilder<ActivityBloc,
                                      ActivityState>(
                                    builder: (context, state) {
                                      if (state is ActivityLoading) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 0.0, vertical: 6.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (geoLocationState
                                                      .location.city !=
                                                  null)
                                                Text(
                                                  geoLocationState
                                                      .location.city!,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall,
                                                ),
                                              Wrap(
                                                spacing: 2.0,
                                                crossAxisAlignment:
                                                    WrapCrossAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.warning,
                                                    size: 14.0,
                                                  ),
                                                  Text(
                                                    'Error Detecting Motion',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall,
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        );
                                      }
                                      if (state is ActivityError) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 0.0, vertical: 6.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (geoLocationState
                                                      .location.city !=
                                                  null)
                                                Text(
                                                  geoLocationState
                                                      .location.city!,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall,
                                                ),
                                              Wrap(
                                                spacing: 2.0,
                                                crossAxisAlignment:
                                                    WrapCrossAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons
                                                        .directions_walk_rounded,
                                                    size: 14.0,
                                                  ),
                                                  Text(
                                                    'Walking',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall,
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        );
                                      }
                                      if (state is ActivityLoaded) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 0.0, vertical: 10.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (geoLocationState
                                                          .location.city !=
                                                      null &&
                                                  geoLocationState
                                                          .location.state !=
                                                      null)
                                                Wrap(
                                                  spacing: 6.0,
                                                  crossAxisAlignment:
                                                      WrapCrossAlignment.center,
                                                  children: [
                                                    const Icon(
                                                      Icons.location_on,
                                                      size: 12.0,
                                                    ),
                                                    Text(
                                                      '${geoLocationState.location.city}, ${geoLocationState.location.state}',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall,
                                                    ),
                                                  ],
                                                ),
                                              Wrap(
                                                spacing: 6.0,
                                                crossAxisAlignment:
                                                    WrapCrossAlignment.center,
                                                children: [
                                                  Icon(
                                                    state.activity == 'still'
                                                        ? Icons.pause_rounded
                                                        : state.activity ==
                                                                    'on_foot' ||
                                                                state.activity ==
                                                                    'walking'
                                                            ? Icons
                                                                .directions_walk_rounded
                                                            : state.activity ==
                                                                    'running'
                                                                ? Icons
                                                                    .directions_run_rounded
                                                                : state.activity ==
                                                                        'in_vehicle'
                                                                    ? Icons
                                                                        .drive_eta_rounded
                                                                    : state.activity ==
                                                                            'on_bicycle'
                                                                        ? Icons
                                                                            .directions_bike_rounded
                                                                        : Icons
                                                                            .error_rounded,
                                                    size: 12.0,
                                                  ),
                                                  Text(
                                                    state.activity == 'still'
                                                        ? 'Stationary'
                                                        : state.activity ==
                                                                    'on_foot' ||
                                                                state.activity ==
                                                                    'walking'
                                                            ? 'Walking'
                                                            : state.activity ==
                                                                    'running'
                                                                ? 'Running'
                                                                : state.activity ==
                                                                        'in_vehicle'
                                                                    ? 'Driving'
                                                                    : state.activity ==
                                                                            'on_bicycle'
                                                                        ? 'Cycling'
                                                                        : 'Unknown',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall,
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        );
                                      } else {
                                        return const Center(
                                          child:
                                              Text('Something Went Wrong...'),
                                        );
                                      }
                                    },
                                  );
                                } else {
                                  return const Center(
                                    child: Text('Something Went Wrong...'),
                                  );
                                }
                              },
                            )
                          ],
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(
                          duration: 400.ms,
                          curve: Curves.easeOutSine,
                        )
                        .slideY(
                          duration: 600.ms,
                          begin: -.0,
                          end: 0.0,
                          curve: Curves.easeOutSine,
                        ),
                  ),
                ),
              ),
            ],
          );
        }
        if (state is GeolocationError) {
          return Center(
            child: Text(state.message),
          );
        } else {
          return const Center(child: Text('Something Went Wrong...'));
        }
      },
    );
  }
}

class SelectDestinationSheet extends StatelessWidget {
  const SelectDestinationSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RideBloc, RideState>(
      builder: (context, state) {
        return DraggableScrollableSheet(
          expand: false,
          maxChildSize: 0.58,
          initialChildSize: 0.33,
          minChildSize: 0.13,
          builder: (context, controller) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24.0),
                  topRight: Radius.circular(24.0),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 8.0,
                  ),
                  Container(
                    height: 4.0,
                    width: 48.0,
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Select Meeting Point',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Select a meeting point on the map',
                                style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: state.ride!.meetingPoint != null
                                      ? BoxDecoration(
                                          border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            width: 2.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                        )
                                      : BoxDecoration(
                                          border: Border.all(
                                            color: Colors.red,
                                            width: 2.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                        ),
                                  child: ListTile(
                                    style: ListTileStyle.list,
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                        color: Colors.red,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(24.0),
                                    ),
                                    title: state.ride!.meetingPoint != null
                                        ? Text(
                                            'Destination Set: ${state.ride!.meetingPointAddress ?? state.ride!.meetingPointName}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          )
                                        : const Text('Location Not Set'),
                                    leading: state.ride!.meetingPoint != null
                                        ? const Icon(Icons.location_on_rounded)
                                        : const Icon(
                                            Icons.location_off_rounded),
                                    onTap: () {
                                      // Show search bar
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  state.ride!.meetingPoint != null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              context.pop();
                              showBottomSheet(
                                  context: context,
                                  builder: (context) =>
                                      const ConfirmRideRequestSheet());
                            },
                            icon: const Icon(Icons.check_rounded),
                            label: const Text('Set Meeting Point'),
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class RideDetailsCard extends StatelessWidget {
  final Ride ride;
  final AnimatedMapController? mapController;
  const RideDetailsCard(
      {required this.ride, required this.mapController, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () async {
          showBottomSheet(
            context: context,
            builder: (context) {
              return DraggableScrollableSheet(
                expand: false,
                maxChildSize: 0.58,
                initialChildSize: 0.33,
                minChildSize: 0.13,
                builder: (context, controller) {
                  return RideDetailsSheet(
                    ride: ride,
                    scrollController: controller,
                  );
                },
              );
            },
          );
          await mapController?.animateTo(
            dest: LatLng(ride.meetingPoint![0], ride.meetingPoint![1]),
            zoom: 12,
            rotation: 0,
          );
        },
        child: Column(
          children: [
            ListTile(
              leading: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 18,
                    child: PhosphorIcon(PhosphorIcons.motorcycle(
                      PhosphorIconsStyle.fill,
                    )),
                  ),
                  LoadingAnimationWidget.threeArchedCircle(
                      color: Theme.of(context).colorScheme.primary, size: 36)
                ],
              ),
              title: Text(
                'Awaiting Rider Confirmation...',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              subtitle: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                      child: Text.rich(
                    TextSpan(
                      text: 'Meet at: ',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      children: [
                        TextSpan(
                          text: ride.meetingPointAddress,
                          style: Theme.of(context).textTheme.bodySmall!,
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConfirmRideRequestSheet extends StatelessWidget {
  const ConfirmRideRequestSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: 0.58,
      initialChildSize: 0.35,
      minChildSize: 0.13,
      builder: (context, controller) {
        return BlocConsumer<RideBloc, RideState>(
          listener: (context, state) {
            if (state is RideError) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Error sending ride request!'),
                  duration: Duration(seconds: 3),
                ),
              );
            }
            if (state is RideRequestSent) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ride Request Sent!'),
                  duration: Duration(seconds: 3),
                ),
              );
              context.pop();
            }
          },
          builder: (context, state) {
            if (state is RideLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is RideError) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Center(
                    child: Text('Error sending ride request!'),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<RideBloc>().add(SendRideRequest(
                          context.read<RideBloc>().state.ride!));
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry'),
                  ),
                ],
              );
            }
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24.0),
                  topRight: Radius.circular(24.0),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 8.0,
                  ),
                  Container(
                    height: 4.0,
                    width: 48.0,
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Confirm Details',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Send a ride request to this rider?',
                                style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  child: ListTile(
                                    style: ListTileStyle.list,
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                        color: Colors.red,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(24.0),
                                    ),
                                    title: Text(
                                        'Meet at: ${context.read<RideBloc>().state.ride!.meetingPointAddress}'),
                                    leading:
                                        const Icon(Icons.location_on_rounded),
                                    onTap: () {
                                      // Show search bar
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.read<RideBloc>().add(SendRideRequest(
                            context.read<RideBloc>().state.ride!));
                      },
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Send Ride Request'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class RideDetailsSheet extends StatelessWidget {
  const RideDetailsSheet({
    super.key,
    required this.ride,
    required this.scrollController,
  });

  final Ride ride;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(
            height: 8.0,
          ),
          Container(
            height: 4.0,
            width: 48.0,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
          const SizedBox(
            height: 8.0,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Ride Details',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            PhosphorIcon(
                              PhosphorIcons.mapPinArea(
                                PhosphorIconsStyle.fill,
                              ),
                              size: 20,
                            ),
                            const SizedBox(width: 8.0),
                            Flexible(
                                child: Text.rich(
                              TextSpan(
                                text: 'Meet at: ',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                children: [
                                  TextSpan(
                                    text: ride.meetingPointAddress,
                                    style:
                                        Theme.of(context).textTheme.bodySmall!,
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Card(
                    child: ListTile(
                      leading: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 18,
                            child: PhosphorIcon(PhosphorIcons.motorcycle(
                              PhosphorIconsStyle.fill,
                            )),
                          ),
                          LoadingAnimationWidget.threeArchedCircle(
                              color: Theme.of(context).colorScheme.primary,
                              size: 36)
                        ],
                      ),
                      title: ride.status == RideStatus.pending
                          ? const Text('Waiting For Rider Response...')
                          : ride.status == RideStatus.accepted
                              ? const Text('Ride Request Accepted')
                              : ride.status == RideStatus.rejected
                                  ? const Text('Ride Request Rejected')
                                  : ride.status == RideStatus.completed
                                      ? const Text('Ride Request Completed')
                                      : ride.status == RideStatus.canceled
                                          ? const Text('Ride Request Canceled')
                                          : ride.status ==
                                                  RideStatus
                                                      .rejectedWithResponse
                                              ? const Text(
                                                  'Ride Changes Requested')
                                              : const Text(
                                                  'Ride Request Unknown'),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextButton.icon(
              // style: OutlinedButton.styleFrom(
              //     side: const BorderSide(
              //   color: Colors.red,
              //   width: 2.0,
              // )),
              onPressed: () {
                context.pop();
              },
              icon: PhosphorIcon(
                PhosphorIcons.prohibit(),
                size: 20,
              ),
              label: const Text('Cancel Ride Request'),
            ),
          ),
        ],
      ),
    );
  }
}
