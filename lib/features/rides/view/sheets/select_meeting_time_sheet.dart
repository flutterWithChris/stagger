import 'package:buoy/features/locate/view/sheets/confirm_ride_request_sheet.dart';
import 'package:buoy/features/rides/bloc/ride_bloc.dart';
import 'package:buoy/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:cupertino_calendar_picker/cupertino_calendar_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SelectMeetingTimeSheet extends StatefulWidget {
  const SelectMeetingTimeSheet({super.key});

  @override
  State<SelectMeetingTimeSheet> createState() => _SelectMeetingTimeSheetState();
}

class _SelectMeetingTimeSheetState extends State<SelectMeetingTimeSheet> {
  DateTime? _selectedDate;
  String? _selectedTimeString;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RideBloc, RideState>(
      builder: (context, state) {
        // _selectedDate = context.watch<RideBloc>().state.ride!.meetingTime;
        return DraggableScrollableSheet(
          expand: false,
          maxChildSize: 0.58,
          initialChildSize: 0.55,
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
                              'Set Meeting Time',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
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
                                  child: Material(
                                    elevation: 1.618,
                                    type: MaterialType.card,
                                    borderRadius: BorderRadius.circular(16.0),
                                    child: ListTile(
                                      style: ListTileStyle.list,
                                      shape: RoundedRectangleBorder(
                                        side: _selectedDate == null &&
                                                _selectedTimeString == null
                                            ? BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                width: 2.0,
                                              )
                                            : BorderSide.none,
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                      title: const Text('ASAP'),
                                      subtitle: const Text(
                                          'Ride as soon as possible.'),
                                      leading: CircleAvatar(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .primaryContainer,
                                          child: Icon(
                                            PhosphorIcons.lightning(
                                                PhosphorIconsStyle.fill),
                                            color: Colors.white,
                                          )),
                                      onTap: () {
                                        setState(() {
                                          _selectedDate = null;
                                          _selectedTimeString = null;
                                        });
                                        // Show search bar
                                        context.read<RideBloc>().add(
                                            UpdateRideDraft(state.ride!
                                                .copyWith(meetingTime: null)));
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Gutter(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: BlocConsumer<SubscriptionBloc,
                                    SubscriptionState>(
                                  listener: (context, state) {
                                    // TODO: implement listener
                                  },
                                  builder: (context, subscriptionState) {
                                    if (subscriptionState
                                        is SubscriptionError) {
                                      return const Center(
                                        child:
                                            Text('Error Loading Subscription'),
                                      );
                                    }
                                    if (subscriptionState
                                        is SubscriptionLoading) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    if (subscriptionState
                                            is SubscriptionLoaded ||
                                        subscriptionState
                                            is SubscriptionInitial) {
                                      return Material(
                                        type: MaterialType.card,
                                        elevation: 1.618,
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                        child: ListTile(
                                          style: ListTileStyle.list,
                                          shape: RoundedRectangleBorder(
                                            side: _selectedDate != null
                                                ? BorderSide(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                    width: 2.0,
                                                  )
                                                : BorderSide.none,
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                          ),
                                          title: Row(
                                            children: [
                                              Text(
                                                _selectedDate == null ||
                                                        _selectedTimeString ==
                                                            null
                                                    ? 'Later'
                                                    : 'Meet at ${_selectedTimeString!}',
                                              ),
                                              const Gutter(),
                                              SizedBox(
                                                height: 30,
                                                child: FittedBox(
                                                  child: Chip(
                                                      label: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          const Icon(
                                                            Icons.star_rounded,
                                                            size: 16.0,
                                                          ),
                                                          const GutterSmall(),
                                                          Text(
                                                            'Pro',
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyMedium
                                                                ?.copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                          ),
                                                        ],
                                                      ),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 4.0),
                                                      visualDensity:
                                                          VisualDensity.compact,
                                                      side: BorderSide.none,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50.0),
                                                      ),
                                                      backgroundColor: Theme.of(
                                                              context)
                                                          .colorScheme
                                                          .tertiaryContainer),
                                                ),
                                              ),
                                            ],
                                          ),
                                          subtitle: const Text(
                                              'Schedule a ride for later.'),
                                          leading: CircleAvatar(
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .tertiaryContainer,
                                            child: Icon(
                                              PhosphorIcons.clock(
                                                  PhosphorIconsStyle.fill),
                                              color: Colors.white,
                                            ),
                                          ),
                                          onTap: () async {
                                            if (subscriptionState.customerInfo
                                                        ?.entitlements.active !=
                                                    null &&
                                                subscriptionState
                                                    .customerInfo!
                                                    .entitlements
                                                    .active
                                                    .isNotEmpty) {
                                              await showTimePicker(
                                                context: context,
                                                initialTime: TimeOfDay.now(),
                                              ).then((time) {
                                                if (time != null) {
                                                  print(
                                                      'Minute: ${time.minute}');
                                                  setState(() {
                                                    _selectedDate ??=
                                                        DateTime.now().copyWith(
                                                            hour: time.hour,
                                                            minute:
                                                                time.minute);

                                                    _selectedTimeString = time
                                                                .hour <
                                                            12
                                                        ? _selectedDate!
                                                                    .minute ==
                                                                0
                                                            ? '${time.hour} AM'
                                                            : '${time.hour}:${_selectedDate!.minute} AM'
                                                        : _selectedDate!
                                                                    .minute ==
                                                                0
                                                            ? '${time.hour - 12} PM'
                                                            : '${time.hour - 12}:${_selectedDate!.minute} PM';
                                                  });

                                                  context.read<RideBloc>().add(
                                                        UpdateRideDraft(
                                                          state.ride!.copyWith(
                                                            meetingTime:
                                                                DateTime(
                                                              _selectedDate!
                                                                  .year,
                                                              _selectedDate!
                                                                  .month,
                                                              _selectedDate!
                                                                  .day,
                                                              time.hour,
                                                              time.minute,
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                }
                                              });
                                            } else {
                                              context
                                                  .read<SubscriptionBloc>()
                                                  .add(ShowPaywall());
                                            }
                                          },
                                        ),
                                      );
                                    } else {
                                      return const Center(
                                        child: Text('Something Went Wrong..'),
                                      );
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: FilledButton.icon(
                      onPressed: () {
                        context.pop();
                        showBottomSheet(
                            context: context,
                            builder: (context) =>
                                const ConfirmRideRequestSheet());
                      },
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Set Meeting Time'),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}
