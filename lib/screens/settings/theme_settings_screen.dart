import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitly/providers/theme_provider.dart';
import 'package:splitly/utils/design_system.dart';

/// Theme settings screen for dark mode toggle
class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Theme Settings')),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ListView(
            padding: AppSpacing.paddingMD,
            children: [
              // Current Theme Card
              Card(
                child: Padding(
                  padding: AppSpacing.paddingMD,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            themeProvider.isDarkMode
                                ? Icons.dark_mode
                                : Icons.light_mode,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text('Current Theme', style: AppTypography.h4),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        themeProvider.isDarkMode ? 'Dark Mode' : 'Light Mode',
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: AppTypography.fontWeightSemiBold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Theme Options
              Card(
                child: Column(
                  children: [
                    RadioListTile<ThemeMode>(
                      title: const Text('Light Mode'),
                      subtitle: const Text('Use light theme'),
                      secondary: const Icon(Icons.light_mode),
                      value: ThemeMode.light,
                      groupValue: themeProvider.themeMode,
                      onChanged: (value) {
                        if (value != null) {
                          themeProvider.setThemeMode(value);
                        }
                      },
                    ),
                    const Divider(height: 1),
                    RadioListTile<ThemeMode>(
                      title: const Text('Dark Mode'),
                      subtitle: const Text('Use dark theme'),
                      secondary: const Icon(Icons.dark_mode),
                      value: ThemeMode.dark,
                      groupValue: themeProvider.themeMode,
                      onChanged: (value) {
                        if (value != null) {
                          themeProvider.setThemeMode(value);
                        }
                      },
                    ),
                    const Divider(height: 1),
                    RadioListTile<ThemeMode>(
                      title: const Text('System Default'),
                      subtitle: const Text('Follow system theme'),
                      secondary: const Icon(Icons.settings_suggest),
                      value: ThemeMode.system,
                      groupValue: themeProvider.themeMode,
                      onChanged: (value) {
                        if (value != null) {
                          themeProvider.setThemeMode(value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Information Card
              Card(
                color: AppColors.info.withValues(alpha: 0.1),
                child: Padding(
                  padding: AppSpacing.paddingMD,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.info,
                            size: AppConstants.iconSizeMD,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'About Themes',
                            style: AppTypography.bodyLarge.copyWith(
                              fontWeight: AppTypography.fontWeightSemiBold,
                              color: AppColors.info,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Choose your preferred theme for the app. System default will automatically switch between light and dark mode based on your device settings.',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Quick Toggle Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    themeProvider.toggleTheme();
                  },
                  icon: Icon(
                    themeProvider.isDarkMode
                        ? Icons.light_mode
                        : Icons.dark_mode,
                  ),
                  label: Text(
                    themeProvider.isDarkMode
                        ? 'Switch to Light Mode'
                        : 'Switch to Dark Mode',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
