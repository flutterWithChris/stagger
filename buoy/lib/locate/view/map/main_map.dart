import 'package:buoy/friends/bloc/friends_bloc.dart';
import 'package:buoy/locate/bloc/geolocation_bloc.dart';
import 'package:buoy/locate/model/location.dart';
import 'package:buoy/locate/view/widgets/friend_location_card.dart';
import 'package:buoy/profile/repository/bloc/profile_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';

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
        if (state is GeolocationLoaded || state is GeolocationUpdating) {
          await mapController?.animateTo(
              dest: LatLng(state.bgLocation!.coords.latitude,
                  state.bgLocation!.coords.longitude));
        }
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
                mapController: mapController,
                options: MapOptions(
                  center: LatLng(state.bgLocation!.coords.latitude - 0.16,
                      state.bgLocation!.coords.longitude),
                  zoom: 10.0,
                  maxZoom: 18.0,
                  minZoom: 2.0,
                  maxBounds:
                      LatLngBounds(LatLng(-90.0, -180.0), LatLng(90.0, 180.0)),
                  interactiveFlags: InteractiveFlag.pinchZoom |
                      InteractiveFlag.drag |
                      InteractiveFlag.doubleTapZoom |
                      InteractiveFlag.flingAnimation,
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
                      if (friendsState is FriendsLoaded) {
                        return StreamBuilder<List<Location>>(
                            stream: friendsState.locationUpdatesStream,
                            builder: (context, snapshot) {
                              var data = snapshot.data;
                              if (data == null) {
                                return MarkerLayer(
                                  markers: [
                                    /// User Location
                                    Marker(
                                      anchorPos:
                                          AnchorPos.align(AnchorAlign.top),
                                      width: 32.0,
                                      height: 32.0,
                                      point: LatLng(
                                          state.bgLocation!.coords.latitude,
                                          state.bgLocation!.coords.longitude),
                                      builder: (ctx) => Stack(
                                        clipBehavior: Clip.none,
                                        alignment: Alignment.center,
                                        children: [
                                          CircleAvatar(
                                            radius: 30.0,
                                            backgroundColor:
                                                Theme.of(context).splashColor,
                                          )
                                              .animate(
                                                onComplete: (controller) =>
                                                    controller.repeat(),
                                              )
                                              .fadeIn(duration: 800.ms)
                                              .scale(duration: 1.618.seconds)
                                              .fadeOut(delay: 800.ms),
                                          Icon(
                                            Icons.person_pin_circle_rounded,
                                            color:
                                                Theme.of(context).primaryColor,
                                            size: 30.0,
                                            fill: 1.0,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }
                              print('Location Data: $data');
                              // Find matching ids in friend objects and location stream & print them
                              for (Location location in data) {
                                if (location.userId ==
                                    friendsState.friends[1].id) {
                                  print('Matching id: ${location.userId}');
                                  print(
                                      '${friendsState.friends[1].name} photo: ${friendsState.friends[1].photoUrl}');
                                }
                              }
                              // print(
                              //     'Location: ${location.coords.latitude}, ${location.coords.longitude}');
                              return BlocBuilder<ProfileBloc, ProfileState>(
                                builder: (context, profileState) {
                                  if (profileState is ProfileLoading) {
                                    return MarkerLayer(
                                      markers: [],
                                    );
                                  }
                                  if (profileState is ProfileLoaded) {
                                    print('Profile: ${profileState.user.name}');
                                    return MarkerLayer(
                                      markers: [
                                        /// User Location
                                        Marker(
                                          anchorPos:
                                              AnchorPos.align(AnchorAlign.top),
                                          width: 32.0,
                                          height: 32.0,
                                          point: LatLng(
                                              state.bgLocation!.coords.latitude,
                                              state.bgLocation!.coords
                                                  .longitude),
                                          builder: (ctx) => Stack(
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
                                                    onComplete: (controller) =>
                                                        controller.repeat(),
                                                  )
                                                  .fadeIn(duration: 800.ms)
                                                  .scale(
                                                      duration: 1.618.seconds)
                                                  .fadeOut(delay: 800.ms),
                                              InkWell(
                                                onTap: () async {
                                                  await mapController
                                                      ?.animateTo(
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
                                                  backgroundColor: Colors.white,
                                                  radius: 18.0,
                                                  child: CircleAvatar(
                                                    radius: 16.0,
                                                    foregroundImage:
                                                        CachedNetworkImageProvider(
                                                      profileState
                                                              .user.photoUrl ??
                                                          '',
                                                    ),
                                                    child: profileState.user
                                                                    .photoUrl ==
                                                                null ||
                                                            profileState.user
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
                                                                  color: Theme.of(
                                                                          context)
                                                                      .scaffoldBackgroundColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w800,
                                                                ),
                                                          )
                                                        : null,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        for (Location location in data)
                                          Marker(
                                            width: 100.0,
                                            height: 100.0,
                                            point: LatLng(
                                                double.parse(location.latitude),
                                                double.parse(
                                                    location.longitude)),
                                            builder: (ctx) => Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                CircleAvatar(
                                                  radius: 28.0,
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
                                                    .fadeIn(duration: 800.ms)
                                                    .scale(
                                                        duration: 1.618.seconds)
                                                    .fadeOut(delay: 800.ms),
                                                InkWell(
                                                  onTap: () async {
                                                    await mapController
                                                        ?.centerOnPoint(
                                                      LatLng(
                                                        double.parse(
                                                            location.latitude),
                                                        double.parse(
                                                            location.longitude),
                                                      ),
                                                    );
                                                  },
                                                  child: CircleAvatar(
                                                    backgroundColor:
                                                        Colors.white,
                                                    radius: 18.0,
                                                    child: CircleAvatar(
                                                      radius: 16.0,
                                                      foregroundImage:
                                                          CachedNetworkImageProvider(
                                                        friendsState.friends
                                                                .firstWhere(
                                                                    (friend) =>
                                                                        friend
                                                                            .id ==
                                                                        location
                                                                            .userId)
                                                                .photoUrl ??
                                                            '',
                                                      ),
                                                      child: friendsState
                                                                  .friends
                                                                  .firstWhere((friend) =>
                                                                      friend
                                                                          .id ==
                                                                      location
                                                                          .userId)
                                                                  .photoUrl ==
                                                              null
                                                          ? Text(friendsState
                                                              .friends
                                                              .firstWhere(
                                                                  (friend) =>
                                                                      friend
                                                                          .id ==
                                                                      location
                                                                          .userId)
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
                                  } else {
                                    return MarkerLayer(
                                      markers: [],
                                    );
                                  }
                                },
                              );
                            });
                      } else {
                        return MarkerLayer(
                          markers: [
                            /// User Location
                            Marker(
                              anchorPos: AnchorPos.align(AnchorAlign.top),
                              width: 32.0,
                              height: 32.0,
                              point: LatLng(state.bgLocation!.coords.latitude,
                                  state.bgLocation!.coords.longitude),
                              builder: (ctx) => Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 30.0,
                                    backgroundColor:
                                        Theme.of(context).splashColor,
                                  )
                                      .animate(
                                        onComplete: (controller) =>
                                            controller.repeat(),
                                      )
                                      .fadeIn(duration: 800.ms)
                                      .scale(duration: 1.618.seconds)
                                      .fadeOut(delay: 800.ms),
                                  Icon(
                                    Icons.person_pin_circle_rounded,
                                    color: Theme.of(context).primaryColor,
                                    size: 30.0,
                                    fill: 1.0,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }
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
                              BlocBuilder<FriendsBloc, FriendsState>(
                                builder: (context, state) {
                                  if (state is FriendsLoading) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  if (state is FriendsError) {
                                    return const Center(
                                      child: Text('Error'),
                                    );
                                  } else if (state is FriendsLoaded) {
                                    return StreamBuilder<List<Location>>(
                                        stream: state.locationUpdatesStream,
                                        builder: (context, snapshot) {
                                          var data = snapshot.data;
                                          if (data == null ||
                                              snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          } else if (data.isEmpty) {
                                            return const Center(
                                              child: Text('No Friends'),
                                            );
                                          }
                                          print('Stream data received');
                                          // Print location updates
                                          data.forEach(
                                            (element) => print(
                                                element.toJson().toString()),
                                          );
                                          return Column(
                                            children: [
                                              ...state.friends.map((friend) {
                                                Location location = data
                                                    .firstWhere((location) =>
                                                        location.userId ==
                                                        friend.id);
                                                return FriendLocationCard(
                                                  friend: friend,
                                                  locationUpdatesStream: state
                                                      .locationUpdatesStream,
                                                  name: friend.name!,
                                                  activity: location.activity,
                                                  batteryLevel:
                                                      location.batteryLevel,
                                                  location: location,
                                                  locationString: 'Ridge, NY',
                                                  isOnline: true,
                                                  profilePhotoUrl:
                                                      friend.photoUrl,
                                                );
                                              }).toList(),
                                            ],
                                          );
                                        });
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
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(right: 12.0),
                              child: CircleAvatar(
                                radius: 20.0,
                                child: Icon(
                                  Icons.person_pin_circle_rounded,
                                  color: Colors.white,
                                  size: 30.0,
                                  fill: 1.0,
                                ),
                                foregroundImage: CachedNetworkImageProvider(
                                    'https://scontent-ord5-2.xx.fbcdn.net/v/t1.6435-9/193213907_4419559838077181_2959395753433319266_n.jpg?_nc_cat=107&ccb=1-7&_nc_sid=09cbfe&_nc_ohc=wOk65qwQtM4AX-u5oOI&_nc_ht=scontent-ord5-2.xx&oh=00_AfBfuDGJuqIyOTavFvz2JUa7KosApfemDsxTMOf86LbnUg&oe=647BE024'),
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
                                  return Center(
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
                                                    Icons.hiking_rounded,
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
                                                    Icon(
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
                                                                .hiking_rounded
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
                                                    color: const Color.fromARGB(
                                                        255, 100, 100, 100),
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
