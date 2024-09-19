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
                children: [
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Exp: ',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                )),
                        const GutterSmall(),
                        Flexible(
                          child: Chip(
                            visualDensity: VisualDensity.compact,
                            side: BorderSide.none,
                            label: Text(
                              rider.yearsRiding == 0
                                  ? 'New Rider'
                                  : '${rider.yearsRiding} Years',
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gutter(),
                  // Gear Preference
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Gear: ',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                )),
                        const GutterSmall(),
                        Flexible(
                          child: Chip(
                            visualDensity: VisualDensity.compact,
                            side: BorderSide.none,
                            label: Text(
                              rider.gearLevel?.name.enumToString() ?? 'Gear',
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Gutter(),
              Text('Preferred Ride Types',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
              const GutterSmall(),
              Wrap(
                spacing: 6,
                runSpacing: 3,
                children: [
                  if (rider.rideTypes != null)
                    for (var rideType in rider.rideTypes!)
                      Chip(
                        visualDensity: VisualDensity.compact,
                        label: Text(rideType.name.enumToString()),
                      ),
                ],
              ),
              const Gutter(),
              Text('I Like Stops At',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
              const GutterSmall(),
              Wrap(
                spacing: 6,
                runSpacing: 3,
                children: [
                  if (rider.rideDestinations != null)
                    for (var rideDestination in rider.rideDestinations!)
                      Chip(
                        visualDensity: VisualDensity.compact,
                        label: Text(rideDestination.name.enumToString()),
                      ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
