import 'package:buoy/activity/bloc/activity_bloc.dart';
import 'package:buoy/locate/bloc/geolocation_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.person_rounded), label: 'Profile'),
          NavigationDestination(
              icon: Icon(Icons.person_pin_circle_rounded), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.settings_rounded), label: 'Settings'),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Wrap(
              spacing: 12.0,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: const [
                Icon(Icons.directions_boat_filled_rounded),
                Text('Buoy')
              ],
            ),
          ),
          SliverFillViewport(
              delegate: SliverChildListDelegate([
            BlocConsumer<GeolocationBloc, GeolocationState>(
              listener: (context, state) {
                if (state is GeolocationLoaded ||
                    state is GeolocationUpdating) {
                  // context
                  //     .read<ActivityBloc>()
                  //     .add(LoadMotion(isMoving: state.location!.isMoving));
                }
              },
              builder: (context, state) {
                if (state is GeolocationLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is GeolocationLoaded ||
                    state is GeolocationUpdating) {
                  final MapController mapController = MapController();
                  return Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      FlutterMap(
                        mapController: mapController,
                        options: MapOptions(
                          center: LatLng(state.location!.coords.latitude - 0.16,
                              state.location!.coords.longitude),
                          zoom: 10.0,
                          interactiveFlags:
                              InteractiveFlag.pinchZoom | InteractiveFlag.drag,
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
                          MarkerLayer(
                            markers: [
                              Marker(
                                width: 100.0,
                                height: 100.0,
                                point: LatLng(state.location!.coords.latitude,
                                    state.location!.coords.longitude),
                                builder: (ctx) => Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 24.0,
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
                              Marker(
                                width: 100.0,
                                height: 100.0,
                                point: LatLng(40.909167, -73.115497),
                                builder: (ctx) => Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 28.0,
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
                                    const CircleAvatar(
                                      backgroundColor: Colors.white,
                                      radius: 18.0,
                                      child: CircleAvatar(
                                        radius: 16.0,
                                        foregroundImage:
                                            CachedNetworkImageProvider(
                                          'https://scontent-ord5-1.xx.fbcdn.net/v/t39.30808-6/313255261_5446832598772011_8429708394281270457_n.jpg?_nc_cat=111&ccb=1-7&_nc_sid=09cbfe&_nc_ohc=aAfM7ihOqY4AX9ykEsf&_nc_ht=scontent-ord5-1.xx&oh=00_AfA8-XPV0obuRb5Y6GqW5Lo2BjZF9Vmbu7IiLOLXyPIZrA&oe=64595362',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Marker(
                                width: 100.0,
                                height: 100.0,
                                point: LatLng(40.905864, -72.743684),
                                builder: (ctx) => Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 28.0,
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
                                    const CircleAvatar(
                                      backgroundColor: Colors.white,
                                      radius: 18.0,
                                      child: CircleAvatar(
                                        radius: 16.0,
                                        foregroundImage:
                                            CachedNetworkImageProvider(
                                          'https://scontent-ord5-2.xx.fbcdn.net/v/t1.18169-9/26993314_10212996658128798_4595686453243734005_n.jpg?_nc_cat=110&ccb=1-7&_nc_sid=09cbfe&_nc_ohc=DvsvZHhuO-8AX_DksWj&_nc_ht=scontent-ord5-2.xx&oh=00_AfDiQsZAOjjtRHD57wwSRfT_c02Yci30fhFO9kNnuXcENA&oe=647B7F09',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Marker(
                                width: 100.0,
                                height: 100.0,
                                point: LatLng(40.943029, -72.943628),
                                builder: (ctx) => Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 28.0,
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
                                    const CircleAvatar(
                                      backgroundColor: Colors.white,
                                      radius: 18.0,
                                      child: CircleAvatar(
                                        radius: 16.0,
                                        foregroundImage:
                                            CachedNetworkImageProvider(
                                          'https://scontent-ord5-2.xx.fbcdn.net/v/t39.30808-6/272085883_4774303025995034_4450740488095800449_n.jpg?_nc_cat=100&ccb=1-7&_nc_sid=09cbfe&_nc_ohc=5hC_pbIbS3YAX_wWXn5&_nc_oc=AQkNkw3EI1_fxSSYx63Rss_gOgoFVDpw9e8x30aIwMqnDn47kJPrCcdLR0TJTtONZ4xbfby-qfCPd5BKNopFtnDu&_nc_ht=scontent-ord5-2.xx&oh=00_AfB6LvvSedi9lFQIcgFSFbvvvkXkhkeT-T_s2GNRWpftDg&oe=6459CFDD',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      FractionallySizedBox(
                        heightFactor: 0.5,
                        widthFactor: 1.0,
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 120.0),
                          child: CustomScrollView(
                            //shrinkWrap: true,
                            reverse: true,
                            slivers: [
                              SliverList(
                                delegate: SliverChildListDelegate(
                                  [
                                    FriendLocationCard(
                                        name: 'Justin',
                                        profilePhotoUrl:
                                            'https://scontent-ord5-2.xx.fbcdn.net/v/t39.30808-6/272085883_4774303025995034_4450740488095800449_n.jpg?_nc_cat=100&ccb=1-7&_nc_sid=09cbfe&_nc_ohc=5hC_pbIbS3YAX_wWXn5&_nc_oc=AQkNkw3EI1_fxSSYx63Rss_gOgoFVDpw9e8x30aIwMqnDn47kJPrCcdLR0TJTtONZ4xbfby-qfCPd5BKNopFtnDu&_nc_ht=scontent-ord5-2.xx&oh=00_AfB6LvvSedi9lFQIcgFSFbvvvkXkhkeT-T_s2GNRWpftDg&oe=6459CFDD',
                                        isOnline: false,
                                        location: 'Rocky Point, NY',
                                        time: 'Here for 1 hr.'),
                                    FriendLocationCard(
                                        name: 'Dad',
                                        profilePhotoUrl:
                                            'https://scontent-ord5-2.xx.fbcdn.net/v/t1.18169-9/26993314_10212996658128798_4595686453243734005_n.jpg?_nc_cat=110&ccb=1-7&_nc_sid=09cbfe&_nc_ohc=DvsvZHhuO-8AX_DksWj&_nc_ht=scontent-ord5-2.xx&oh=00_AfDiQsZAOjjtRHD57wwSRfT_c02Yci30fhFO9kNnuXcENA&oe=647B7F09',
                                        isOnline: true,
                                        location: 'Calverton, NY',
                                        time: 'Currently Moving'),
                                    FriendLocationCard(
                                        name: 'Kelly Oliva',
                                        profilePhotoUrl:
                                            'https://scontent-ord5-1.xx.fbcdn.net/v/t39.30808-6/313255261_5446832598772011_8429708394281270457_n.jpg?_nc_cat=111&ccb=1-7&_nc_sid=09cbfe&_nc_ohc=aAfM7ihOqY4AX9ykEsf&_nc_ht=scontent-ord5-1.xx&oh=00_AfA8-XPV0obuRb5Y6GqW5Lo2BjZF9Vmbu7IiLOLXyPIZrA&oe=64595362',
                                        isOnline: true,
                                        location: 'Stony Brook, NY',
                                        time: 'Here for 2 hrs.'),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 60,
                            width: 200,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24.0),
                              ),
                              child: Row(
                                children: [
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    child: CircleAvatar(
                                      radius: 18.0,
                                      foregroundImage: CachedNetworkImageProvider(
                                          'https://scontent-ord5-2.xx.fbcdn.net/v/t1.6435-9/193213907_4419559838077181_2959395753433319266_n.jpg?_nc_cat=107&ccb=1-7&_nc_sid=09cbfe&_nc_ohc=wOk65qwQtM4AX-u5oOI&_nc_ht=scontent-ord5-2.xx&oh=00_AfBfuDGJuqIyOTavFvz2JUa7KosApfemDsxTMOf86LbnUg&oe=647BE024'),
                                    ),
                                  ),
                                  BlocBuilder<ActivityBloc, ActivityState>(
                                    builder: (context, state) {
                                      if (state is ActivityLoading) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 0.0, vertical: 6.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Wading River, NY',
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
                                              Text(
                                                'Wading River, NY',
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
                                              horizontal: 0.0, vertical: 6.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Wading River, NY',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall,
                                              ),
                                              Wrap(
                                                spacing: 4.0,
                                                crossAxisAlignment:
                                                    WrapCrossAlignment.center,
                                                children: [
                                                  Icon(
                                                    state.activity == 'still'
                                                        ? Icons
                                                            .stop_circle_rounded
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
                                                    size: 14.0,
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
                                  )
                                ],
                              ),
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
            )
          ])),
          SliverList(
            delegate: SliverChildListDelegate([
              const Text('Home'),
            ]),
          ),
        ],
      ),
    );
  }
}

class FriendLocationCard extends StatelessWidget {
  final bool isOnline;
  final String name;
  String? profilePhotoUrl;
  final String location;
  final String time;
  FriendLocationCard({
    required this.isOnline,
    required this.name,
    this.profilePhotoUrl,
    required this.location,
    required this.time,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          foregroundImage: profilePhotoUrl != null
              ? CachedNetworkImageProvider(profilePhotoUrl!)
              : null,
        ),
        title: Wrap(
          spacing: 6.0,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(name),
            Icon(
                isOnline
                    ? Icons.share_location_rounded
                    : Icons.location_off_rounded,
                color: isOnline
                    ? Theme.of(context).primaryColor
                    : Colors.grey[400],
                size: isOnline ? 18.0 : 16.0)
          ],
        ),
        subtitle: Wrap(
          children: [
            Text.rich(
              TextSpan(text: location, children: [
                const TextSpan(text: ' • '),
                TextSpan(text: time),
              ]),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: IconButton(
            onPressed: () {}, icon: const Icon(Icons.chevron_right_rounded)),
      ),
    );
  }
}
