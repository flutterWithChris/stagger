import 'package:buoy/features/locate/view/sheets/ride_details_sheet.dart';
import 'package:buoy/features/rides/bloc/ride_bloc.dart';
import 'package:buoy/features/rides/model/ride.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
      RideStatus.meetingUp => 'Ride Accepted',
      RideStatus.inProgress => 'Ride In Progress',
      RideStatus.rejected => 'Ride Rejected',
      RideStatus.completed => 'Ride Completed',
      RideStatus.canceled => 'Ride Cancelled',
      null => 'Unknown Status',
    };
    Widget iconWidget = switch (ride.status) {
      RideStatus.pending => LoadingAnimationWidget.prograssiveDots(
          color: Theme.of(context).colorScheme.primary, size: 36),
      RideStatus.meetingUp => PhosphorIcon(
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
          context.read<RideBloc>().add(LoadRideParticipants(ride));
          // context.read<RideBloc>().add(SelectRide(ride));
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
                  if (ride.status == RideStatus.meetingUp)
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
