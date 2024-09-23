import 'package:buoy/features/onboarding/presentation/bloc/onboarding_bloc.dart';
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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
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
                if (state is RideLoading || state is RideUpdated) {
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

                  RideParticipant rider = ride.rideParticipants!.firstWhere(
                      (rider) =>
                          rider.userId ==
                          Supabase.instance.client.auth.currentUser!.id);
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
                      RideStepper(
                          ride: ride,
                          allRidersAtMeetingPoint: allRidersAtMeetingPoint,
                          waitingForRiders: waitingForRiders),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (ride.status == RideStatus.meetingUp ||
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
                          // On The Way Button
                          if (ride.status == RideStatus.pending &&
                              !enRoute &&
                              !atMeetingPoint)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: FilledButton.icon(
                                          onPressed: () {
                                            context
                                                .read<RideBloc>()
                                                .add(UpdateArrivalStatus(
                                                  ride: ride,
                                                  userId: supabase
                                                      .auth.currentUser!.id,
                                                  arrivalStatus:
                                                      ArrivalStatus.enRoute,
                                                ));
                                            context.read<RideBloc>().add(
                                                  UpdateRide(
                                                    ride.copyWith(
                                                      status:
                                                          RideStatus.meetingUp,
                                                    ),
                                                  ),
                                                );
                                          },
                                          label: const Text('On The Way'),
                                          icon: PhosphorIcon(
                                            PhosphorIcons.navigationArrow(
                                              PhosphorIconsStyle.fill,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    'Let them know you\'re on the way!',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          // Get Directions Button
                          if (ride.status == RideStatus.meetingUp && enRoute)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: ImHereButton(ride: ride),
                            ),
                          if (atMeetingPoint &&
                              ride.status == RideStatus.meetingUp)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: StartRideButton(ride: ride),
                            ),
                          if (ride.status == RideStatus.meetingUp)
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
                          // Cancel Ride Button
                          const CancelRideButton(),
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
    return BlocListener<RideBloc, RideState>(
      listener: (context, state) {
        if (state is RideCompleted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(getSuccessSnackbar('Finished Ride!'));
          if (context.mounted) {
            context.pop();
          }
        }
        if (state is RideError) {
          ScaffoldMessenger.of(context)
              .showSnackBar(getErrorSnackbar('Error Completing Ride!'));
        }
      },
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
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
            ),
          ),
        ],
      ),
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
        BlocBuilder<RidersBloc, RidersState>(
          builder: (context, state) {
            if (state is RidersError) {
              return const Center(
                child: Text('Error fetching riders!'),
              );
            }
            if (state is RidersLoaded) {
              return ListView.builder(
                shrinkWrap: true,
                itemCount: ride.rideParticipants!.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  RideParticipant rideParticipant =
                      ride.rideParticipants![index];
                  Rider? rider = state.riders.firstWhereOrNull(
                      (rider) => rider.id == rideParticipant.userId);
                  if (rider == null) {
                    return const SizedBox();
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
                      onTap: () {
                        context.read<RiderProfileBloc>().add(LoadRiderProfile(
                              riderId: rider.id,
                              rider: rider,
                            ));
                        context.go('/rider-profile/${rider.id}',
                            extra: rider.copyWith(
                                firstName: rideParticipant.firstName,
                                photoUrl: rideParticipant.photoUrl,
                                lastName: rideParticipant.lastName));
                      },
                      child: Row(
                        children: [
                          CircleAvatar(
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
                          const Gutter(),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
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
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.share_location_rounded,
                                      size: 16),
                                  const SizedBox(width: 4.0),
                                  Text(
                                    switch (rideParticipant.arrivalStatus) {
                                      ArrivalStatus.atMeetingPoint =>
                                        'At Meeting Point',
                                      ArrivalStatus.atDestination =>
                                        'At Destination',
                                      ArrivalStatus.enRoute => 'En Route',
                                      ArrivalStatus.stopped => 'Stopped',
                                      null => 'Unknown',
                                    },
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
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
                          rider.bike != null
                              ? Expanded(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Flexible(
                                        child: Chip(
                                          visualDensity: VisualDensity.compact,
                                          avatar: PhosphorIcon(
                                            PhosphorIcons.motorcycle(
                                              PhosphorIconsStyle.fill,
                                            ),
                                            size: 16,
                                          ),
                                          label: Text(
                                            rider.bike!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox(),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
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
    return BlocConsumer<RideBloc, RideState>(
      listener: (context, state) {
        if (state is RideError) {
          ScaffoldMessenger.of(context).showSnackBar(
            getErrorSnackbar('Error cancelling ride!'),
          );
        }
        if (state is RideCancelled) {
          ScaffoldMessenger.of(context)
              .showSnackBar(getErrorSnackbar('Ride Cancelled!'));
          if (context.mounted) {
            context.pop();
          }
        }
      },
      builder: (context, state) {
        if (state is RideLoading) {
          return TextButton.icon(
            onPressed: () {},
            label: Row(
              children: [
                LoadingAnimationWidget.prograssiveDots(
                  color: Theme.of(context).colorScheme.primary,
                  size: 16,
                ),
                const SizedBox(width: 8.0),
                const Text('Cancelling Ride...'),
              ],
            ),
            icon: PhosphorIcon(
              PhosphorIcons.prohibit(),
              size: 20,
            ),
          );
        }
        return TextButton.icon(
          // style: OutlinedButton.styleFrom(
          //     side: const BorderSide(
          //   color: Colors.red,
          //   width: 2.0,
          // )),
          onPressed: () {
            context
                .read<RideBloc>()
                .add(CancelRide(context.read<RideBloc>().state.ride!));
          },
          icon: PhosphorIcon(
            PhosphorIcons.prohibit(),
            size: 20,
          ),
          label: const Text('Cancel Ride'),
        );
      },
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
                  userId: supabase.auth.currentUser!.id,
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
            RideStatus.meetingUp => PhosphorIcon(
                atMeetingPoint && waitingForRiders
                    ? PhosphorIcons.clock(
                        PhosphorIconsStyle.fill,
                      )
                    : allRidersAtMeetingPoint
                        ? PhosphorIcons.checkCircle(
                            PhosphorIconsStyle.fill,
                          )
                        : Icons.mode_of_travel,
                color: allRidersAtMeetingPoint ? Colors.green[400] : null,
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
                ? 'Waiting For Riders To Join..'
                : ride.status == RideStatus.meetingUp
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
                                            : 'Ride Request Unknown'
                    : 'Ride In Progress',
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: ride.status == RideStatus.meetingUp &&
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
              : ride.status == RideStatus.meetingUp
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
          trailing: ride.status == RideStatus.meetingUp && (enRoute || stopped)
              ? IconButton.filledTonal(
                  onPressed: () {},
                  icon: PhosphorIcon(
                    switch (ride.status) {
                      RideStatus.pending => PhosphorIcons.clock(
                          PhosphorIconsStyle.fill,
                        ),
                      RideStatus.meetingUp => switch (rider.arrivalStatus) {
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
              if (ride.status != RideStatus.meetingUp)
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
                                            allRidersAtMeetingPoint == false
                                        ? Colors.blue
                                        : Colors.transparent,
                                foregroundColor:
                                    ride.status == RideStatus.meetingUp ||
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
                                    ride.status == RideStatus.meetingUp ||
                                            allRidersAtMeetingPoint == true
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
