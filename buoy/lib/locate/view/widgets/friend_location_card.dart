import 'package:buoy/friends/view/friend_details_sheet.dart';
import 'package:buoy/locate/model/location.dart';
import 'package:buoy/locate/view/widgets/activity_chip.dart';
import 'package:buoy/locate/view/widgets/battery_chip.dart';
import 'package:buoy/shared/models/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';
import 'package:timeago/timeago.dart' as timeago;

class FriendLocationCard extends StatelessWidget {
  final User friend;
  final bool isOnline;
  final String name;
  final String? profilePhotoUrl;
  final String locationString;
  final Location location;
  final String? activity;
  final int? batteryLevel;
  final AnimatedMapController mapController;
  const FriendLocationCard({
    required this.friend,
    required this.isOnline,
    required this.name,
    this.profilePhotoUrl,
    required this.location,
    required this.locationString,
    this.activity,
    this.batteryLevel,
    required this.mapController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28.0),
      ),
      child: InkWell(
        onTap: () async {
          showBottomSheet(
            context: context,
            //       isScrollControlled: true,
            builder: (context) {
              return DraggableScrollableSheet(
                  expand: false,
                  maxChildSize: 0.28,
                  initialChildSize: 0.28,
                  minChildSize: 0.13,
                  builder: (context, controller) {
                    return FriendDetailsSheet(
                        friendId: friend.id!,
                        location: location,
                        scrollController: controller);
                  });
            },
          );
          await mapController.centerOnPoint(
            LatLng(double.parse(location.latitude),
                double.parse(location.longitude)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 4.0),
                  child: Hero(
                    tag: friend.id!,
                    child: CircleAvatar(
                      radius: 28,
                      foregroundImage: profilePhotoUrl != null
                          ? CachedNetworkImageProvider(profilePhotoUrl!)
                          : null,
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                            flex: 1,
                            child: Text(
                              name.split(' ').first,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            )),
                        // Icon(
                        //     isOnline
                        //         ? Icons.share_location_rounded
                        //         : Icons.location_off_rounded,
                        //     color: isOnline
                        //         ? Theme.of(context).primaryColor
                        //         : Colors.grey[500],
                        //     size: isOnline ? 14.0 : 14.0),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '  •  ${timeago.format(DateTime.parse(location.timeStamp))}',
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            maxLines: 1,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8.0,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Icon(Icons.location_on_rounded,
                                  color: Theme.of(context).primaryColor,
                                  size: 12.0),
                              const GutterTiny(),
                              Text.rich(
                                TextSpan(text: locationString, children: const [
                                  //TextSpan(text: '  • '),
                                ]),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        if (activity != null)
                          SizedBox(
                            height: 30,
                            child: ActivityChip(activity: activity),
                          ),
                        if (batteryLevel != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: 29,
                                child: BatteryChip(batteryLevel: batteryLevel),
                              ),
                              // const Icon(Icons.battery_3_bar_rounded,
                              //     color: Colors.green, size: 14.0),
                              // const GutterTiny(),
                              // Text('$batteryLevel%',
                              //     style: Theme.of(context).textTheme.bodySmall)
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Flexible(
                child: IconButton(
                    onPressed: () async {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) {
                          return DraggableScrollableSheet(
                              expand: false,
                              maxChildSize: 0.28,
                              initialChildSize: 0.28,
                              minChildSize: 0.13,
                              builder: (context, controller) {
                                return FriendDetailsSheet(
                                    friendId: friend.id!,
                                    location: location,
                                    scrollController: controller);
                              });
                        },
                      );
                      await mapController.centerOnPoint(
                        LatLng(double.parse(location.latitude),
                            double.parse(location.longitude)),
                      );
                    },
                    icon: const Icon(Icons.chevron_right_rounded)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
