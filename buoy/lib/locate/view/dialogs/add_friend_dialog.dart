import 'package:buoy/friends/bloc/friends_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gutter/flutter_gutter.dart';

class AddFriendDialog extends StatelessWidget {
  const AddFriendDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const GutterSmall(),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12.0,
              children: [
                const Icon(
                  Icons.person_add_alt_1_rounded,
                  size: 24.0,
                ),
                Text(
                  'Add a Friend',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
            const GutterSmall(),
            const Text('Enter an email to add a friend.'),
            const Gutter(),
            TextField(
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Enter an email...',
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    width: 1.0,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(12.0),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      width: 1.0,
                    ),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(12.0),
                    )),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    width: 1.0,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(12.0),
                  ),
                ),
              ),
            ),
            const Gutter(),
            BlocBuilder<FriendsBloc, FriendsState>(
              builder: (context, state) {
                if (state is FriendsLoading) {
                  return FilledButton.tonalIcon(
                      onPressed: () {},
                      icon: const Icon(Icons.person_add_alt_1_rounded),
                      label: const Text('Sending...'));
                }
                if (state is FriendsError) {
                  return FilledButton.tonalIcon(
                    onPressed: () {},
                    icon: const Icon(Icons.person_add_alt_1_rounded),
                    label: const Text('Error'),
                  );
                }
                if (state is FriendsLoaded) {
                  return FilledButton.tonalIcon(
                    onPressed: () {},
                    icon: const Icon(Icons.person_add_alt_1_rounded),
                    label: const Text('Add Friend'),
                  );
                } else {
                  return const Center(
                    child: Text('Something Went Wrong...'),
                  );
                }
              },
            ),
            const GutterSmall(),
          ],
        ),
      ),
    );
  }
}
