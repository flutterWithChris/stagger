import 'package:buoy/core/system/bottom_nav_bar.dart';
import 'package:buoy/core/system/main_sliver_app_bar.dart';
import 'package:buoy/config/theme/theme_cubit.dart';
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
      body: CustomScrollView(
        slivers: [
          const MainSliverAppBar(),
          SliverFillRemaining(
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
                            SettingsTile.switchTile(
                              initialValue: activityTrackingEnabled,
                              onToggle: (enabled) async {
                                await SharedPreferences.getInstance()
                                    .then((value) {
                                  setState(() {
                                    value.setBool(
                                        'activityTrackingEnabled', enabled);
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
                                            Icons.directions_car_rounded,
                                            color: Colors.white,
                                            size: 20.0,
                                          ),
                                          Text(
                                              'Activity tracking is now ${enabled ? 'enabled' : 'disabled'}'),
                                        ],
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                });
                              },
                              leading: const Icon(Icons.directions_car_rounded),
                              title: const Text('Activity Tracking'),
                              description: const Text(
                                  'Tracks walking, cycling, driving, etc'),
                            ),
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
                                  'Tracks when you\'re moving/still.'),
                            ),
                            // Battery Tracking
                            SettingsTile.switchTile(
                              initialValue: batteryTrackingEnabled,
                              onToggle: (enabled) async {
                                await SharedPreferences.getInstance()
                                    .then((value) {
                                  setState(() {
                                    value.setBool(
                                        'batteryTrackingEnabled', enabled);
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
                                            Icons.battery_full_rounded,
                                            color: Colors.white,
                                            size: 20.0,
                                          ),
                                          Text(
                                              'Battery tracking is now ${enabled ? 'enabled' : 'disabled'}'),
                                        ],
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                });
                              },
                              leading: const Icon(Icons.battery_full_rounded),
                              title: const Text('Battery Tracking'),
                              description:
                                  const Text('Tracks your battery level.'),
                            ),
                            // Tracking Rules
                            // SettingsTile.navigation(
                            //   onPressed: (context) {},
                            //   leading: const Icon(Icons.rule_rounded),
                            //   title: const Text('Tracking Rules'),
                            //   description: const Text(
                            //       'Set rules for when to track your location'),
                            // ),
                            // Geofencing
                            // SettingsTile.navigation(
                            //   onPressed: (context) {},
                            //   leading: const Icon(Icons.location_on_rounded),
                            //   title: const Text('Geofencing'),
                            //   description: const Text(
                            //       'Set safe zones - like home, school, or work.'),
                            // ),
                            // Data Usage Settings
                            // SettingsTile.navigation(
                            //   leading: const Icon(Icons.data_usage_rounded),
                            //   title: const Text('Data Usage'),
                            //   description: const Text(
                            //       'Update location always, only over Wi-Fi, etc'),
                            //   onPressed: (context) {},
                            // ),
                          ],
                        ),
                        SettingsSection(
                          title: const Text('Customization'),
                          tiles: [
                            SettingsTile(
                              title: const Text('Brightness'),
                              trailing: SizedBox(
                                width: 240,
                                child: FittedBox(
                                  child: BlocBuilder<ThemeCubit, ThemeState>(
                                    builder: (context, state) {
                                      return SegmentedButton(
                                          selected:
                                              state.themeMode == ThemeMode.light
                                                  ? {'Light'}
                                                  : state.themeMode ==
                                                          ThemeMode.dark
                                                      ? {'Dark'}
                                                      : {'System'},
                                          onSelectionChanged: (p0) {
                                            if (p0.first == 'Light') {
                                              context
                                                  .read<ThemeCubit>()
                                                  .changeBrightness(
                                                      ThemeMode.light);
                                            } else if (p0.first == 'Dark') {
                                              context
                                                  .read<ThemeCubit>()
                                                  .changeBrightness(
                                                      ThemeMode.dark);
                                            } else if (p0.first == 'System') {
                                              context
                                                  .read<ThemeCubit>()
                                                  .changeBrightness(
                                                      ThemeMode.system);
                                            }
                                          },
                                          segments: const [
                                            ButtonSegment(
                                                value: 'Light',
                                                icon: Icon(
                                                    Icons.wb_sunny_rounded),
                                                label: Text('Light')),
                                            ButtonSegment(
                                                value: 'Dark',
                                                icon: Icon(
                                                    Icons.nightlight_round),
                                                label: Text('Dark')),
                                            ButtonSegment(
                                                value: 'System',
                                                icon: Icon(Icons
                                                    .brightness_auto_rounded),
                                                label: Text('System')),
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
