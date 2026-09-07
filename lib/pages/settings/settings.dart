import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_x/pages/settings/model.dart';
import 'package:note_x/pages/settings/provider.dart';
import 'package:note_x/l10n.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n(ref);

    final Color primaryColor = colorScheme.primary;
    final Color textColor = colorScheme.onSurface;
    final Color secondaryTextColor = colorScheme.onSurface.withAlpha(153);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 20,
        title: Row(
          children: [
            Icon(Icons.settings_outlined, color: primaryColor, size: 30),
            const SizedBox(width: 10),
            Text(
              l10n.translate('settings'),
              style: GoogleFonts.nunito(
                color: textColor,
                fontSize: 27,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _showSearchMessage(context),
            icon: Icon(Icons.search_outlined, color: textColor, size: 26),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
        children: [
          _buildHeader(
            l10n.translate('general'),
            l10n.translate('customize_experience'),
            textColor,
            secondaryTextColor,
          ),
          const SizedBox(height: 10),
          _buildSettingsCard(
            context,
            children: [
              _buildSelectionTile(
                context,
                icon: Icons.language_outlined,
                iconColor: const Color(0xff4894b5),
                title: l10n.translate('language'),
                subtitle: l10n.translate(settings.selectedLanguage),
                onTap: () => _showLanguageDialog(
                  context,
                  settings,
                  settingsNotifier,
                  l10n,
                ),
              ),
              _buildDivider(context),
              _buildSelectionTile(
                context,
                icon: Icons.brightness_6_outlined,
                iconColor: const Color(0xff8c7ad5),
                title: l10n.translate('theme'),
                subtitle: l10n.translate(settings.selectedTheme),
                onTap: () =>
                    _showThemeDialog(context, settings, settingsNotifier, l10n),
              ),
            ],
          ),
          const SizedBox(height: 25),
          _buildHeader(
            l10n.translate('notes'),
            l10n.translate('notes_management'),
            textColor,
            secondaryTextColor,
          ),
          const SizedBox(height: 10),
          _buildSettingsCard(
            context,
            children: [
              _buildSwitchTile(
                context,
                icon: Icons.cloud_outlined,
                iconColor: const Color(0xff4894b5),
                title: l10n.translate('sync'),
                subtitle: settings.syncEnabled
                    ? l10n.translate('sync_on')
                    : l10n.translate('sync_off'),
                value: settings.syncEnabled,
                onChanged: (value) => settingsNotifier.toggleSync(value),
              ),
              _buildDivider(context),
              _buildSwitchTile(
                context,
                icon: Icons.save_outlined,
                iconColor: const Color(0xff759b4a),
                title: l10n.translate('auto_save'),
                subtitle: settings.autoSaveEnabled
                    ? l10n.translate('enabled')
                    : l10n.translate('disabled'),
                value: settings.autoSaveEnabled,
                onChanged: (value) => settingsNotifier.toggleAutoSave(value),
              ),
            ],
          ),
          const SizedBox(height: 25),
          _buildHeader(
            l10n.translate('notifications'),
            l10n.translate('notification_settings'),
            textColor,
            secondaryTextColor,
          ),
          const SizedBox(height: 10),
          _buildSettingsCard(
            context,
            children: [
              _buildSwitchTile(
                context,
                icon: Icons.notifications_none_outlined,
                iconColor: const Color(0xffd57a7a),
                title: l10n.translate('notifications'),
                subtitle: settings.notificationsEnabled
                    ? l10n.translate('enabled')
                    : l10n.translate('disabled'),
                value: settings.notificationsEnabled,
                onChanged: (value) =>
                    settingsNotifier.toggleNotifications(value),
              ),
              _buildDivider(context),
              _buildNavigationTile(
                context,
                icon: Icons.alarm_outlined,
                iconColor: const Color(0xfff5b839),
                title: l10n.translate('reminders'),
                subtitle: l10n.translate('reminder_subtitle'),
                onTap: () =>
                    _showComingSoon(context, l10n.translate('reminders')),
              ),
            ],
          ),
          const SizedBox(height: 25),
          _buildHeader(
            l10n.translate('appearance'),
            l10n.translate('appearance_subtitle'),
            textColor,
            secondaryTextColor,
          ),
          const SizedBox(height: 10),
          _buildSettingsCard(
            context,
            children: [
              _buildNavigationTile(
                context,
                icon: Icons.palette_outlined,
                iconColor: const Color(0xff8c7ad5),
                title: l10n.translate('note_colors'),
                subtitle: l10n.translate('note_colors_subtitle'),
                onTap: () => _showNoteColorDialog(context, l10n),
              ),
              _buildDivider(context),
              _buildNavigationTile(
                context,
                icon: Icons.text_fields_outlined,
                iconColor: const Color(0xff4894b5),
                title: l10n.translate('text_size'),
                subtitle: l10n.translate('normal'),
                onTap: () =>
                    _showComingSoon(context, l10n.translate('text_size')),
              ),
            ],
          ),
          const SizedBox(height: 25),
          _buildHeader(
            l10n.translate('storage'),
            l10n.translate('storage_subtitle'),
            textColor,
            secondaryTextColor,
          ),
          const SizedBox(height: 10),
          _buildSettingsCard(
            context,
            children: [
              _buildNavigationTile(
                context,
                icon: Icons.storage_outlined,
                iconColor: const Color(0xff759b4a),
                title: l10n.translate('storage'),
                subtitle: l10n.translate('storage_desc'),
                onTap: () => _showStorageDialog(context, l10n),
              ),
              _buildDivider(context),
              _buildNavigationTile(
                context,
                icon: Icons.delete_sweep_outlined,
                iconColor: const Color(0xffd57a7a),
                title: l10n.translate('trash'),
                subtitle: l10n.translate('permanently_delete_notes'),
                onTap: () => _showEmptyTrashDialog(context, l10n),
              ),
            ],
          ),
          const SizedBox(height: 25),
          _buildHeader(
            l10n.translate('about'),
            l10n.translate('about_noteX_subtitle'),
            textColor,
            secondaryTextColor,
          ),
          const SizedBox(height: 10),
          _buildSettingsCard(
            context,
            children: [
              _buildNavigationTile(
                context,
                icon: Icons.info_outline,
                iconColor: const Color(0xff4894b5),
                title: l10n.translate('about_noteX'),
                subtitle: '${l10n.translate('version')} 1.0.0',
                onTap: () => _showAboutDialog(context, primaryColor, l10n),
              ),
              _buildDivider(context),
              _buildNavigationTile(
                context,
                icon: Icons.help_outline,
                iconColor: const Color(0xfff5b839),
                title: l10n.translate('help'),
                subtitle: l10n.translate('questions_information'),
                onTap: () => _showComingSoon(context, l10n.translate('help')),
              ),
              _buildDivider(context),
              _buildNavigationTile(
                context,
                icon: Icons.privacy_tip_outlined,
                iconColor: const Color(0xff8c7ad5),
                title: l10n.translate('privacy'),
                subtitle: l10n.translate('privacy_subtitle'),
                onTap: () =>
                    _showComingSoon(context, l10n.translate('privacy')),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Center(
            child: Column(
              children: [
                Text(
                  'noteX',
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  l10n.translate('slogan'),
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${l10n.translate('version')} 1.0.0',
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    String title,
    String subtitle,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.nunito(fontSize: 12, color: secondaryTextColor),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required List<Widget> children,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.onSurface.withAlpha(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSelectionTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final secondaryTextColor = textColor.withAlpha(153);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            _buildIconContainer(icon: icon, color: iconColor),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: textColor.withAlpha(97)),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = colorScheme.onSurface;
    final secondaryTextColor = textColor.withAlpha(153);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        children: [
          _buildIconContainer(icon: icon, color: iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: colorScheme.primary,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: textColor.withAlpha(30),
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final secondaryTextColor = textColor.withAlpha(153);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            _buildIconContainer(icon: icon, color: iconColor),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: textColor.withAlpha(97)),
          ],
        ),
      ),
    );
  }

  Widget _buildIconContainer({required IconData icon, required Color color}) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withAlpha(28),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      indent: 72,
      endIndent: 16,
      color: Theme.of(context).colorScheme.onSurface.withAlpha(25),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    SettingsState settings,
    SettingsNotifier notifier,
    L10n l10n,
  ) {
    final languages = [
      l10n.translate('system'),
      'Français',
      'English',
      'Español',
      'Português',
      'Русский',
      '中文',
      'Deutsch',
      'Italiano',
    ];
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return _buildChoiceSheet(
          context,
          title: l10n.translate('language'),
          choices: languages,
          selectedValue: settings.selectedLanguage,
          onSelected: (value) {
            notifier.updateLanguage(value);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _showThemeDialog(
    BuildContext context,
    SettingsState settings,
    SettingsNotifier notifier,
    L10n l10n,
  ) {
    final themes = [l10n.translate('system'), l10n.translate('light'), l10n.translate('dark')];
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return _buildChoiceSheet(
          context,
          title: l10n.translate('theme'),
          choices: themes,
          selectedValue: settings.selectedTheme,
          onSelected: (value) {
            notifier.updateTheme(l10n.translate(l10n.getKeyOf(value), targetlanguage: 'en'));
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Widget _buildChoiceSheet(
    BuildContext context, {
    required String title,
    required List<String> choices,
    required String selectedValue,
    required ValueChanged<String> onSelected,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = colorScheme.onSurface;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.nunito(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            ...choices.map((choice) {
              final selected = choice == selectedValue;
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                title: Text(
                  choice,
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: textColor,
                  ),
                ),
                trailing: selected
                    ? Icon(Icons.check_circle, color: colorScheme.primary)
                    : Icon(
                        Icons.radio_button_unchecked,
                        color: textColor.withAlpha(66),
                      ),
                onTap: () => onSelected(choice),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showNoteColorDialog(BuildContext context, L10n l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = colorScheme.onSurface;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final colors = [
      {
        'name': 'Jaune',
        'color': isDark ? const Color(0xFF2D2A20) : const Color(0xfffdf8ec),
      },
      {
        'name': 'Vert',
        'color': isDark ? const Color(0xFF252D20) : const Color(0xfff2f8ec),
      },
      {
        'name': 'Bleu',
        'color': isDark ? const Color(0xFF202A2D) : const Color(0xffedf5f8),
      },
      {
        'name': 'Rose',
        'color': isDark ? const Color(0xFF2D2020) : const Color(0xfff8eded),
      },
      {
        'name': 'Violet',
        'color': isDark ? const Color(0xFF25202D) : const Color(0xfff3edf8),
      },
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.translate('note_colors'),
                  style: GoogleFonts.nunito(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 18),
                ...colors.map((item) {
                  final color = item['color'] as Color;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Text(
                      item['name'] as String,
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Couleur ${item['name']} sélectionnée.',
                          ),
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showStorageDialog(BuildContext context, L10n l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = colorScheme.onSurface;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            l10n.translate('storage'),
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          content: Text(
            l10n.translate('storage_desc'),
            style: GoogleFonts.nunito(color: textColor.withAlpha(153)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.translate('close')),
            ),
          ],
        );
      },
    );
  }

  void _showEmptyTrashDialog(BuildContext context, L10n l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = colorScheme.onSurface;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            l10n.translate('empty_trash_q'),
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          content: Text(
            l10n.translate('empty_trash_desc'),
            style: GoogleFonts.nunito(color: textColor.withAlpha(153)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.translate('cancel')),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.translate('trash_emptied'))),
                );
              },
              child: Text(
                l10n.translate('delete'),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context, Color primaryColor, L10n l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = colorScheme.onSurface;

    showAboutDialog(
      context: context,
      applicationName: 'noteX',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          color: primaryColor.withAlpha(30),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.edit_note, color: primaryColor, size: 32),
      ),
      applicationLegalese:
          'Une application de prise de notes simple et moderne.',
      children: [
        const SizedBox(height: 15),
        Text(
          'Créée with Flutter.',
          style: GoogleFonts.nunito(color: textColor),
        ),
      ],
    );
  }

  void _showSearchMessage(BuildContext context) {
    showSearch(context: context, delegate: SettingsSearchDelegate());
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature sera disponible prochainement.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class SettingsSearchDelegate extends SearchDelegate<String> {
  final settings = [
    'Langue',
    'Thème',
    'Synchronisation des notes',
    'Enregistrement automatique',
    'Notifications',
    'Rappels',
    'Couleur des notes',
    'Taille du texte',
    'Stockage',
    'Vider la corbeille',
    'À propos de noteX',
    'Aide',
    'Confidentialité',
  ];

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(onPressed: () => query = '', icon: const Icon(Icons.clear)),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, ''),
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildResults(context);
  }

  Widget _buildResults(BuildContext context) {
    final results = settings
        .where((setting) => setting.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.settings_outlined),
          title: Text(
            results[index],
            style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
          ),
          onTap: () => close(context, results[index]),
        );
      },
    );
  }
}
