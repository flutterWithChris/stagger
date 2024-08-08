import 'package:avatar_glow/avatar_glow.dart';
import 'package:buoy/friends/bloc/friends_bloc.dart';
import 'package:buoy/friends/view/friend_details_sheet.dart';
import 'package:buoy/locate/bloc/geolocation_bloc.dart';
import 'package:buoy/locate/model/location.dart';
import 'package:buoy/locate/view/sheets/ride_details_sheet.dart';
import 'package:buoy/profile/repository/bloc/profile_bloc.dart';
import 'package:buoy/riders/bloc/riders_bloc.dart';
import 'package:buoy/riders/model/rider.dart';
import 'package:buoy/riders/view/sheets/rider_details_sheet.dart';
import 'package:buoy/rides/bloc/ride_bloc.dart';
import 'package:buoy/rides/bloc/rides_bloc.dart';
import 'package:buoy/rides/model/ride.dart';
import 'package:buoy/rides/model/ride_participant.dart';
import 'package:buoy/rides/ride_privacy_sheet.dart';
import 'package:buoy/shared/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

import '../../../activity/bloc/activity_bloc.dart';
import 'dart:math' as math;

class MainMap extends StatefulWidget {
  const MainMap({
    super.key,
    required this.mapController,
  });

  final AnimatedMapController? mapController;

  @override
  State<MainMap> createState() => _MainMapState();
}

