import 'package:buoy/profile/repository/bloc/profile_bloc.dart';
import 'package:buoy/rides/bloc/ride_bloc.dart';
import 'package:buoy/rides/bloc/rides_bloc.dart';
import 'package:buoy/rides/model/ride.dart';
import 'package:buoy/rides/model/ride_participant.dart';
import 'package:buoy/shared/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class RideDetailsSheet extends StatelessWidget {
  RideDetailsSheet({
    super.key,
    required this.rideId,
  });

  String rideId;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        initialChildSize: 0.618,
        expand: false,
        builder: (context, controller) => BlocConsumer<RidesBloc, RidesState>(
              listener: (context, state) {
                if (state is RideCompleted) {
                  scaffoldMessengerKey.currentState!.showSnackBar(
                    getSuccessSnackbar('Ride Completed!'),
                  );
                  if (context.mounted) {
                    context.pop();
                  }
                }
              },
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
                } else if (state is RidesLoaded) {
                  Ride ride = state.myRides
                          .firstWhereOrNull((ride) => ride.id == rideId) ??
                      state.receivedRides
                          .firstWhere((ride) => ride.id == rideId);

                  print('All Participants: ${ride.rideParticipants}');
                  RideParticipant rider = ride.rideParticipants!.firstWhere(
                      (rider) =>
                          rider.userId ==
                          Supabase.instance.client.auth.currentUser!.id);
                  print('Rider arrival status: ${rider.arrivalStatus}');
                  List<RideParticipant> riders = ride.rideParticipants!
                      .where((rider) =>
                          rider.id !=
                          Supabase.instance.client.auth.currentUser!.id)
                      .toList();
                  bool allRidersAtMeetingPoint = rider.arrivalStatus ==
                          ArrivalStatus.atMeetingPoint &&
                      riders.every((rider) =>
                          rider.arrivalStatus == ArrivalStatus.atMeetingPoint);
                  bool waitingForRiders =
                      rider.arrivalStatus == ArrivalStatus.atMeetingPoint &&
                          riders.any((rider) =>
                              rider.arrivalStatus == ArrivalStatus.stopped ||
                              rider.arrivalStatus == ArrivalStatus.enRoute);
                  bool atMeetingPoint =
                      rider.arrivalStatus == ArrivalStatus.atMeetingPoint;
                  bool atDestination =
                      rider.arrivalStatus == ArrivalStatus.atDestination;
                  bool enRoute = rider.arrivalStatus == ArrivalStatus.enRoute;
                  bool stopped = rider.arrivalStatus == ArrivalStatus.stopped;

                  return Column(
                    //  /   physics: const NeverScrollableScrollPhysics(),
                    // controller: controller,
                    mainAxisSize: MainAxisSize.min,
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
                      // Title
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Ride Details',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      RideStepper(
                          ride: ride,
                          allRidersAtMeetingPoint: allRidersAtMeetingPoint,
                          waitingForRiders: waitingForRiders),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (ride.status == RideStatus.accepted ||
                              ride.status == RideStatus.pending)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: MeetingPointAddressWidget(ride: ride),
                            ),

                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: RideActionCard(
                                ride: ride,
                                atMeetingPoint: atMeetingPoint,
                                waitingForRiders: waitingForRiders,
                                allRidersAtMeetingPoint:
                                    allRidersAtMeetingPoint,
                                enRoute: enRoute,
                                rider: rider,
                                stopped: stopped),
                          ),
                          const SizedBox(height: 8.0),
                          // Get Directions Button
                          if (ride.status == RideStatus.accepted && enRoute)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: ImHereButton(ride: ride),
                            ),
                          if (atMeetingPoint &&
                              allRidersAtMeetingPoint &&
                              ride.status == RideStatus.accepted)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: StartRideButton(ride: ride),
                            ),
                          if (ride.status == RideStatus.accepted)
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: CancelRideButton(),
                            ),
                          if (ride.status == RideStatus.inProgress)
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: FinishRideButton(),
                            ),
                          const SizedBox(height: 8.0),
                          // Riders List
                          if (ride.rideParticipants!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 0.0),
                              child: RidersList(ride: ride),
                            ),
                        ],
                      ),
                    ],
                  );
                } else {
                  return const Center(
                    child: Text('Something Went Wrong...'),
                  );
                }
              },
            ));
  }
}

