import 'package:buoy/core/system/bottom_nav_bar.dart';
import 'package:buoy/core/system/main_sliver_app_bar.dart';
import 'package:buoy/config/theme/theme_cubit.dart';
import 'package:buoy/features/locate/view/home.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/presentation/bloc/auth_bloc.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    Future<List<bool>> checkTrackingSettings() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final bool activityTrackingEnabled =
          prefs.getBool('activityTrackingEnabled') ?? true;
      final bool motionTrackingEnabled =
          prefs.getBool('motionTrackingEnabled') ?? true;
      final bool batteryTrackingEnabled =
          prefs.getBool('batteryTrackingEnabled') ?? true;
      return [
        activityTrackingEnabled,
        motionTrackingEnabled,
        batteryTrackingEnabled
      ];
    }

    return Scaffold(
      bottomNavigationBar: const BottomNavBar(),
      appBar: const PreferredSize(
          preferredSize: Size.fromHeight(80), child: NonSliverAppBar()),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<bool>>(
                future: checkTrackingSettings(),
                builder: (context, snapshot) {
                  var data = snapshot.data;
                  if (data == null) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    bool activityTrackingEnabled = data[0];
                    bool motionTrackingEnabled = data[1];
                    bool batteryTrackingEnabled = data[2];
                    return SettingsList(
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
                          title: const Text('Location Settings'),
                          tiles: [
                            // Motion Tracking
                            SettingsTile.switchTile(
                              initialValue: motionTrackingEnabled,
                              onToggle: (enabled) async {
                                await SharedPreferences.getInstance()
                                    .then((value) {
                                  setState(() {
                                    value.setBool(
                                        'motionTrackingEnabled', enabled);
                                  });
                                  return value;
                                }).then((value) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Wrap(
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        spacing: 6.0,
                                        children: [
                                          const Icon(
                                            Icons.directions_walk_rounded,
                                            color: Colors.white,
                                            size: 20.0,
                                          ),
                                          Text(
                                              'Motion tracking is now ${enabled ? 'enabled' : 'disabled'}'),
                                        ],
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                });
                              },
                              leading:
                                  const Icon(Icons.directions_walk_rounded),
                              title: const Text('Motion Tracking'),
                              description: const Text(
                                  'When the plugin detects the device is not moving, it will enter the stationary state, '),
                            ),

                            // Tracking Rules
                            // SettingsTile.navigation(
                            //   onPressed: (context) {},
                            //   leading: const Icon(Icons.rule_rounded),
                            //   title: const Text('Tracking Rules'),
                            //   description: const Text(
                            //       'Set rules for when to track your location'),
                            // ),
                            //   Geofencing']
                            // Check if debug mode
                            // TODO: Implement Geofencing
                            if (!kReleaseMode)
                              SettingsTile.navigation(
                                onPressed: (context) {},
                                leading: const Icon(Icons.location_on_rounded),
                                title: const Text('Geofencing'),
                                description: const Text(
                                    'Set safe zones - like home, school, or work. Your location will be hidden when you are in these zones.'),
                              ),
                          ],
                        ),
                        SettingsSection(
                          title: const Text('Customization'),
                          tiles: [
                            SettingsTile(
                              title: const Text('Brightness'),
                              trailing: SizedBox(
                                width: 180,
                                child: FittedBox(
                                  child: BlocBuilder<ThemeCubit, ThemeState>(
                                    builder: (context, state) {
                                      return DropdownMenu(
                                          leadingIcon: state.themeMode ==
                                                  ThemeMode.light
                                              ? const Icon(
                                                  Icons.wb_sunny_rounded)
                                              : state.themeMode ==
                                                      ThemeMode.dark
                                                  ? const Icon(
                                                      Icons.nightlight_round)
                                                  : const Icon(Icons
                                                      .brightness_auto_rounded),
                                          initialSelection:
                                              state.themeMode == ThemeMode.light
                                                  ? 'Light'
                                                  : state.themeMode ==
                                                          ThemeMode.dark
                                                      ? 'Dark'
                                                      : 'System',
                                          onSelected: (p0) {
                                            if (p0 == 'Light') {
                                              context
                                                  .read<ThemeCubit>()
                                                  .changeBrightness(
                                                      ThemeMode.light);
                                            } else if (p0 == 'Dark') {
                                              context
                                                  .read<ThemeCubit>()
                                                  .changeBrightness(
                                                      ThemeMode.dark);
                                            } else if (p0 == 'System') {
                                              context
                                                  .read<ThemeCubit>()
                                                  .changeBrightness(
                                                      ThemeMode.system);
                                            }
                                          },
                                          dropdownMenuEntries: const [
                                            DropdownMenuEntry(
                                                value: 'Light',
                                                leadingIcon: Icon(
                                                    Icons.wb_sunny_rounded),
                                                label: 'Light'),
                                            DropdownMenuEntry(
                                                value: 'Dark',
                                                leadingIcon: Icon(
                                                    Icons.nightlight_round),
                                                label: 'Dark'),
                                            DropdownMenuEntry(
                                                value: 'System',
                                                leadingIcon: Icon(Icons
                                                    .brightness_auto_rounded),
                                                label: 'System'),
                                          ]);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Account Settings
                        SettingsSection(
                          title: const Text('Account Settings'),
                          tiles: [
                            // SettingsTile(
                            //   leading: Icon(Icons.email_rounded),
                            //   title: Text('Email'),
                            //   description:
                            //       Text(context.watch<ProfileBloc>().state.user!.email!),
                            //   onPressed: (context) {},
                            // ),
                            // SettingsTile(
                            //   leading: const Icon(Icons.notifications_rounded),
                            //   title: const Text('Notifications'),
                            //   onPressed: (context) {},
                            // ),
                            // SettingsTile(
                            //   leading: const Icon(Icons.privacy_tip_rounded),
                            //   title: const Text('Privacy'),
                            //   onPressed: (context) {},
                            // ),
                            // SettingsTile(
                            //   leading: const Icon(Icons.security_rounded),
                            //   title: const Text('Security'),
                            //   onPressed: (context) {},
                            // ),
                            // SettingsTile(
                            //   leading: const Icon(Icons.language_rounded),
                            //   title: const Text('Language'),
                            //   onPressed: (context) {},
                            // ),
                            // SettingsTile(
                            //   leading: const Icon(Icons.help_rounded),
                            //   title: const Text('Help'),
                            //   onPressed: (context) {},
                            // ),
                            // SettingsTile(
                            //   leading: const Icon(Icons.info_rounded),
                            //   title: const Text('About'),
                            //   onPressed: (context) {},
                            // ),
                            SettingsTile(
                                title: const Text('Sign Out'),
                                leading: const Icon(Icons.logout_rounded),
                                onPressed: (context) async {
                                  context
                                      .read<AuthBloc>()
                                      .add(AuthLogoutRequested());
                                }),
                            SettingsTile(
                                leading:
                                    const Icon(Icons.delete_forever_rounded),
                                title: const Text('Delete Account'))
                          ],
                        ),
                      ],
                    );
                  }
                }),
          ),
        ],
      ),
    );
  }
}
