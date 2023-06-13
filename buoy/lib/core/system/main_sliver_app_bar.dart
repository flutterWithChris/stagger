import 'package:buoy/locate/view/dialogs/add_friend_dialog.dart';
import 'package:flutter/material.dart';

class MainSliverAppBar extends StatelessWidget {
  const MainSliverAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: Wrap(
        spacing: 12.0,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Image.asset(
            'lib/assets/logo/buoy_logo.png',
            color: Colors.orange[800],
            width: 24,
            height: 24,
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 2.0),
            child: Text('Buoy'),
          )
        ],
      ),
      actions: [
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
