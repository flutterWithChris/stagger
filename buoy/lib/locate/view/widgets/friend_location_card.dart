import 'package:buoy/friends/view/friend_details_sheet.dart';
import 'package:buoy/locate/model/location.dart';
import 'package:buoy/shared/models/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

class FriendLocationCard extends StatelessWidget {
  final User friend;
  final Stream<List<Location>> locationUpdatesStream;
  final bool isOnline;
  final String name;
  final String? profilePhotoUrl;
  final String locationString;
  final Location location;
  final String? activity;
  final int? batteryLevel;
  FriendLocationCard({
    required this.friend,
    required this.locationUpdatesStream,
    required this.isOnline,
    required this.name,
    this.profilePhotoUrl,
    required this.location,
    required this.locationString,
    this.activity,
    this.batteryLevel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () async {
          // context.push('/friend-details/${friend.id}', extra: location);
          showBottomSheet(
            context: context,
            builder: (context) {
              return DraggableScrollableSheet(
                  expand: false,
                  maxChildSize: 0.9,
                  builder: (context, controller) {
                    return FriendDetailsSheet(
                        friendId: friend.id!,
                        location: location,
                        scrollController: controller);
                  });
            },
          );
        },
        leading: CircleAvatar(
          radius: 22,
          foregroundImage: profilePhotoUrl != null
              ? CachedNetworkImageProvider(profilePhotoUrl!)
              : null,
          child: const Icon(
            Icons.person_rounded,
            color: Colors.white,
          ),
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
                    : Colors.grey[500],
                size: isOnline ? 18.0 : 16.0),
          ],
        ),
        subtitle: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8.0,
          children: [
            Text.rich(
              TextSpan(text: locationString, children: const [
                //TextSpan(text: '  • '),
              ]),
              style: Theme.of(context).textTheme.bodySmall,
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
                    height: 30,
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
        trailing: IconButton(
            onPressed: () {}, icon: const Icon(Icons.chevron_right_rounded)),
      ),
    );
  }
}

class BatteryChip extends StatelessWidget {
  const BatteryChip({
    super.key,
    required this.batteryLevel,
  });

  final int? batteryLevel;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Chip(
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40.0),
        ),
        visualDensity: VisualDensity.compact,
        label: Text('$batteryLevel%',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).scaffoldBackgroundColor)),
        avatar: batteryLevel == 100
            ? Icon(Icons.battery_full_rounded,
                color: Theme.of(context).scaffoldBackgroundColor, size: 18.0)
            : batteryLevel! > 50
                ? Icon(Icons.battery_5_bar,
                    color: Theme.of(context).scaffoldBackgroundColor,
                    size: 18.0)
                : batteryLevel! > 20
                    ? Icon(Icons.battery_3_bar,
                        color: Theme.of(context).scaffoldBackgroundColor,
                        size: 18.0)
                    : Icon(Icons.battery_alert_rounded,
                        color: Theme.of(context).scaffoldBackgroundColor,
                        size: 18.0),
        backgroundColor: batteryLevel! > 50
            ? Colors.green
            : batteryLevel! > 20
                ? Colors.orange
                : Colors.red,
      ),
    );
  }
}

class ActivityChip extends StatelessWidget {
  const ActivityChip({
    super.key,
    required this.activity,
  });

  final String? activity;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Chip(
        labelStyle: const TextStyle(
          color: Color.fromARGB(255, 247, 247, 247),
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: activity == 'walking'
            ? Theme.of(context).colorScheme.primaryContainer
            : activity == 'driving'
                ? Theme.of(context).colorScheme.secondaryContainer
                : activity == 'stationary'
                    ? Theme.of(context).colorScheme.tertiaryContainer
                    : activity == 'cycling'
                        ? Theme.of(context).colorScheme.secondaryContainer
                        : activity == 'running'
                            ? Theme.of(context).colorScheme.tertiaryContainer
                            : Theme.of(context).colorScheme.primaryContainer,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40.0),
        ),
        visualDensity: VisualDensity.compact,
        label: Text(
          activity!.capitalize,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: activity == 'walking'
                  ? const Color.fromARGB(255, 100, 100, 100)
                  : null),
        ),
        avatar: activity == 'walking'
            ? const Icon(
                Icons.hiking_rounded,
                color: Color.fromARGB(255, 100, 100, 100),
                size: 18.0,
              )
            : activity == 'driving'
                ? const Icon(
                    Icons.drive_eta_rounded,
                    size: 18.0,
                    color: Color.fromARGB(255, 247, 247, 247),
                  )
                : activity == 'stationary'
                    ? const Icon(Icons.pause,
                        size: 18.0, color: Color.fromARGB(255, 247, 247, 247))
                    : activity == 'cycling'
                        ? Icon(
                            Icons.directions_bike_rounded,
                            size: 18.0,
                            color: Theme.of(context).primaryColor,
                          )
                        : activity == 'running'
                            ? const Icon(
                                Icons.directions_run_rounded,
                                size: 18.0,
                                color: Color.fromARGB(255, 247, 247, 247),
                              )
                            : const SizedBox(),
      ),
    );
  }
}
