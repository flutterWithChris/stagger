import 'package:avatar_glow/avatar_glow.dart';
import 'package:buoy/features/friends/bloc/friends_bloc.dart';
import 'package:buoy/features/friends/view/friend_details_sheet.dart';
import 'package:buoy/features/locate/bloc/geolocation_bloc.dart';
import 'package:buoy/features/locate/model/location.dart';
import 'package:buoy/features/locate/view/sheets/public_ride_details_sheet.dart';
import 'package:buoy/features/locate/view/sheets/ride_details_sheet.dart';
import 'package:buoy/features/locate/view/widgets/ride_details_card.dart';
import 'package:buoy/features/profile/repository/bloc/profile_bloc.dart';
import 'package:buoy/features/riders/bloc/riders_bloc.dart';
import 'package:buoy/features/riders/model/rider.dart';
import 'package:buoy/features/riders/view/sheets/rider_details_sheet.dart';
import 'package:buoy/features/rides/bloc/ride_bloc.dart';
import 'package:buoy/features/rides/bloc/rides_bloc.dart';
import 'package:buoy/features/rides/model/ride.dart';
import 'package:buoy/features/rides/ride_privacy_sheet.dart';
import 'package:buoy/features/rides/view/widgets/ride_request_card.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
        print('Geolocation State: $state');
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
                      context.read<RidersBloc>().add(LoadRidersWithinBounds(
                          widget.mapController!.mapController.camera
                              .visibleBounds));
                      context.read<RidesBloc>().add(LoadRides(
                            bounds: widget.mapController!.mapController.camera
                                .visibleBounds,
                          ));
                    },
                    onMapEvent: (p0) {
                      if (p0 is MapEventMove &&
                          p0.source != MapEventSource.mapController) {
                        EasyDebounce.debounce(
                            'rider-fetch-debounce', const Duration(seconds: 1),
                            () {
                          print('Fetching riders... ${DateTime.now()}');
                          context.read<RidersBloc>().add(LoadRidersWithinBounds(
                              widget.mapController!.mapController.camera
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
                        print('Friends State: $friendsState');
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
                                print(
                                    'Profile: ${profileState.user.firstName}');
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
                                      // if (friendsState.friends.isEmpty ||
                                      //     friendsState.locations.isEmpty) {
                                      //   print('Friends Empty...');

                                      //   return const MarkerLayer(
                                      //     markers: [],
                                      //   );
                                      // }
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
                                                //     return const SelectMeetingPointSheet();
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
                                                                            .firstName!
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
                                                                              CircleAvatar(
                                                                            backgroundColor:
                                                                                Theme.of(context).colorScheme.tertiaryFixed,
                                                                            child:
                                                                                PhosphorIcon(
                                                                              PhosphorIcons.motorcycle(
                                                                                PhosphorIconsStyle.fill,
                                                                              ),
                                                                              color: Theme.of(context).scaffoldBackgroundColor,
                                                                              size: 20,
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
                                                                    'Tapped ride Marker');

                                                                context
                                                                    .read<
                                                                        RideBloc>()
                                                                    .add(LoadRideParticipants(
                                                                        ride));

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
                                                                ).closed.then(
                                                                  (value) {
                                                                    widget
                                                                        .mapController
                                                                        ?.animateTo(
                                                                      dest: LatLng(
                                                                          ride.meetingPoint![
                                                                              0],
                                                                          ride.meetingPoint![
                                                                              1]),
                                                                      // zoom: 12,
                                                                      curve: Curves
                                                                          .easeOutSine,
                                                                      rotation:
                                                                          null,
                                                                      offset:
                                                                          const Offset(
                                                                              0,
                                                                              0),
                                                                    );
                                                                  },
                                                                );
                                                                await widget
                                                                    .mapController
                                                                    ?.animateTo(
                                                                  dest: LatLng(
                                                                      ride.meetingPoint![
                                                                          0],
                                                                      ride.meetingPoint![
                                                                          1]),
                                                                  // zoom: 12,
                                                                  curve: Curves
                                                                      .easeOutSine,
                                                                  rotation:
                                                                      null,
                                                                  offset:
                                                                      const Offset(
                                                                          0,
                                                                          -220.0),
                                                                );
                                                              },
                                                              child: Stack(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                children: [
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
                                                                          RideStatus.meetingUp =>
                                                                            PhosphorIcons.mapPinArea(PhosphorIconsStyle.fill),
                                                                          RideStatus.rejected =>
                                                                            PhosphorIcons.prohibit(PhosphorIconsStyle.fill),
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
                                                        for (Ride ride in ridesState
                                                                .receivedRides
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
                                                                    'Tapped ride Marker');

                                                                context
                                                                    .read<
                                                                        RideBloc>()
                                                                    .add(LoadRideParticipants(
                                                                        ride));

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
                                                                    return PublicRideDetailsSheet(
                                                                      rideId: ride
                                                                          .id!,
                                                                    );
                                                                  },
                                                                ).closed.then(
                                                                  (value) {
                                                                    widget
                                                                        .mapController
                                                                        ?.animateTo(
                                                                      dest: LatLng(
                                                                          ride.meetingPoint![
                                                                              0],
                                                                          ride.meetingPoint![
                                                                              1]),
                                                                      // zoom: 12,
                                                                      curve: Curves
                                                                          .easeOutSine,
                                                                      rotation:
                                                                          null,
                                                                      offset:
                                                                          const Offset(
                                                                              0,
                                                                              0),
                                                                    );
                                                                  },
                                                                );
                                                                await widget
                                                                    .mapController
                                                                    ?.animateTo(
                                                                  dest: LatLng(
                                                                      ride.meetingPoint![
                                                                          0],
                                                                      ride.meetingPoint![
                                                                          1]),
                                                                  // zoom: 12,
                                                                  curve: Curves
                                                                      .easeOutSine,
                                                                  rotation:
                                                                      null,
                                                                  offset:
                                                                      const Offset(
                                                                          0,
                                                                          -220.0),
                                                                );
                                                              },
                                                              child: Stack(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                children: [
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            2.0),
                                                                    child: switch (
                                                                        ride.status) {
                                                                      RideStatus
                                                                            .pending =>
                                                                        AvatarGlow(
                                                                          glowRadiusFactor:
                                                                              0.618,
                                                                          child:
                                                                              const CircleAvatar(
                                                                            child:
                                                                                PhosphorIcon(Icons.mode_of_travel),
                                                                          ),
                                                                        ),
                                                                      RideStatus
                                                                            .meetingUp =>
                                                                        AvatarGlow(
                                                                          glowRadiusFactor:
                                                                              0.618,
                                                                          child:
                                                                              const CircleAvatar(
                                                                            child:
                                                                                PhosphorIcon(Icons.mode_of_travel),
                                                                          ),
                                                                        ),
                                                                      RideStatus
                                                                            .rejected =>
                                                                        PhosphorIcon(
                                                                            PhosphorIcons.prohibit(PhosphorIconsStyle.fill)),
                                                                      RideStatus
                                                                            .canceled =>
                                                                        PhosphorIcon(
                                                                            PhosphorIcons.prohibit(PhosphorIconsStyle.fill)),
                                                                      RideStatus
                                                                            .completed =>
                                                                        PhosphorIcon(
                                                                            PhosphorIcons.flagCheckered(PhosphorIconsStyle.fill)),
                                                                      RideStatus
                                                                            .inProgress =>
                                                                        PhosphorIcon(
                                                                            PhosphorIcons.mapPinArea(PhosphorIconsStyle.fill)),
                                                                      null =>
                                                                        PhosphorIcon(
                                                                            PhosphorIcons.mapPinArea(PhosphorIconsStyle.fill)),
                                                                    },
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),

                                                        /// User Location
                                                        Marker(
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
                                                                        const PhosphorIcon(
                                                                      Icons
                                                                          .person_pin_circle_rounded,
                                                                      size: 32,
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
                                '${friendsState.friends[1].firstName} photo: ${friendsState.friends[1].photoUrl}');
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
                                    print('Rides State: $state');
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
