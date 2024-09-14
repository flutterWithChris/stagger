import 'package:buoy/features/locate/bloc/geolocation_bloc.dart';
import 'package:buoy/features/locate/view/dialogs/add_friend_dialog.dart';
import 'package:buoy/shared/presentation/widgets/location_updates_switch.dart';
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
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 16.0),
          child: LocationUpdatesSwitch(),
        )
      ],
    );
  }
}
