import 'package:buoy/features/locate/view/map/main_map.dart';
import 'package:buoy/features/locate/view/sheets/confirm_ride_request_sheet.dart';
import 'package:buoy/features/rides/bloc/ride_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SelectMeetingPointSheet extends StatelessWidget {
  const SelectMeetingPointSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RideBloc, RideState>(
      builder: (context, state) {
        return DraggableScrollableSheet(
          expand: false,
          maxChildSize: 0.58,
          initialChildSize: 0.33,
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
                                child: Container(
                                  decoration: state.ride!.meetingPoint != null
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
                                      borderRadius: BorderRadius.circular(24.0),
                                    ),
                                    title: state.ride!.meetingPoint != null
                                        ? Text(
                                            'Destination Set: ${state.ride!.meetingPointAddress ?? state.ride!.meetingPointName}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          )
                                        : const Text('Location Not Set'),
                                    leading: state.ride!.meetingPoint != null
                                        ? const Icon(Icons.location_on_rounded)
                                        : const Icon(
                                            Icons.location_off_rounded),
                                    onTap: () {
                                      // Show search bar
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  state.ride!.meetingPoint != null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              GoRouter.of(context).pop(null);
                              showBottomSheet(
                                  context: context,
                                  builder: (context) =>
                                      const ConfirmRideRequestSheet());
                            },
                            icon: const Icon(Icons.check_rounded),
                            label: const Text('Set Meeting Point'),
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
