import 'package:buoy/features/locate/bloc/geolocation_bloc.dart';
import 'package:buoy/features/locate/view/dialogs/add_friend_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainSliverAppBar extends StatelessWidget {
  const MainSliverAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: Wrap(
        spacing: 16.0,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Image.asset(
            'lib/assets/logo/logo_no_bg.png',
            //  color: Colors.orange[800],
            width: 26,
            height: 26,
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 2.0),
            child: Text('Stagger'),
          )
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(50.0),
              // border: Border.all(color: Colors.white, width: 2.0),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 4.0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    size: 32.0,
                  ),
                  // const SizedBox(width: 8.0),
                  // const Text('Location:'),
                  const SizedBox(width: 8.0),
                  Switch(
                      value: context.watch<GeolocationBloc>().state
                              is GeolocationStopped ==
                          false,
                      onChanged: (value) {
                        if (value == false) {
                          context
                              .read<GeolocationBloc>()
                              .add(StopGeoLocation());
                        } else {
                          context
                              .read<GeolocationBloc>()
                              .add(LoadGeolocation());
                        }
                      }),
                ],
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () async {
            showDialog(
              context: context,
              builder: (context) {
                return const AddFriendDialog();
              },
            );
          },
          icon: const Icon(Icons.person_add_alt_1_rounded),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_vert),
        ),
      ],
    );
  }
}
