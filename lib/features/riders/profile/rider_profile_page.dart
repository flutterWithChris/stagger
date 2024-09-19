import 'package:buoy/config/router/router.dart';
import 'package:buoy/core/constants.dart';
import 'package:buoy/core/system/bottom_nav_bar.dart';
import 'package:buoy/core/system/main_sliver_app_bar.dart';
import 'package:buoy/features/block/presentation/bloc/block_records_bloc.dart';
import 'package:buoy/features/friends/bloc/friends_bloc.dart';
import 'package:buoy/features/riders/bloc/rider_profile_bloc.dart';
import 'package:buoy/features/riders/model/rider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class RiderProfilePage extends StatelessWidget {
  final Rider? rider;
  const RiderProfilePage({super.key, this.rider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomNavBar(),
      body: BlocBuilder<RiderProfileBloc, RiderProfileState>(
        builder: (context, state) {
          if (state is RiderProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is RiderProfileError) {
            return Center(child: Text(state.message));
          }
          if (state is RiderProfileLoaded) {
            print('RiderProfileLoaded: ${state.rider}');
            Rider loadedRider = rider ?? state.rider;
            return CustomScrollView(
              slivers: [
                const MainSliverAppBar(),
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        ListTile(
                          leading: CircleAvatar(
                            child: rider!.photoUrl == null
                                ? PhosphorIcon(
                                    PhosphorIcons.motorcycle(
                                        PhosphorIconsStyle.fill),
                                    size: 24,
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(50.0),
                                    child: CachedNetworkImage(
                                      imageUrl: rider!.photoUrl!,
                                      height: 48.0,
                                      width: 48.0,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                          title: Text(loadedRider.firstName ?? 'First Name',
                              style: Theme.of(context).textTheme.titleLarge),
                          trailing: rider!.bike != null
                              ? Row(
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
                                          rider!.bike!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                        ),
                        const GutterSmall(),
                        Wrap(alignment: WrapAlignment.start, children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Experience: ',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      )),
                              const GutterSmall(),
                              Flexible(
                                child: Chip(
                                  visualDensity: VisualDensity.compact,
                                  side: BorderSide.none,
                                  label: Text(
                                    rider!.yearsRiding == 0
                                        ? 'New Rider'
                                        : '${rider!.yearsRiding} Years',
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  backgroundColor: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          const Gutter(),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Gear: ',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      )),
                              const GutterSmall(),
                              Flexible(
                                child: Chip(
                                  visualDensity: VisualDensity.compact,
                                  side: BorderSide.none,
                                  label: Text(
                                    rider!.gearLevel?.name.enumToString() ??
                                        'Gear',
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  backgroundColor: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ]),
                        const GutterSmall(),
                        rider!.ridingStyle != null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Text(
                                      'Riding Style',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    const GutterSmall(),
                                    buildRiderStyleChip(
                                        context, rider!.ridingStyle!)
                                  ])
                            : const SizedBox(),
                        const Gutter(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Preferred Ride Types',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    )),
                            const GutterSmall(),
                            Wrap(
                              spacing: 6,
                              runSpacing: 3,
                              children: [
                                if (rider!.rideTypes != null)
                                  for (var rideType in rider!.rideTypes!)
                                    Chip(
                                      visualDensity: VisualDensity.compact,
                                      label: Text(rideType.name.enumToString()),
                                    ),
                              ],
                            ),
                          ],
                        ),
                        const Gutter(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('I Like Stops At',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    )),
                            const GutterSmall(),
                            Wrap(
                              spacing: 6,
                              runSpacing: 3,
                              children: [
                                if (rider!.rideDestinations != null)
                                  for (var rideDestination
                                      in rider!.rideDestinations!)
                                    Chip(
                                      visualDensity: VisualDensity.compact,
                                      label: Text(
                                          rideDestination.name.enumToString()),
                                    ),
                              ],
                            ),
                          ],
                        ),
                        const GutterLarge(),
                        Row(
                          children: [
                            Expanded(
                              child: BlocConsumer<BlockRecordsBloc,
                                  BlockRecordsState>(
                                listener: (context, state) {
                                  if (state is BlockRecordsError) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(state.message),
                                      ),
                                    );
                                  }
                                  if (state is BlockRecordsUpdated) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      getSuccessSnackbar('Rider blocked'),
                                    );
                                    context.go('/');
                                  }
                                },
                                builder: (context, state) {
                                  print('BlockRecordsBloc: $state');
                                  if (state is BlockRecordsError) {
                                    return FilledButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            WidgetStateProperty.all(Colors.red),
                                      ),
                                      onPressed: () {},
                                      child: const Text('Block Rider',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    );
                                  }
                                  if (state is BlockRecordsLoading) {
                                    return FilledButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            WidgetStateProperty.all(Colors.red),
                                      ),
                                      onPressed: () {},
                                      child: const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: FittedBox(
                                              child:
                                                  CircularProgressIndicator())),
                                    );
                                  }
                                  if (state is BlockRecordsLoaded ||
                                      state is BlockRecordsUpdated) {
                                    if (state.blockRecords != null &&
                                        state.blockRecords!.any((blockRecord) =>
                                            blockRecord.blockedUserId ==
                                            loadedRider.id)) {
                                      return FilledButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStateProperty.all(
                                                  Colors.red),
                                        ),
                                        onPressed: () {
                                          context.read<BlockRecordsBloc>().add(
                                              UnblockUser(loadedRider.id!));
                                        },
                                        child: const Text('Unblock Rider',
                                            style:
                                                TextStyle(color: Colors.white)),
                                      );
                                    }
                                    return FilledButton.icon(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            WidgetStateProperty.all(Colors.red),
                                      ),
                                      icon: PhosphorIcon(
                                        PhosphorIcons.prohibit(),
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      onPressed: () async {
                                        // Show confirmation dialog
                                        await showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title:
                                                    const Text('Block Rider'),
                                                content: const Text(
                                                    'Are you sure you want to block this rider? This user will no longer be able to see your profile, location, or rides & vice versa.'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const Text('Cancel'),
                                                  ),
                                                  FilledButton(
                                                    style: ButtonStyle(
                                                      backgroundColor:
                                                          WidgetStateProperty
                                                              .all(Colors.red),
                                                    ),
                                                    onPressed: () {
                                                      context
                                                          .read<
                                                              BlockRecordsBloc>()
                                                          .add(BlockUser(
                                                              loadedRider.id!));
                                                    },
                                                    child: const Text('Block',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white)),
                                                  ),
                                                ],
                                              );
                                            });
                                        // print(
                                        //     'Blocking rider: ${loadedRider.id}');
                                        // context
                                        //     .read<BlockRecordsBloc>()
                                        //     .add(BlockUser(loadedRider.id!));
                                      },
                                      label: const Text('Block Rider',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    );
                                  } else {
                                    return const Text(
                                        'Something went wrong...');
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          return const Center(child: Text('Something went wrong...'));
        },
      ),
    );
  }
}
