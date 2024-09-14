import 'package:buoy/features/rides/bloc/ride_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ConfirmRideRequestSheet extends StatelessWidget {
  const ConfirmRideRequestSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: 0.58,
      initialChildSize: 0.43,
      minChildSize: 0.13,
      builder: (context, controller) {
        return BlocConsumer<RideBloc, RideState>(
          listener: (context, state) {
            if (state is RideError) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Error sending ride request!'),
                  duration: Duration(seconds: 3),
                ),
              );
            }
            if (state is RideRequestSent) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ride Request Sent!'),
                  duration: Duration(seconds: 3),
                ),
              );
              context.pop();
            }
          },
          builder: (context, state) {
            if (state is RideLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is RideError) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Center(
                    child: Text('Error sending ride request!'),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<RideBloc>().add(SendRideRequest(
                          context.read<RideBloc>().state.ride!));
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry'),
                  ),
                ],
              );
            }
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
                              'Confirm Details',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        // const SizedBox(height: 8.0),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: [
                        //     Text('Send a ride request to this rider?',
                        //         style: Theme.of(context).textTheme.bodyMedium),
                        //   ],
                        // ),
                        const SizedBox(height: 16.0),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(16.0),
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
                                    title: Text(
                                      'Meet at: ${context.read<RideBloc>().state.ride!.meetingPointAddress}',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    leading:
                                        const Icon(Icons.location_on_rounded),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: FilledButton.icon(
                      onPressed: () {
                        context.read<RideBloc>().add(SendRideRequest(
                            context.read<RideBloc>().state.ride!));
                      },
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Create Ride'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
