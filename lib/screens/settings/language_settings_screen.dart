import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/locale_provider.dart';
import '../../l10n/app_localizations.dart';

/// Screen for managing language settings
class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.languageSettings),
        backgroundColor: Colors.grey[100],
      ),
      body: localeProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // Current Language Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.defaultLanguage,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.language, color: Colors.grey),
                            const SizedBox(width: 12),
                            Text(
                              localeProvider.getLanguageName(
                                localeProvider.locale.languageCode,
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(),

                // Available Languages Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    l10n.selectLanguage,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Language List
                ...LocaleProvider.supportedLanguages.entries.map((entry) {
                  final languageCode = entry.key;
                  final languageName = entry.value;
                  final isSelected =
                      localeProvider.locale.languageCode == languageCode;

                  return ListTile(
                    leading: Icon(
                      Icons.language,
                      color: isSelected ? Colors.blue : Colors.grey,
                    ),
                    title: Text(
                      languageName,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected ? Colors.blue : Colors.black,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Colors.blue)
                        : null,
                    onTap: () =>
                        _changeLanguage(context, localeProvider, languageCode),
                  );
                }),

                const SizedBox(height: 16),

                // Information Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue[700]),
                            const SizedBox(width: 8),
                            Text(
                              'Information',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '• Language changes apply immediately\n'
                          '• Your preference is saved to your profile\n'
                          '• Date and number formats adapt to your language\n'
                          '• Currency symbols follow locale conventions',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Supported Languages Count
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      '${LocaleProvider.supportedLanguages.length} languages supported',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  /// Change language with confirmation
  Future<void> _changeLanguage(
    BuildContext context,
    LocaleProvider localeProvider,
    String languageCode,
  ) async {
    if (localeProvider.locale.languageCode == languageCode) {
      return;
    }

    try {
      await localeProvider.setLocale(Locale(languageCode));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).languageChanged),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).error}: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
