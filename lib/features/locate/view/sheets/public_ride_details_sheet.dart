import 'package:buoy/features/profile/repository/bloc/profile_bloc.dart';
import 'package:buoy/features/riders/bloc/rider_profile_bloc.dart';
import 'package:buoy/features/riders/bloc/riders_bloc.dart';
import 'package:buoy/features/riders/model/rider.dart';
import 'package:buoy/features/rides/bloc/ride_bloc.dart';
import 'package:buoy/features/rides/bloc/rides_bloc.dart';
import 'package:buoy/features/rides/model/ride.dart';
import 'package:buoy/features/rides/model/ride_participant.dart';
import 'package:buoy/core/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class PublicRideDetailsSheet extends StatelessWidget {
  PublicRideDetailsSheet({
    super.key,
    required this.rideId,
  });

  String rideId;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        initialChildSize: 0.618,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, controller) => BlocConsumer<RideBloc, RideState>(
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
                if (state is RideLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (state is RideError) {
                  return const Center(
                    child: Text('Error'),
                  );
                } else if (state is RideLoaded) {
                  Ride ride = state.ride;

                  print('All Participants: ${ride.rideParticipants?.length}');
                  RideParticipant? rideParticipant = ride.rideParticipants!
                      .firstWhereOrNull((rideParticipant) =>
                          rideParticipant.userId ==
                          Supabase.instance.client.auth.currentUser!.id);
                  bool joinedRide = rideParticipant != null;
                  print(
                      'RideParticipant arrival status: ${rideParticipant?.arrivalStatus}');
                  List<RideParticipant> rideParticipants = ride
                      .rideParticipants!
                      .where((rideParticipant) =>
                          rideParticipant.id !=
                          Supabase.instance.client.auth.currentUser!.id)
                      .toList();
                  bool allRideParticipantsAtMeetingPoint =
                      rideParticipant?.arrivalStatus ==
                              ArrivalStatus.atMeetingPoint &&
                          rideParticipants.every((rideParticipant) =>
                              rideParticipant.arrivalStatus ==
                              ArrivalStatus.atMeetingPoint);
                  bool waitingForRideParticipants =
                      rideParticipant?.arrivalStatus ==
                              ArrivalStatus.atMeetingPoint &&
                          rideParticipants.any((rideParticipant) =>
                              rideParticipant.arrivalStatus ==
                                  ArrivalStatus.stopped ||
                              rideParticipant.arrivalStatus ==
                                  ArrivalStatus.enRoute);
                  bool atMeetingPoint = rideParticipant?.arrivalStatus ==
                      ArrivalStatus.atMeetingPoint;
                  bool atDestination = rideParticipant?.arrivalStatus ==
                      ArrivalStatus.atDestination;
                  bool enRoute =
                      rideParticipant?.arrivalStatus == ArrivalStatus.enRoute;
                  bool stopped =
                      rideParticipant?.arrivalStatus == ArrivalStatus.stopped;

                  return ListView(
                    //  /   physics: const NeverScrollableScrollPhysics(),
                    controller: controller,
                    // mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        height: 8.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 4.0,
                            width: 48.0,
                            decoration: BoxDecoration(
                              color: Theme.of(context).dividerColor,
                              borderRadius: BorderRadius.circular(2.0),
                            ),
                          ),
                        ],
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
                      PublicRideStepper(
                          ride: ride,
                          allRideParticipantsAtMeetingPoint:
                              allRideParticipantsAtMeetingPoint,
                          waitingForRideParticipants:
                              waitingForRideParticipants),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if ((ride.status == RideStatus.meetingUp ||
                                  ride.status == RideStatus.pending) &&
                              allRideParticipantsAtMeetingPoint == false)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: MeetingPointAddressWidget(ride: ride),
                            ),

                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: PublicRideActionCard(
                                ride: ride,
                                atMeetingPoint: atMeetingPoint,
                                waitingForRideParticipants:
                                    waitingForRideParticipants,
                                allRideParticipantsAtMeetingPoint:
                                    allRideParticipantsAtMeetingPoint,
                                enRoute: enRoute,
                                rideParticipant: rideParticipant,
                                stopped: stopped),
                          ),
                          // const SizedBox(height: 8.0),
                          // Get Directions Button
                          if (ride.status == RideStatus.meetingUp && enRoute)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: ImHereButton(ride: ride),
                            ),
                          if ((ride.status == RideStatus.pending) &&
                              joinedRide == false)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: JoinRideButton(ride: ride),
                            ),
                          const SizedBox(height: 8.0),
                          // RideParticipants List
                          if (ride.rideParticipants!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 0.0),
                              child: RideParticipantsList(ride: ride),
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

