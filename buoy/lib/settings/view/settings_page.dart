import 'package:buoy/core/system/bottom_nav_bar.dart';
import 'package:buoy/core/system/main_sliver_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings_ui/settings_ui.dart';

import '../../profile/repository/bloc/profile_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavBar(),
      body: CustomScrollView(
        slivers: [
          MainSliverAppBar(),
          SliverFillRemaining(
            child: SettingsList(
              lightTheme: SettingsThemeData(
                settingsListBackground:
                    Theme.of(context).scaffoldBackgroundColor,
              ),
              darkTheme: SettingsThemeData(
                settingsListBackground:
                    Theme.of(context).scaffoldBackgroundColor,
              ),
              sections: [
                SettingsSection(
                  title: Text('Location Settings'),
                  tiles: [
                    SettingsTile.switchTile(
                      initialValue: true,
                      onToggle: (enabled) {},
                      leading: Icon(Icons.directions_car_rounded),
                      title: Text('Activity Tracking'),
                      description:
                          Text('Tracks walking, cycling, driving, etc'),
                    ),
                    // Motion Tracking
                    SettingsTile.switchTile(
                      initialValue: true,
                      onToggle: (enabled) {},
                      leading: Icon(Icons.directions_walk_rounded),
                      title: Text('Motion Tracking'),
                      description: Text('Tracks when you\'re moving/still.'),
                    ),
                    // Battery Tracking
                    SettingsTile.switchTile(
                      initialValue: true,
                      onToggle: (enabled) {},
                      leading: Icon(Icons.battery_full_rounded),
                      title: Text('Battery Tracking'),
                      description: Text('Tracks your battery level.'),
                    ),
                    // Tracking Rules
                    SettingsTile.navigation(
                      onPressed: (context) {},
                      leading: Icon(Icons.rule_rounded),
                      title: Text('Tracking Rules'),
                      description:
                          Text('Set rules for when to track your location'),
                    ),
                    // Geofencing
                    SettingsTile.navigation(
                      onPressed: (context) {},
                      leading: Icon(Icons.location_on_rounded),
                      title: Text('Geofencing'),
                      description:
                          Text('Set safe zones - like home, school, or work.'),
                    ),
                    // Data Usage Settings
                    SettingsTile.navigation(
                      leading: Icon(Icons.data_usage_rounded),
                      title: Text('Data Usage'),
                      description:
                          Text('Update location always, only over Wi-Fi, etc'),
                      onPressed: (context) {},
                    ),
                  ],
                ),
                // Account Settings
                SettingsSection(
                  title: Text('Account Settings'),
                  tiles: [
                    // SettingsTile(
                    //   leading: Icon(Icons.email_rounded),
                    //   title: Text('Email'),
                    //   description:
                    //       Text(context.watch<ProfileBloc>().state.user!.email!),
                    //   onPressed: (context) {},
                    // ),
                    SettingsTile(
                      leading: Icon(Icons.notifications_rounded),
                      title: Text('Notifications'),
                      onPressed: (context) {},
                    ),
                    SettingsTile(
                      leading: Icon(Icons.privacy_tip_rounded),
                      title: Text('Privacy'),
                      onPressed: (context) {},
                    ),
                    SettingsTile(
                      leading: Icon(Icons.security_rounded),
                      title: Text('Security'),
                      onPressed: (context) {},
                    ),
                    SettingsTile(
                      leading: Icon(Icons.language_rounded),
                      title: Text('Language'),
                      onPressed: (context) {},
                    ),
                    SettingsTile(
                      leading: Icon(Icons.help_rounded),
                      title: Text('Help'),
                      onPressed: (context) {},
                    ),
                    SettingsTile(
                      leading: Icon(Icons.info_rounded),
                      title: Text('About'),
                      onPressed: (context) {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