class _MainMapState extends State<MainMap> {
  Rider? selectedRider;
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
          return SafeArea(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                FlutterMap(
                  mapController: widget.mapController!.mapController,
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
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.pinchZoom |
                          InteractiveFlag.drag |
                          InteractiveFlag.doubleTapZoom |
                          InteractiveFlag.flingAnimation,
                    ),
                    // interactiveFlags: InteractiveFlag.pinchZoom |
                    //     InteractiveFlag.drag |
                    //     InteractiveFlag.doubleTapZoom |
                    //     InteractiveFlag.flingAnimation,
                    onMapReady: () {
                      context.read<RidersBloc>().add(LoadRiders(widget
                          .mapController!.mapController.camera.visibleBounds));
                    },
                    onMapEvent: (p0) {
                      if (p0 is MapEventMove &&
                          p0.source != MapEventSource.mapController) {
                        EasyDebounce.debounce(
                            'rider-fetch-debounce', const Duration(seconds: 1),
                            () {
                          print('Fetching riders... ${DateTime.now()}');
                          context.read<RidersBloc>().add(LoadRiders(widget
                              .mapController!
                              .mapController
                              .camera
                              .visibleBounds));
                        });
                      }
                      // context.read<RidersBloc>().add(LoadRiders(
                      //     mapController!.mapController.camera.visibleBounds));
                    },
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
                                                // Show public or private selection
                                                showBottomSheet(
                                                    context: context,
                                                    builder: (context) =>
                                                        const RidePrivacySheet());
                                                // Show bottom sheet to create ride
                                                // showBottomSheet(
                                                //   context: context,
                                                //   // isScrollControlled: true,
                                                //   builder: (context) {
                                                //     return const SelectDestinationSheet();
                                                //   },
                                                // );
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
                                                              begin:
                                                                  const Offset(
                                                                      1.0, 1.0),
                                                              end: const Offset(
                                                                  1.6, 1.6),
                                                              duration: 1.618
                                                                  .seconds),
                                                    ),
                                                    Marker(
                                                      // anchorPos:
                                                      //     AnchorPos.align(AnchorAlign.top),
                                                      width: 32.0,
                                                      height: 32.0,
                                                      point: LatLng(
                                                          state.bgLocation!
                                                              .coords.latitude,
                                                          state
                                                              .bgLocation!
                                                              .coords
                                                              .longitude),
                                                      child: Stack(
                                                        clipBehavior: Clip.none,
                                                        alignment:
                                                            Alignment.center,
                                                        children: [
                                                          CircleAvatar(
                                                            radius: 30.0,
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
                                                              await widget.mapController?.animateTo(
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
                                                            child: PhosphorIcon(
                                                                PhosphorIcons
                                                                    .motorcycle(
                                                                        PhosphorIconsStyle
                                                                            .fill)),
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                    if (friendsState.friends
                                                            .isNotEmpty &&
                                                        friendsState.locations
                                                            .isNotEmpty)
                                                      for (Location location
                                                          in friendsState
                                                              .locations)
                                                        Marker(
                                                          width: 100.0,
                                                          height: 100.0,
                                                          point: LatLng(
                                                              location
                                                                  .latitude!,
                                                              location
                                                                  .longitude!),
                                                          child: Stack(
                                                            alignment: Alignment
                                                                .center,
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
                                                                            controller.repeat(),
                                                                  )
                                                                  .fadeIn(
                                                                      duration:
                                                                          800
                                                                              .ms)
                                                                  .scale(
                                                                      duration:
                                                                          1.618
                                                                              .seconds)
                                                                  .fadeOut(
                                                                      delay: 800
                                                                          .ms),
                                                              InkWell(
                                                                onTap:
                                                                    () async {
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
                                                                              (context, controller) {
                                                                            return FriendDetailsSheet(
                                                                                friendId: friendsState.friends[1].id!,
                                                                                location: location,
                                                                                scrollController: controller);
                                                                          });
                                                                    },
                                                                  );
                                                                  await widget
                                                                      .mapController
                                                                      ?.centerOnPoint(
                                                                    LatLng(
                                                                        location
                                                                            .latitude!,
                                                                        location
                                                                            .longitude!),
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
                                                                    radius:
                                                                        16.0,
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
                                              return BlocBuilder<RidersBloc,
                                                  RidersState>(
                                                builder:
                                                    (context, ridersState) {
                                                  if (ridersState
                                                      is RidersLoading) {
                                                    return const MarkerLayer(
                                                      markers: [],
                                                    );
                                                  }
                                                  if (ridersState
                                                      is RidersLoaded) {
                                                    return MarkerLayer(
                                                      markers: [
                                                        for (Rider rider
                                                            in ridersState
                                                                .riders)
                                                          Marker(
                                                            point: LatLng(
                                                                rider
                                                                    .currentLocation!
                                                                    .latitude!,
                                                                rider
                                                                    .currentLocation!
                                                                    .longitude!),
                                                            child:
                                                                AnimatedSwitcher(
                                                              duration: 800.ms,
                                                              child:
                                                                  selectedRider ==
                                                                          rider
                                                                      ? InkWell(
                                                                          onTap:
                                                                              () async {
                                                                            showBottomSheet(
                                                                                context: context,
                                                                                builder: (context) {
                                                                                  return RiderDetailsSheet(
                                                                                    rider: rider,
                                                                                  );
                                                                                }).closed.then((value) {
                                                                              setState(() {
                                                                                selectedRider = null;
                                                                                widget.mapController?.animateTo(
                                                                                  dest: LatLng(rider.currentLocation!.latitude!, rider.currentLocation!.longitude!),
                                                                                );
                                                                              });
                                                                            });
                                                                            print('Animating to: ${rider.currentLocation!.latitude}, ${rider.currentLocation!.longitude}');
                                                                            await widget.mapController?.animateTo(
                                                                                dest: LatLng(rider.currentLocation!.latitude!, rider.currentLocation!.longitude!),
                                                                                offset: const Offset(0, -220.0));

                                                                            setState(() {
                                                                              selectedRider = rider;
                                                                            });
                                                                          },
                                                                          child:
                                                                              Stack(
                                                                            alignment:
                                                                                Alignment.center,
                                                                            children: [
                                                                              AvatarGlow(
                                                                                glowColor: Theme.of(context).colorScheme.primary,
                                                                                glowRadiusFactor: 2.7,
                                                                                child: const SizedBox(
                                                                                  height: 6,
                                                                                  width: 6,
                                                                                ),
                                                                              ),
                                                                              PhosphorIcon(
                                                                                PhosphorIcons.motorcycle(
                                                                                  PhosphorIconsStyle.fill,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        )
                                                                      : InkWell(
                                                                          onTap:
                                                                              () async {
                                                                            showBottomSheet(
                                                                                context: context,
                                                                                builder: (context) {
                                                                                  return RiderDetailsSheet(
                                                                                    rider: rider,
                                                                                  );
                                                                                }).closed.then((value) {
                                                                              setState(() {
                                                                                selectedRider = null;
                                                                                widget.mapController?.animateTo(
                                                                                  dest: LatLng(rider.currentLocation!.latitude!, rider.currentLocation!.longitude!),
                                                                                );
                                                                              });
                                                                            });
                                                                            print('Animating to: ${rider.currentLocation!.latitude}, ${rider.currentLocation!.longitude}');
                                                                            await widget.mapController?.animateTo(
                                                                                dest: LatLng(rider.currentLocation!.latitude!, rider.currentLocation!.longitude!),
                                                                                offset: const Offset(0, -220.0));
                                                                            setState(() {
                                                                              selectedRider = rider;
                                                                            });
                                                                          },
                                                                          child:
                                                                              PhosphorIcon(
                                                                            PhosphorIcons.motorcycle(
                                                                              PhosphorIconsStyle.fill,
                                                                            ),
                                                                          ),
                                                                        ),
                                                            ),
                                                          ),
                                                        for (Ride ride in ridesState
                                                                .myRides
                                                                ?.where((ride) =>
                                                                    ride.meetingPoint !=
                                                                    null) ??
                                                            [])
                                                          Marker(
                                                            height: 36.0,
                                                            width: 36.0,
                                                            point: LatLng(
                                                                ride.meetingPoint![
                                                                    0],
                                                                ride.meetingPoint![
                                                                    1]),
                                                            child: InkWell(
                                                              onTap: () async {
                                                                print(
                                                                    'Tapped ride');

                                                                showBottomSheet(
                                                                  // barrierColor:
                                                                  //     Colors
                                                                  //         .black26,
                                                                  // isScrollControlled:
                                                                  //     true,
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) {
                                                                    return RideDetailsSheet(
                                                                      rideId: ride
                                                                          .id!,
                                                                    );
                                                                  },
                                                                );

                                                                await widget
                                                                    .mapController
                                                                    ?.animateTo(
                                                                        dest: LatLng(
                                                                            ride.meetingPoint![0],
                                                                            ride.meetingPoint![1]));
                                                              },
                                                              child: Stack(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                children: [
                                                                  CircleAvatar(
                                                                    radius:
                                                                        200.0,
                                                                    backgroundColor: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .primaryContainer,
                                                                  )
                                                                      .animate(
                                                                        onComplete:
                                                                            (controller) =>
                                                                                controller.repeat(),
                                                                      )
                                                                      .fade(
                                                                          begin:
                                                                              0.0,
                                                                          end:
                                                                              0.6,
                                                                          duration: 800
                                                                              .ms)
                                                                      .scale(
                                                                          begin: const Offset(
                                                                              1.0,
                                                                              1.0),
                                                                          end: const Offset(
                                                                              1.6,
                                                                              1.6),
                                                                          duration: 1.618
                                                                              .seconds)
                                                                      .fadeOut(
                                                                          delay:
                                                                              800.ms),
                                                                  CircleAvatar(
                                                                    radius: 30,
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          2.0),
                                                                      child:
                                                                          PhosphorIcon(
                                                                        switch (
                                                                            ride.status) {
                                                                          RideStatus.pending =>
                                                                            PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
                                                                          RideStatus.accepted =>
                                                                            PhosphorIcons.mapPinArea(PhosphorIconsStyle.fill),
                                                                          RideStatus.rejected =>
                                                                            PhosphorIcons.prohibit(PhosphorIconsStyle.fill),
                                                                          RideStatus.rejectedWithResponse =>
                                                                            PhosphorIcons.question(PhosphorIconsStyle.fill),
                                                                          RideStatus.canceled =>
                                                                            PhosphorIcons.prohibit(PhosphorIconsStyle.fill),
                                                                          RideStatus.completed =>
                                                                            PhosphorIcons.flagCheckered(PhosphorIconsStyle.fill),
                                                                          RideStatus.inProgress =>
                                                                            PhosphorIcons.mapPinArea(PhosphorIconsStyle.fill),
                                                                          null =>
                                                                            PhosphorIcons.mapPinArea(PhosphorIconsStyle.fill),
                                                                        },
                                                                        size:
                                                                            20,
                                                                      ),
                                                                    ),
                                                                  )
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
                                                              state
                                                                  .bgLocation!
                                                                  .coords
                                                                  .latitude,
                                                              state
                                                                  .bgLocation!
                                                                  .coords
                                                                  .longitude),
                                                          child: Stack(
                                                            clipBehavior:
                                                                Clip.none,
                                                            alignment: Alignment
                                                                .center,
                                                            children: [
                                                              InkWell(
                                                                onTap:
                                                                    () async {
                                                                  await widget.mapController?.animateTo(
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
                                                                child: Transform
                                                                    .flip(
                                                                  child: Transform
                                                                      .rotate(
                                                                    angle: 0,
                                                                    // state.location?.heading !=
                                                                    //         null
                                                                    //     ? (state.location!.heading! * math.pi / 180) -
                                                                    //         90
                                                                    //     : 0.0,
                                                                    child:
                                                                        PhosphorIcon(
                                                                      PhosphorIcons
                                                                          .motorcycle(
                                                                        PhosphorIconsStyle
                                                                            .fill,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  } else {
                                                    return const MarkerLayer(
                                                      markers: [],
                                                    );
                                                  }
                                                },
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
                                    }
                                    if (state is RidesInitial) {
                                      return const SizedBox();
                                    }
                                    if (state is RidesLoaded) {
                                      if (state.myRides.isEmpty &&
                                          state.receivedRides.isEmpty) {
                                        return const SizedBox();
                                      }
                                      print('My Rides: ${state.myRides}');
                                      print(
                                          'Received Rides: ${state.receivedRides}');
                                      return Column(
                                        children: [
                                          ...state.myRides.map((ride) {
                                            return RideDetailsCard(
                                              ride: ride,
                                              mapController:
                                                  widget.mapController!,
                                            );
                                          }),
                                          ...state.receivedRides.map((ride) {
                                            return RideRequestCard(
                                                ride: ride,
                                                mapController:
                                                    widget.mapController!);
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
              ],
            ),
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
  // final SheetController sheetController;
  const RideDetailsCard(
      {required this.ride,
      required this.mapController,
      // required this.sheetController,
      super.key});

  @override
  Widget build(BuildContext context) {
    String titleText = switch (ride.status) {
      RideStatus.pending => 'Awaiting Rider Confirmation...',
      RideStatus.accepted => 'Ride Accepted',
      RideStatus.inProgress => 'Ride In Progress',
      RideStatus.rejected => 'Ride Rejected',
      RideStatus.rejectedWithResponse => 'Ride Rejected',
      RideStatus.completed => 'Ride Completed',
      RideStatus.canceled => 'Ride Cancelled',
      null => 'Unknown Status',
    };
    Widget iconWidget = switch (ride.status) {
      RideStatus.pending => LoadingAnimationWidget.prograssiveDots(
          color: Theme.of(context).colorScheme.primary, size: 36),
      RideStatus.accepted => PhosphorIcon(
          PhosphorIcons.checkCircle(
            PhosphorIconsStyle.fill,
          ),
          color: Colors.green[400],
        ),
      RideStatus.inProgress => PhosphorIcon(PhosphorIcons.motorcycle(
          PhosphorIconsStyle.fill,
        )),
      RideStatus.rejected => PhosphorIcon(PhosphorIcons.motorcycle(
          PhosphorIconsStyle.fill,
        )),
      RideStatus.rejectedWithResponse => PhosphorIcon(PhosphorIcons.motorcycle(
          PhosphorIconsStyle.fill,
        )),
      RideStatus.completed => PhosphorIcon(PhosphorIcons.motorcycle(
          PhosphorIconsStyle.fill,
        )),
      RideStatus.canceled => PhosphorIcon(PhosphorIcons.motorcycle(
          PhosphorIconsStyle.fill,
        )),
      null => PhosphorIcon(PhosphorIcons.motorcycle(
          PhosphorIconsStyle.fill,
        )),
    };
    return Card(
      child: InkWell(
        onTap: () async {
          context.read<RideBloc>().add(SelectRide(ride));
          if (ride.meetingPoint != null) {
            print('Animating to ride meeting point...');

            showBottomSheet(
                context: context,
                builder: (context) {
                  return RideDetailsSheet(
                    rideId: ride.id!,
                  );
                }).closed.then(
              (value) async {
                print('Sheet closed');
                await mapController?.animateTo(
                  dest: LatLng(ride.meetingPoint![0], ride.meetingPoint![1]),
                  // zoom: 12,
                  curve: Curves.easeOutSine,
                  rotation: 0,
                );
                return value;
              },
            );

            await mapController?.animateTo(
              dest: LatLng(ride.meetingPoint![0], ride.meetingPoint![1]),
              // zoom: 12,
              curve: Curves.easeOutSine,
              rotation: null,
              offset: const Offset(0, -220.0),
            );
          }
        },
        child: Column(
          children: [
            ListTile(
              leading: iconWidget,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    titleText,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(width: 8.0),
                  if (ride.status == RideStatus.accepted)
                    Row(
                      children: [
                        // Middle Dot
                        Text(
                          '•',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: 8.0),
                        CircleAvatar(
                          // backgroundColor: Colors.white,
                          radius: 8,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50.0),
                            child: CachedNetworkImage(
                              imageUrl:
                                  'https://scontent-lga3-1.cdninstagram.com/v/t51.2885-19/239083158_1041850919887570_7755239183612531984_n.jpg?stp=dst-jpg_s150x150&_nc_ht=scontent-lga3-1.cdninstagram.com&_nc_cat=110&_nc_ohc=-G3T7pl73asQ7kNvgFjLgW4&gid=b72e8aa84d7940049d9af5a959b74669&edm=AEhyXUkBAAAA&ccb=7-5&oh=00_AYCKn1GYP_pojAwBKTvJi8eskcuyXoQoqgp7crpWFQdwXg&oe=66ADCC2B&_nc_sid=8f1549',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          'Christian',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    )
                ],
              ),
              subtitle: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  PhosphorIcon(PhosphorIcons.path(PhosphorIconsStyle.fill),
                      size: 12, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 6.0),
                  Flexible(
                      child: Text.rich(
                    TextSpan(
                      text: ride.meetingPointAddress,
                      style: Theme.of(context).textTheme.bodySmall!,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )),
                ],
              ),
              trailing: IconButton.filledTonal(
                icon: Icon(
                  PhosphorIcons.navigationArrow(PhosphorIconsStyle.fill),
                  size: 18,
                ),
                onPressed: () {
                  showBottomSheet(
                    context: context,
                    builder: (context) {
                      return RideDetailsSheet(
                        rideId: ride.id!,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RideRequestCard extends StatelessWidget {
  final Ride ride;
  final AnimatedMapController? mapController;
  const RideRequestCard(
      {required this.ride, required this.mapController, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () async {
          showBottomSheet(
            context: context,
            enableDrag: true,
            builder: (context) {
              return RideDetailsSheet(
                rideId: ride.id!,
              );
            },
          );
          await mapController?.animateTo(
            dest: LatLng(ride.meetingPoint![0], ride.meetingPoint![1]),
            // zoom: 12,
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
                'Ride Request',
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
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: 16.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white),
                      onPressed: () {
                        showBottomSheet(
                          context: context,
                          builder: (context) => const ConfirmRideRequestSheet(),
                        );
                      },
                      icon: PhosphorIcon(PhosphorIcons.prohibit()),
                      label: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        showBottomSheet(
                          context: context,
                          builder: (context) => const ConfirmRideRequestSheet(),
                        );
                      },
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Accept'),
                    ),
                  ),
                ],
              ),
            )
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
