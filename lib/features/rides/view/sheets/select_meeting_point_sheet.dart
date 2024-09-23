import 'package:buoy/features/locate/view/map/main_map.dart';
import 'package:buoy/features/locate/view/sheets/confirm_ride_request_sheet.dart';
import 'package:buoy/features/rides/bloc/ride_bloc.dart';
import 'package:buoy/features/rides/view/sheets/select_meeting_time_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SelectMeetingPointSheet extends StatelessWidget {
  const SelectMeetingPointSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: 0.58,
      initialChildSize: 0.45,
      minChildSize: 0.13,
      builder: (context, controller) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24.0),
              topRight: Radius.circular(24.0),
            ),
          ),
          child: Column(
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
              const SizedBox(
                height: 8.0,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Select Meeting Point',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Select a meeting point on the map',
                            style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: BlocBuilder<RideBloc, RideState>(
                              builder: (context, state) {
                                if (state is RideError) {
                                  return Text(
                                    state.error,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  );
                                }
                                if (state is RideLoading) {
                                  return const SizedBox(
                                      height: 48.0,
                                      child: CircularProgressIndicator());
                                }
                                if (state is RideLoaded ||
                                    state is RideUpdated ||
                                    state is SelectingMeetingPoint ||
                                    state is CreatingRide) {
                                  return Container(
                                    decoration: state.ride?.meetingPoint != null
                                        ? BoxDecoration(
                                            border: Border.all(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              width: 2.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                          )
                                        : BoxDecoration(
                                            border: Border.all(
                                              color: Colors.red,
                                              width: 2.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                          ),
                                    child: ListTile(
                                      style: ListTileStyle.list,
                                      shape: RoundedRectangleBorder(
                                        side: const BorderSide(
                                          color: Colors.red,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(24.0),
                                      ),
                                      title: state.ride?.meetingPoint != null
                                          ? Text(
                                              '${state.ride?.meetingPointAddress ?? state.ride?.meetingPointName}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                            )
                                          : const Text('Location Not Set'),
                                      leading: state.ride?.meetingPoint != null
                                          ? const Icon(
                                              Icons.location_on_rounded)
                                          : const Icon(
                                              Icons.location_off_rounded),
                                    ),
                                  );
                                } else {
                                  return const SizedBox();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8.0),
              BlocBuilder<RideBloc, RideState>(
                builder: (context, state) {
                  if (state is RideError) {
                    return Text(state.error);
                  }
                  if (state is RideLoading) {
                    return const SizedBox(
                        height: 48.0, child: CircularProgressIndicator());
                  }
                  if (state is SelectingMeetingPoint || state is CreatingRide) {
                    return state.meetingPoint != null
                        ? Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: FilledButton.icon(
                              onPressed: () {
                                GoRouter.of(context).pop(null);
                                context.read<RideBloc>().add(SetMeetingPoint());
                                showBottomSheet(
                                    context: context,
                                    builder: (context) =>
                                        const SelectMeetingTimeSheet());
                              },
                              icon: const Icon(Icons.check_rounded),
                              label: const Text('Set Meeting Point'),
                            ),
                          )
                        : const SizedBox();
                  }
                  return const SizedBox(
                    child: Center(
                      child: Text('Something Went Wrong...'),
                    ),
                  );
                },
              )
            ],
          ),
        );
      },
    );
  }
}
