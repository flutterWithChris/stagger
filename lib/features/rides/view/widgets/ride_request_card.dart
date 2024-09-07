import 'package:buoy/features/locate/view/map/main_map.dart';
import 'package:buoy/features/locate/view/sheets/confirm_ride_request_sheet.dart';
import 'package:buoy/features/locate/view/sheets/ride_details_sheet.dart';
import 'package:buoy/features/rides/model/ride.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
                    child: PhosphorIcon(
                      PhosphorIcons.mapPinArea(
                        PhosphorIconsStyle.fill,
                      ),
                      size: 18,
                    ),
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