class FinishRideButton extends StatelessWidget {
  const FinishRideButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        side: const BorderSide(
          color: Colors.red,
          width: 2.0,
        ),
      ),
      onPressed: () {
        context.read<RideBloc>().add(FinishRide(
              context.read<RideBloc>().state.ride!.copyWith(
                    status: RideStatus.completed,
                  ),
            ));
      },
      icon: PhosphorIcon(
        PhosphorIcons.flag(),
        size: 20,
      ),
      label: const Text('Finish Ride'),
    );
  }
}

class RidersList extends StatelessWidget {
  const RidersList({
    super.key,
    required this.ride,
  });

  final Ride ride;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Riders',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 8.0),
        ListView.builder(
          shrinkWrap: true,
          itemCount: ride.rideParticipants!.length,
          itemBuilder: (context, index) {
            RideParticipant rider = ride.rideParticipants![index];
            return Material(
              type: MaterialType.transparency,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              // borderRadius: BorderRadius.circular(16.0),
              child: InkWell(
                radius: 16.0,
                customBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                borderRadius: BorderRadius.circular(16.0),
                onTap: () => context.go('/profile/${rider.userId}'),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  onTap: () {},
                  leading: const CircleAvatar(
                    radius: 24.0,
                    foregroundImage: CachedNetworkImageProvider(
                        'https://scontent-lga3-1.cdninstagram.com/v/t51.2885-19/239083158_1041850919887570_7755239183612531984_n.jpg?stp=dst-jpg_s150x150&_nc_ht=scontent-lga3-1.cdninstagram.com&_nc_cat=110&_nc_ohc=N89ZbyRlvsMQ7kNvgHSGD4V&gid=3de9eaed2f0241b48c6ca6bf392219c2&edm=AFg4Q8wBAAAA&ccb=7-5&oh=00_AYCFBSzLCF1NWqhA3o4VH_6R5PqiaLiv6RpnsjZk03rxJw&oe=66B57CEB&_nc_sid=0b30b7'),
                  ),
                  title: Text(
                    rider.name ?? 'N/A',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    switch (rider.arrivalStatus) {
                      ArrivalStatus.atMeetingPoint => 'At Meeting Point',
                      ArrivalStatus.atDestination => 'At Destination',
                      ArrivalStatus.enRoute => 'En Route',
                      ArrivalStatus.stopped => 'Stopped',
                      null => 'Unknown',
                    },
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class CancelRideButton extends StatelessWidget {
  const CancelRideButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      // style: OutlinedButton.styleFrom(
      //     side: const BorderSide(
      //   color: Colors.red,
      //   width: 2.0,
      // )),
      onPressed: () {
        context.pop();
      },
      icon: PhosphorIcon(
        PhosphorIcons.prohibit(),
        size: 20,
      ),
      label: const Text('Cancel Ride'),
    );
  }
}

class StartRideButton extends StatelessWidget {
  const StartRideButton({
    super.key,
    required this.ride,
  });

  final Ride ride;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: BlocConsumer<RideBloc, RideState>(
            listener: (context, state) {
              if (state is RideError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  getErrorSnackbar('Error starting ride!'),
                );
              }
              if (state is RideUpdated) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(getSuccessSnackbar('Ride Started!'));
              }
            },
            builder: (context, state) {
              if (state is RideLoading) {
                return FilledButton.icon(
                  onPressed: () {},
                  label: Row(
                    children: [
                      LoadingAnimationWidget.prograssiveDots(
                        color: Theme.of(context).colorScheme.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 8.0),
                      const Text('Starting Ride...'),
                    ],
                  ),
                  icon: PhosphorIcon(
                    PhosphorIcons.motorcycle(PhosphorIconsStyle.fill),
                  ),
                );
              }
              return FilledButton.icon(
                onPressed: () {
                  context.read<RideBloc>().add(UpdateRide(
                        ride.copyWith(
                          status: RideStatus.inProgress,
                        ),
                      ));
                },
                label: const Text('Start Ride'),
                icon: PhosphorIcon(
                  PhosphorIcons.motorcycle(PhosphorIconsStyle.fill),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ImHereButton extends StatelessWidget {
  const ImHereButton({
    super.key,
    required this.ride,
  });

  final Ride ride;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () {
              context.read<RideBloc>().add(UpdateArrivalStatus(
                  ride: ride,
                  userId: context.read<ProfileBloc>().state.user!.id!,
                  arrivalStatus: ArrivalStatus.atMeetingPoint));
            },
            label: const Text('I\'m Here'),
            icon: PhosphorIcon(
              PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
            ),
          ),
        ),
      ],
    );
  }
}

class RideActionCard extends StatelessWidget {
  const RideActionCard({
    super.key,
    required this.ride,
    required this.atMeetingPoint,
    required this.waitingForRiders,
    required this.allRidersAtMeetingPoint,
    required this.enRoute,
    required this.rider,
    required this.stopped,
  });

  final Ride ride;
  final bool atMeetingPoint;
  final bool waitingForRiders;
  final bool allRidersAtMeetingPoint;
  final bool enRoute;
  final RideParticipant rider;
  final bool stopped;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
          leading: switch (ride.status) {
            RideStatus.pending => LoadingAnimationWidget.prograssiveDots(
                color: Theme.of(context).colorScheme.primary, size: 36),
            RideStatus.accepted => PhosphorIcon(
                atMeetingPoint && waitingForRiders
                    ? PhosphorIcons.clock(
                        PhosphorIconsStyle.fill,
                      )
                    : allRidersAtMeetingPoint
                        ? PhosphorIcons.checkCircle(
                            PhosphorIconsStyle.fill,
                          )
                        : PhosphorIcons.mapPinArea(
                            PhosphorIconsStyle.fill,
                          ),
                color: allRidersAtMeetingPoint ? Colors.green[400] : null,
              ),
            RideStatus.inProgress => PhosphorIcon(PhosphorIcons.motorcycle(
                PhosphorIconsStyle.fill,
              )),
            RideStatus.rejected => PhosphorIcon(PhosphorIcons.motorcycle(
                PhosphorIconsStyle.fill,
              )),
            RideStatus.rejectedWithResponse =>
              PhosphorIcon(PhosphorIcons.motorcycle(
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
          },
          title: Text(
            ride.status == RideStatus.pending
                ? 'Waiting For Rider Response...'
                : ride.status == RideStatus.accepted
                    ? enRoute
                        ? '${ride.meetingPointAddress}'
                        : atMeetingPoint && waitingForRiders
                            ? 'Wait for Christian to arrive...'
                            : atMeetingPoint && allRidersAtMeetingPoint
                                ? 'It\'s time to ride!'
                                : ride.status == RideStatus.rejected
                                    ? 'Ride Request Rejected'
                                    : ride.status == RideStatus.completed
                                        ? 'Ride Request Completed'
                                        : ride.status == RideStatus.canceled
                                            ? 'Ride Request Canceled'
                                            : ride.status ==
                                                    RideStatus
                                                        .rejectedWithResponse
                                                ? 'Ride Changes Requested'
                                                : 'Ride Request Unknown'
                    : 'Ride In Progress',
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: ride.status == RideStatus.accepted &&
                  (rider.arrivalStatus == ArrivalStatus.stopped ||
                      rider.arrivalStatus == ArrivalStatus.enRoute)
              ? Text.rich(
                  TextSpan(
                    text: 'It\'s time to head to the meeting point!',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : ride.status == RideStatus.accepted
                  ? atMeetingPoint && waitingForRiders
                      ? Text.rich(
                          TextSpan(
                            text: 'We let them know you\'re here!',
                            style:
                                Theme.of(context).textTheme.bodySmall!.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : atMeetingPoint && allRidersAtMeetingPoint
                          ? Text.rich(
                              TextSpan(
                                  text: 'Let\'s get this show on the road!',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                        fontWeight: FontWeight.w600,
                                      )),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : null
                  : null,
          trailing: ride.status == RideStatus.accepted && (enRoute || stopped)
              ? IconButton.filledTonal(
                  onPressed: () {},
                  icon: PhosphorIcon(
                    switch (ride.status) {
                      RideStatus.pending => PhosphorIcons.clock(
                          PhosphorIconsStyle.fill,
                        ),
                      RideStatus.accepted => switch (rider.arrivalStatus) {
                          ArrivalStatus.stopped =>
                            PhosphorIcons.navigationArrow(
                              PhosphorIconsStyle.fill,
                            ),
                          ArrivalStatus.enRoute =>
                            PhosphorIcons.navigationArrow(
                              PhosphorIconsStyle.fill,
                            ),
                          ArrivalStatus.atMeetingPoint =>
                            PhosphorIcons.navigationArrow(
                              PhosphorIconsStyle.fill,
                            ),
                          ArrivalStatus.atDestination =>
                            PhosphorIcons.navigationArrow(
                              PhosphorIconsStyle.fill,
                            ),
                          null => PhosphorIcons.navigationArrow(
                              PhosphorIconsStyle.fill,
                            ),
                        },
                      RideStatus.inProgress => PhosphorIcons.motorcycle(
                          PhosphorIconsStyle.fill,
                        ),
                      RideStatus.rejected => PhosphorIcons.motorcycle(
                          PhosphorIconsStyle.fill,
                        ),
                      RideStatus.rejectedWithResponse =>
                        PhosphorIcons.motorcycle(
                          PhosphorIconsStyle.fill,
                        ),
                      RideStatus.completed => PhosphorIcons.motorcycle(
                          PhosphorIconsStyle.fill,
                        ),
                      RideStatus.canceled => PhosphorIcons.motorcycle(
                          PhosphorIconsStyle.fill,
                        ),
                      null => PhosphorIcons.motorcycle(
                          PhosphorIconsStyle.fill,
                        ),
                    },
                  ),
                )
              : null),
    );
  }
}

class MeetingPointAddressWidget extends StatelessWidget {
  const MeetingPointAddressWidget({
    super.key,
    required this.ride,
  });

  final Ride ride;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (ride.status != RideStatus.accepted)
                Expanded(
                  child: Row(
                    children: [
                      PhosphorIcon(
                        PhosphorIcons.mapPinArea(
                          PhosphorIconsStyle.fill,
                        ),
                        size: 20,
                      ),
                      const SizedBox(width: 8.0),
                      Flexible(
                          child: Text.rich(
                        TextSpan(
                          text: 'Meet at: ',
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
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
            ],
          ),
        ),
      ],
    );
  }
}

class RideStepper extends StatelessWidget {
  const RideStepper({
    super.key,
    required this.ride,
    required this.allRidersAtMeetingPoint,
    required this.waitingForRiders,
  });

  final Ride ride;
  final bool allRidersAtMeetingPoint;
  final bool waitingForRiders;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 40,
        width: MediaQuery.sizeOf(context).width,
        child: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.transparent,
            colorScheme: Theme.of(context).brightness == Brightness.light
                ? ColorScheme.light(
                    primary: Theme.of(context).colorScheme.primaryContainer,
                    secondary: Colors.blue,
                    onSurface: Colors.grey,
                    // ignore: deprecated_member_use
                    background: Colors.blue)
                : ColorScheme.dark(
                    primary: Colors.green[600]!,
                    secondary: Colors.green[600]!,

                    // ignore: deprecated_member_use
                    background: Colors.grey[600]),
          ),
          child: IgnorePointer(
            child: OverflowBox(
              maxHeight: 72,
              child: Stepper(
                  margin: EdgeInsets.zero,
                  elevation: 0,
                  type: StepperType.horizontal,
                  connectorThickness: 2.5,
                  controlsBuilder: (context, details) {
                    return const SizedBox();
                  },
                  currentStep: ride.status == RideStatus.accepted
                      ? 1
                      : ride.status == RideStatus.inProgress
                          ? 2
                          : 1,
                  stepIconBuilder: (stepIndex, stepState) {
                    return stepIndex == 0
                        ? CircleAvatar(
                            backgroundColor: ride.status == RideStatus.pending
                                ? Colors.blue
                                : Colors.transparent,
                            foregroundColor:
                                ride.status == RideStatus.accepted ||
                                        ride.status == RideStatus.inProgress
                                    ? Colors.white
                                    : null,
                            child: PhosphorIcon(
                              ride.status == RideStatus.accepted ||
                                      ride.status == RideStatus.inProgress
                                  ? PhosphorIcons.checkCircle(
                                      PhosphorIconsStyle.fill,
                                    )
                                  : PhosphorIcons.clock(
                                      PhosphorIconsStyle.fill,
                                    ),
                              size: 16,
                            ),
                          )
                        : stepIndex == 1
                            ? CircleAvatar(
                                backgroundColor:
                                    ride.status == RideStatus.accepted &&
                                            allRidersAtMeetingPoint == false
                                        ? Colors.blue
                                        : Colors.transparent,
                                foregroundColor:
                                    ride.status == RideStatus.accepted ||
                                            ride.status == RideStatus.inProgress
                                        ? Colors.white
                                        : null,
                                child: PhosphorIcon(
                                  ride.status == RideStatus.inProgress ||
                                          allRidersAtMeetingPoint
                                      ? PhosphorIcons.checkCircle(
                                          PhosphorIconsStyle.fill,
                                        )
                                      : waitingForRiders
                                          ? PhosphorIcons.clock(
                                              PhosphorIconsStyle.fill,
                                            )
                                          : PhosphorIcons.mapPinArea(
                                              PhosphorIconsStyle.fill,
                                            ),
                                  size: 16,
                                ),
                              )
                            : CircleAvatar(
                                backgroundColor:
                                    ride.status == RideStatus.accepted ||
                                            allRidersAtMeetingPoint == true
                                        ? Colors.blue
                                        : Colors.transparent,
                                foregroundColor:
                                    ride.status == RideStatus.accepted ||
                                            ride.status == RideStatus.inProgress
                                        ? Colors.white
                                        : null,
                                child: PhosphorIcon(
                                  ride.status == RideStatus.inProgress
                                      ? PhosphorIcons.checkCircle(
                                          PhosphorIconsStyle.fill,
                                        )
                                      : PhosphorIcons.motorcycle(
                                          PhosphorIconsStyle.fill,
                                        ),
                                  size: 16,
                                ),
                              );
                  },
                  steps: [
                    Step(
                      isActive: ride.status == RideStatus.accepted ||
                          ride.status == RideStatus.inProgress,
                      title: const Text('Request'),
                      content: const SizedBox.shrink(),
                    ),
                    Step(
                      isActive: ride.status == RideStatus.inProgress ||
                          allRidersAtMeetingPoint,
                      title: const Text('Meet Up'),
                      content: const SizedBox.shrink(),
                    ),
                    Step(
                      isActive: ride.status == RideStatus.inProgress,
                      title: const Text('Ride'),
                      content: const SizedBox.shrink(),
                    ),
                  ]),
            ),
          ),
        ));
  }
}
