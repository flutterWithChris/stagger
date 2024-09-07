import 'package:buoy/features/riders/model/rider.dart';
import 'package:buoy/core/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class RiderDetailsSheet extends StatelessWidget {
  final Rider rider;
  const RiderDetailsSheet({required this.rider, super.key});

  @override
  Widget build(BuildContext context) {
    print('Selected Rider: $rider');
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.33,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            controller: scrollController,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Rider Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  leading:
                      Icon(PhosphorIcons.motorcycle(PhosphorIconsStyle.fill)),
                  title: Text(
                    rider.bikeType?.name.enumToString() ?? 'Bike Type',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  trailing: rider.ridingStyle != null
                      ? buildRiderStyleChip(context, rider.ridingStyle!)
                      : null,
                ),
              ),
              const Gutter(),
              // Row(
              //   children: [
              //     Expanded(
              //       child: FilledButton.icon(
              //           icon: PhosphorIcon(
              //             PhosphorIcons.motorcycle(),
              //             size: 20,
              //           ),
              //           onPressed: () {},
              //           label: const Text('Invite to Ride')),
              //     ),
              //   ],
              // ),
              // const Gutter(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Experience: ',
                      style: Theme.of(context).textTheme.bodyMedium),
                  const GutterSmall(),
                  const Chip(
                    visualDensity: VisualDensity.compact,
                    side: BorderSide.none,
                    label: Text(
                      '3 Years',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: Colors.orange,
                  ),
                ],
              ),
              const Gutter(),
              const Text('Preferred Ride Types'),
              const GutterSmall(),
              Wrap(
                spacing: 6,
                runSpacing: 3,
                children: [
                  Chip(
                    visualDensity: VisualDensity.compact,
                    avatar: PhosphorIcon(PhosphorIcons.sunHorizon()),
                    label: const Text('Sunset Rides'),
                  ),
                  Chip(
                    visualDensity: VisualDensity.compact,
                    avatar: PhosphorIcon(PhosphorIcons.moon()),
                    label: const Text('Night Rides'),
                  ),
                  Chip(
                    visualDensity: VisualDensity.compact,
                    avatar: PhosphorIcon(PhosphorIcons.sun()),
                    label: const Text('Day Rides'),
                  ),
                  if (rider.rideTypes != null)
                    for (var rideType in rider.rideTypes!)
                      Chip(
                        visualDensity: VisualDensity.compact,
                        avatar: PhosphorIcon(PhosphorIcons.motorcycle()),
                        label: Text(rideType.name.enumToString()),
                      ),
                ],
              ),
              const Gutter(),
              const Text('I Like Stops At'),
              const GutterSmall(),
              Wrap(
                spacing: 6,
                runSpacing: 3,
                children: [
                  Chip(
                      visualDensity: VisualDensity.compact,
                      avatar: PhosphorIcon(PhosphorIcons.coffee()),
                      label: const Text('Cafes')),
                  Chip(
                      visualDensity: VisualDensity.compact,
                      avatar: PhosphorIcon(PhosphorIcons.iceCream()),
                      label: const Text('Ice Cream Shops')),
                  Chip(
                      visualDensity: VisualDensity.compact,
                      avatar: PhosphorIcon(PhosphorIcons.pizza()),
                      label: const Text('Pizza Places')),
                  Chip(
                      visualDensity: VisualDensity.compact,
                      avatar: PhosphorIcon(PhosphorIcons.hamburger()),
                      label: const Text('Burger Joints')),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Chip buildRiderStyleChip(BuildContext context, RidingStyle ridingStyle) {
    return Chip(
      avatar: Icon(
        switch (rider.ridingStyle) {
          RidingStyle.cruiser => PhosphorIcons.mountains(
              PhosphorIconsStyle.fill,
            ),
          RidingStyle.balanced => PhosphorIcons.motorcycle(
              PhosphorIconsStyle.fill,
            ),
          RidingStyle.fast => PhosphorIcons.flagCheckered(
              PhosphorIconsStyle.fill,
            ),
          null => PhosphorIcons.motorcycle(
              PhosphorIconsStyle.fill,
            ),
        },
        color: Colors.orange[300],
        size: 18,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      label: Text.rich(
        TextSpan(
          text: ' ${rider.ridingStyle!.name.enumToString()} Rider',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