class JoinRideButton extends StatelessWidget {
  final Ride ride;
  const JoinRideButton({required this.ride, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: BlocConsumer<RideBloc, RideState>(
            listener: (context, state) {
              if (state is JoinedRide) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(getSuccessSnackbar('Joined Ride!'));
              }
              if (state is RideError) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(getErrorSnackbar('Error Joining Ride!'));
              }
            },
            builder: (context, state) {
              if (state is JoinedRide) {
                return const SizedBox();
              }
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
                      const Text('Joining Ride...'),
                    ],
                  ),
                  icon: PhosphorIcon(
                    PhosphorIcons.motorcycle(PhosphorIconsStyle.fill),
                  ),
                );
              }
              if (state is RideError) {
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
                    context.read<RideBloc>().add(JoinRide(ride));
                  },
                  label: const Text('Retry Joining'),
                  icon: PhosphorIcon(
                    PhosphorIcons.repeat(PhosphorIconsStyle.fill),
                  ),
                );
              }
              return FilledButton.icon(
                onPressed: () {
                  context.read<RideBloc>().add(JoinRide(ride));
                },
                label: const Text('Join Ride'),
                icon: PhosphorIcon(
                  PhosphorIcons.motorcycle(PhosphorIconsStyle.fill),
                  size: 20,
                ),
              );
            },
          )
              .animate(
                onComplete: (controller) => controller.repeat(),
              )
              .shimmer(
                  color: Theme.of(context).colorScheme.primary,
                  duration: const Duration(seconds: 6),
                  curve: Curves.easeInOut),
        ),
      ],
    );
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

