import 'package:buoy/locate/view/map/main_map.dart';
import 'package:buoy/rides/bloc/ride_bloc.dart';
import 'package:buoy/rides/model/ride.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class RidePrivacySheet extends StatefulWidget {
  const RidePrivacySheet({super.key});

  @override
  State<RidePrivacySheet> createState() => _RidePrivacySheetState();
}

class _RidePrivacySheetState extends State<RidePrivacySheet> {
  RidePrivacy selectedPrivacy = RidePrivacy.public;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RideBloc, RideState>(
      builder: (context, state) {
        selectedPrivacy = state.ride!.privacy!;
        return DraggableScrollableSheet(
          expand: false,
          maxChildSize: 0.58,
          initialChildSize: 0.5,
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
                              'Set Ride Privacy',
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
                                    child: InkWell(
                                      onTap: () {},
                                      child: ListTile(
                                        style: ListTileStyle.list,
                                        shape: RoundedRectangleBorder(
                                          side: selectedPrivacy ==
                                                  RidePrivacy.public
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
                                        title: const Text('Public'),
                                        subtitle: const Text(
                                            'Displayed on map. Riders can request to join.'),
                                        leading: CircleAvatar(
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .primaryContainer,
                                            child: Icon(
                                                PhosphorIcons.usersThree())),
                                        onTap: () {
                                          // Show search bar
                                          context.read<RideBloc>().add(
                                              UpdateRideDraft(state.ride!
                                                  .copyWith(
                                                      privacy:
                                                          RidePrivacy.public)));
                                        },
                                      ),
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
                                child: Material(
                                  type: MaterialType.card,
                                  elevation: 1.618,
                                  borderRadius: BorderRadius.circular(16.0),
                                  child: InkWell(
                                    onTap: () {
                                      print('Tapped Invite Only');
                                    },
                                    child: ListTile(
                                      style: ListTileStyle.list,
                                      shape: RoundedRectangleBorder(
                                        side: selectedPrivacy ==
                                                RidePrivacy.private
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
                                          const Text('Invite Only'),
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
                                                        style: Theme.of(context)
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
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50.0),
                                                  ),
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .tertiaryContainer),
                                            ),
                                          ),
                                        ],
                                      ),
                                      subtitle: const Text(
                                          'Only riders you invite can see & join your ride.'),
                                      leading: CircleAvatar(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .tertiaryContainer,
                                        child: Icon(
                                            PhosphorIcons.envelopeSimple(
                                                PhosphorIconsStyle.duotone)),
                                      ),
                                      onTap: () {
                                        context.read<RideBloc>().add(
                                            UpdateRideDraft(state.ride!
                                                .copyWith(
                                                    privacy:
                                                        RidePrivacy.private)));
                                      },
                                    ),
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
                        context.pop();
                        showBottomSheet(
                            context: context,
                            builder: (context) =>
                                const SelectMeetingPointSheet());
                      },
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Set Privacy'),
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