class RideParticipantsList extends StatelessWidget {
  const RideParticipantsList({
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
          child: Row(
            children: [
              Image.asset(
                'lib/assets/icons/helmet_icon.png',
                height: 20.0,
                width: 20.0,
                color: Theme.of(context).iconTheme.color,
              ),
              const SizedBox(width: 12.0),
              Text(
                'Riders',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8.0),
        BlocBuilder<RidersBloc, RidersState>(
          builder: (context, state) {
            if (state is RidersLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is RidersError) {
              return const Center(
                child: Text('Error'),
              );
            } else if (state is RidersLoaded) {
              print('Riders going into list view: ${state.riders}');
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: ride.rideParticipants!.length,
                itemBuilder: (context, index) {
                  RideParticipant rideParticipant =
                      ride.rideParticipants![index];

                  Rider? rider = state.riders.firstWhereOrNull(
                      (rider) => rider.id == rideParticipant.userId);
                  print('Rider: ${rider.toString()}');

                  if (rider == null) {
                    return const SizedBox.shrink();
                  }

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
                      onTap: () =>
                          context.push('/profile/${rideParticipant.userId}'),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        onTap: () {
                          context
                              .read<RiderProfileBloc>()
                              .add(LoadRiderProfile(rider: rider));
                          context
                              .push('/rider-profile/${rideParticipant.userId}');
                        },
                        leading: CircleAvatar(
                          radius: 24.0,
                          // foregroundImage: rideParticipant.photoUrl != null
                          //     ? CachedNetworkImageProvider(rideParticipant.photoUrl!)
                          //     : null,
                          child: rideParticipant.photoUrl == null
                              ? PhosphorIcon(
                                  PhosphorIcons.personSimple(),
                                  size: 24,
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(50.0),
                                  child: CachedNetworkImage(
                                    imageUrl: rideParticipant.photoUrl!,
                                    height: 48.0,
                                    width: 48.0,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        title: Row(
                          children: [
                            if (rider.id == ride.userId)
                              const Padding(
                                padding: EdgeInsets.only(right: 4.0),
                                child: Icon(Icons.star,
                                    size: 16, color: Colors.yellow),
                              ),
                            Text(
                              rideParticipant.firstName ?? 'N/A',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 16.0),

                            const SizedBox(
                              width: 8.0,
                            ),
                            // if (rider.ridingStyle != null)
                            //   Chip(
                            //     visualDensity: VisualDensity.compact,
                            //     avatar: PhosphorIcon(
                            //       PhosphorIcons.bicycle(
                            //         PhosphorIconsStyle.fill,
                            //       ),
                            //       size: 16,
                            //     ),
                            //     label: Text(
                            //       rider.ridingStyle!.name.enumToString(),
                            //       style: Theme.of(context).textTheme.bodySmall,
                            //     ),
                            //   ),
                          ],
                        ),
                        trailing: rider.bike != null
                            ? Chip(
                                visualDensity: VisualDensity.compact,
                                avatar: PhosphorIcon(
                                  PhosphorIcons.motorcycle(
                                    PhosphorIconsStyle.fill,
                                  ),
                                  size: 16,
                                ),
                                label: Text(
                                  rider.bike!,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              )
                            : null,
                        subtitle: Row(
                          children: [
                            const Icon(Icons.share_location_rounded, size: 16),
                            const SizedBox(width: 4.0),
                            Text(
                              switch (rideParticipant.arrivalStatus) {
                                ArrivalStatus.atMeetingPoint =>
                                  'At Meeting Point',
                                ArrivalStatus.atDestination => 'At Destination',
                                ArrivalStatus.enRoute => 'En Route',
                                ArrivalStatus.stopped => 'Stopped',
                                null => 'Unknown',
                              },
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Center(
                child: Text('Something Went Wrong...'),
              );
            }
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

class PublicRideActionCard extends StatelessWidget {
  const PublicRideActionCard({
    super.key,
    required this.ride,
    required this.atMeetingPoint,
    required this.waitingForRideParticipants,
    required this.allRideParticipantsAtMeetingPoint,
    required this.enRoute,
    required this.rideParticipant,
    required this.stopped,
  });

  final Ride ride;
  final bool atMeetingPoint;
  final bool waitingForRideParticipants;
  final bool allRideParticipantsAtMeetingPoint;
  final bool enRoute;
  final RideParticipant? rideParticipant;
  final bool stopped;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
          leading: switch (ride.status) {
            RideStatus.pending => LoadingAnimationWidget.prograssiveDots(
                color: Theme.of(context).colorScheme.primary, size: 36),
            RideStatus.meetingUp => PhosphorIcon(
                atMeetingPoint && waitingForRideParticipants
                    ? PhosphorIcons.clock(
                        PhosphorIconsStyle.fill,
                      )
                    : allRideParticipantsAtMeetingPoint
                        ? PhosphorIcons.checkCircle(
                            PhosphorIconsStyle.fill,
                          )
                        : PhosphorIcons.mapPinArea(
                            PhosphorIconsStyle.fill,
                          ),
                color: allRideParticipantsAtMeetingPoint
                    ? Colors.green[400]
                    : null,
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
          },
          title: Text(
            ride.status == RideStatus.pending
                ? 'Waiting For Riders..'
                : ride.status == RideStatus.meetingUp
                    ? enRoute
                        ? '${ride.meetingPointAddress}'
                        : atMeetingPoint && waitingForRideParticipants
                            ? 'Wait for riders to arrive...'
                            : atMeetingPoint &&
                                    allRideParticipantsAtMeetingPoint
                                ? 'Waiting for ${ride.rideParticipants?.where((rideParticipant) => rideParticipant.id == ride.userId).first.firstName} to start the ride...'
                                : ride.status == RideStatus.rejected
                                    ? 'Ride Request Rejected'
                                    : ride.status == RideStatus.completed
                                        ? 'Ride Request Completed'
                                        : ride.status == RideStatus.canceled
                                            ? 'Ride Request Canceled'
                                            : 'Ride Request Unknown'
                    : 'Ride In Progress',
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: ride.status == RideStatus.meetingUp &&
                  (rideParticipant?.arrivalStatus == ArrivalStatus.stopped ||
                      rideParticipant?.arrivalStatus == ArrivalStatus.enRoute)
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
              : ride.status == RideStatus.meetingUp
                  ? atMeetingPoint && waitingForRideParticipants
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
                      : null
                  : null,
          trailing: ride.status == RideStatus.meetingUp && (enRoute || stopped)
              ? IconButton.filledTonal(
                  onPressed: () {},
                  icon: PhosphorIcon(
                    switch (ride.status) {
                      RideStatus.pending => PhosphorIcons.clock(
                          PhosphorIconsStyle.fill,
                        ),
                      RideStatus.meetingUp => switch (
                            rideParticipant?.arrivalStatus) {
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
              Expanded(
                child: ListTile(
                  leading: const Stack(
                    alignment: Alignment.center,
                    children: [
                      PhosphorIcon(
                        Icons.mode_of_travel,
                        size: 28,
                      ),
                    ],
                  ),
                  title: const Text(
                    'Meet at',
                  ),
                  subtitle: Text(
                    ride.meetingPointAddress!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: IconButton.filledTonal(
                    onPressed: () {},
                    icon: PhosphorIcon(
                      PhosphorIcons.navigationArrow(
                        PhosphorIconsStyle.fill,
                      ),
                      size: 20,
                    ),
                  ),
                ),
              ),
              // Expanded(
              //   child: Row(
              //     children: [
              //       PhosphorIcon(
              //         PhosphorIcons.mapPinArea(
              //           PhosphorIconsStyle.fill,
              //         ),
              //         size: 20,
              //       ),
              //       const SizedBox(width: 8.0),
              //       Flexible(
              //           child: Text.rich(
              //         TextSpan(
              //           text: 'Meet at: ',
              //           style:
              //               Theme.of(context).textTheme.bodySmall!.copyWith(
              //                     fontWeight: FontWeight.w600,
              //                   ),
              //           children: [
              //             TextSpan(
              //               text: ride.meetingPointAddress,
              //               style: Theme.of(context).textTheme.bodySmall!,
              //             ),
              //           ],
              //         ),
              //         maxLines: 1,
              //         overflow: TextOverflow.ellipsis,
              //       )),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ],
    );
  }
}

class PublicRideStepper extends StatelessWidget {
  const PublicRideStepper({
    super.key,
    required this.ride,
    required this.allRideParticipantsAtMeetingPoint,
    required this.waitingForRideParticipants,
  });

  final Ride ride;
  final bool allRideParticipantsAtMeetingPoint;
  final bool waitingForRideParticipants;

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
                  currentStep: ride.status == RideStatus.meetingUp
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
                                ride.status == RideStatus.meetingUp ||
                                        ride.status == RideStatus.inProgress
                                    ? Colors.white
                                    : null,
                            child: PhosphorIcon(
                              ride.status == RideStatus.meetingUp ||
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
                                    ride.status == RideStatus.meetingUp &&
                                            allRideParticipantsAtMeetingPoint ==
                                                false
                                        ? Colors.blue
                                        : Colors.transparent,
                                foregroundColor:
                                    ride.status == RideStatus.meetingUp ||
                                            ride.status == RideStatus.inProgress
                                        ? Colors.white
                                        : null,
                                child: PhosphorIcon(
                                  ride.status == RideStatus.inProgress ||
                                          allRideParticipantsAtMeetingPoint
                                      ? PhosphorIcons.checkCircle(
                                          PhosphorIconsStyle.fill,
                                        )
                                      : waitingForRideParticipants
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
                                    ride.status == RideStatus.meetingUp ||
                                            allRideParticipantsAtMeetingPoint ==
                                                true
                                        ? Colors.blue
                                        : Colors.transparent,
                                foregroundColor:
                                    ride.status == RideStatus.meetingUp ||
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
                      isActive: ride.status == RideStatus.meetingUp ||
                          ride.status == RideStatus.inProgress,
                      title: const Text('Waiting'),
                      content: const SizedBox.shrink(),
                    ),
                    Step(
                      isActive: ride.status == RideStatus.inProgress ||
                          allRideParticipantsAtMeetingPoint,
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
