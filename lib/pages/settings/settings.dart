import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const Color primaryColor = Color(0xfff5b839);
  static const Color backgroundColor = Color(0xfffffcf7);
  static const Color textColor = Color(0xff252525);
  static const Color secondaryTextColor = Color(0xff747474);


  String selectedLanguage = 'Système';
  String selectedTheme = 'Système';

  bool syncEnabled = true;
  bool notificationsEnabled = true;
  bool autoSaveEnabled = true;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 20,
        title: Row(
          children: [
            const Icon(
              Icons.settings_outlined,
              color: primaryColor,
              size: 30,
            ),
            const SizedBox(width: 10),
            Text(
              'Paramètres',
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
            onPressed: () {
              _showSearchMessage();
            },
            icon: const Icon(
              Icons.search_outlined,
              color: textColor,
              size: 26,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          16,
          8,
          16,
          30,
        ),
        children: [
          _buildHeader('Général', 'Personnalisez votre expérience noteX',),
          const SizedBox(height: 10),
          _buildSettingsCard(
            children: [
              _buildSelectionTile(
                icon: Icons.language_outlined,
                iconColor: const Color(0xff4894b5),
                title: 'Langue',
                subtitle: selectedLanguage,
                onTap: _showLanguageDialog,
              ),
              _buildDivider(),
              _buildSelectionTile(
                icon: Icons.brightness_6_outlined,
                iconColor: const Color(0xff8c7ad5),
                title: 'Thème',
                subtitle: selectedTheme,
                onTap: _showThemeDialog,
              ),
            ],
          ),
          const SizedBox(height: 25),
          _buildHeader('Notes', 'Gérez le comportement de vos notes',),
          const SizedBox(height: 10),
          _buildSettingsCard(
            children: [
              _buildSwitchTile(
                icon: Icons.cloud_outlined,
                iconColor: const Color(0xff4894b5),
                title: 'Synchronisation des notes',
                subtitle: syncEnabled ? 'Vos notes sont synchronisées' : 'Synchronisation désactivée',
                value: syncEnabled,
                onChanged: (value) {
                  setState(() {
                    syncEnabled = value;
                  });
                },
              ),
              _buildDivider(),
              _buildSwitchTile(
                icon: Icons.save_outlined,
                iconColor: const Color(0xff759b4a),
                title: 'Enregistrement automatique',
                subtitle: autoSaveEnabled ? 'Activé' : 'Désactivé',
                value: autoSaveEnabled,
                onChanged: (value) {
                  setState(() {
                    autoSaveEnabled = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 25),
          _buildHeader('Notifications', 'Choisissez quand noteX peut vous prévenir', ),
          const SizedBox(height: 10),
          _buildSettingsCard(
            children: [
              _buildSwitchTile(
                icon: Icons.notifications_none_outlined,
                iconColor: const Color(0xffd57a7a),
                title: 'Notifications',
                subtitle: notificationsEnabled ? 'Activées' : 'Désactivées',
                value: notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    notificationsEnabled = value;
                  });
                },
              ),
              _buildDivider(),
              _buildNavigationTile(
                icon: Icons.alarm_outlined,
                iconColor: const Color(0xfff5b839),
                title: 'Rappels',
                subtitle: 'Gérer les rappels de notes',
                onTap: () {
                  _showComingSoon('Rappels');
                },
              ),
            ],
          ),
          const SizedBox(height: 25),
          _buildHeader(
              'Apparence',
              'Personnalisez l\'apparence de vos notes',
          ),
          const SizedBox(height: 10),
          _buildSettingsCard(
            children: [
              _buildNavigationTile(
                icon: Icons.palette_outlined,
                iconColor: const Color(0xff8c7ad5),
                title: 'Couleur des notes',
                subtitle: 'Jaune, vert, bleu, violet...',
                onTap: () {
                  _showNoteColorDialog();
                },
              ),
              _buildDivider(),
              _buildNavigationTile(
                icon: Icons.text_fields_outlined,
                iconColor: const Color(0xff4894b5),
                title: 'Taille du texte',
                subtitle: 'Normale',
                onTap: () {
                  _showComingSoon('Taille du texte');
                },
              ),
            ],
          ),
          const SizedBox(height: 25),
          _buildHeader('Stockage', 'Gérez vos données locales',),
          const SizedBox(height: 10),
          _buildSettingsCard(
            children: [
              _buildNavigationTile(
                icon: Icons.storage_outlined,
                iconColor: const Color(0xff759b4a),
                title: 'Stockage',
                subtitle: 'Notes enregistrées localement',
                onTap: () {
                  _showStorageDialog();
                },
              ),
              _buildDivider(),
              _buildNavigationTile(
                icon: Icons.delete_sweep_outlined,
                iconColor: const Color(0xffd57a7a),
                title: 'Vider la corbeille',
                subtitle: 'Supprimer définitivement les notes',
                onTap: _showEmptyTrashDialog,
              ),
            ],
          ),
          const SizedBox(height: 25),
          _buildHeader('À propos', 'Informations sur noteX',),
          const SizedBox(height: 10),
          _buildSettingsCard(
            children: [
              _buildNavigationTile(
                icon: Icons.info_outline,
                iconColor: const Color(0xff4894b5),
                title: 'À propos de noteX',
                subtitle: 'Version 1.0.0',
                onTap: _showAboutDialog,
              ),
              _buildDivider(),
              _buildNavigationTile(
                icon: Icons.help_outline,
                iconColor: const Color(0xfff5b839),
                title: 'Aide',
                subtitle: 'Questions et informations',
                onTap: () {
                  _showComingSoon('Aide');
                },
              ),
              _buildDivider(),
              _buildNavigationTile(
                icon: Icons.privacy_tip_outlined,
                iconColor: const Color(0xff8c7ad5),
                title: 'Confidentialité',
                subtitle: 'Comment noteX utilise vos données',
                onTap: () {
                  _showComingSoon('Confidentialité');
                },
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
                  'Simple. Organisé. À vous.',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Version 1.0.0',
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: Colors.black38,
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
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
      ),
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
            style: GoogleFonts.nunito(
              fontSize: 12,
              color: secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.black.withAlpha(17),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSelectionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        child: Row(
          children: [
            _buildIconContainer(
              icon: icon,
              color: iconColor,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
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
            const Icon(
              Icons.chevron_right,
              color: Colors.black38,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 11,
      ),
      child: Row(
        children: [
          _buildIconContainer(
            icon: icon,
            color: iconColor,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
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
            activeTrackColor: primaryColor,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.black12,
            trackOutlineColor:
            WidgetStateProperty.all(
              Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        child: Row(
          children: [
            _buildIconContainer(
              icon: icon,
              color: iconColor,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
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
            const Icon(
              Icons.chevron_right,
              color: Colors.black38,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconContainer({
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withAlpha(28),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(
        icon,
        color: color,
        size: 22,
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      indent: 72,
      endIndent: 16,
      color: Color(0xffeeeeee),
    );
  }

  void _showLanguageDialog() {
    final languages = [
      'Système',
      'Français',
      'English',
      'Español',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return _buildChoiceSheet(
          title: 'Langue',
          choices: languages,
          selectedValue: selectedLanguage,
          onSelected: (value) {
            setState(() {
              selectedLanguage = value;
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _showThemeDialog() {
    final themes = [
      'Système',
      'Clair',
      'Sombre',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return _buildChoiceSheet(
          title: 'Thème',
          choices: themes,
          selectedValue: selectedTheme,
          onSelected: (value) {
            setState(() {
              selectedTheme = value;
            });

            Navigator.pop(context);
          },
        );
      },
    );
  }

  Widget _buildChoiceSheet({
    required String title,
    required List<String> choices,
    required String selectedValue,
    required ValueChanged<String> onSelected,
  }) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          15,
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
          CrossAxisAlignment.start,
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

            ...choices.map(
                  (choice) {
                final selected =
                    choice == selectedValue;
                return ListTile(
                  contentPadding:
                  const EdgeInsets.symmetric(
                    horizontal: 4,
                  ),
                  title: Text(
                    choice,
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: selected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                  trailing: selected
                      ? const Icon(
                    Icons.check_circle,
                    color: primaryColor,
                  )
                      : const Icon(
                    Icons.radio_button_unchecked,
                    color: Colors.black26,
                  ),
                  onTap: () {
                    onSelected(choice);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNoteColorDialog() {
    final colors = [
      {
        'name': 'Jaune',
        'color': const Color(0xfffdf8ec),
      },
      {
        'name': 'Vert',
        'color': const Color(0xfff2f8ec),
      },
      {
        'name': 'Bleu',
        'color': const Color(0xffedf5f8),
      },
      {
        'name': 'Rose',
        'color': const Color(0xfff8eded),
      },
      {
        'name': 'Violet',
        'color': const Color(0xfff3edf8),
      },
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Couleur des notes',
                  style: GoogleFonts.nunito(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 18),
                ...colors.map(
                      (item) {
                    final color =
                    item['color'] as Color;
                    return ListTile(
                      contentPadding:
                      EdgeInsets.zero,
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
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          SnackBar(
                            content: Text(
                              'Couleur ${item['name']} sélectionnée.',
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showStorageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Stockage',
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'Vos notes sont actuellement enregistrées '
                'localement sur cet appareil.',
            style: GoogleFonts.nunito(
              color: secondaryTextColor,
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text(
                'Fermer',
              ),
            ),
          ],
        );
      },
    );
  }

  
  void _showEmptyTrashDialog() {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Vider la corbeille ?',
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'Toutes les notes présentes dans la corbeille '
                'seront définitivement supprimées.',
            style: GoogleFonts.nunito(
              color: secondaryTextColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Annuler',
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      'La corbeille a été vidée.',
                    ),
                  ),
                );
              },
              child: const Text(
                'Vider',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog() {
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
        child: const Icon(
          Icons.edit_note,
          color: primaryColor,
          size: 32,
        ),
      ),
      applicationLegalese:
      'Une application de prise de notes '
          'simple et moderne.',
      children: [
        const SizedBox(height: 15),
        Text(
          'Créée avec Flutter.',
          style: GoogleFonts.nunito(),
        ),
      ],
    );
  }

  void _showSearchMessage() {
    showSearch(
      context: context,
      delegate: SettingsSearchDelegate(),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$feature sera disponible prochainement.',
        ),
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
        IconButton(
          onPressed: () {
            query = '';
          },
          icon: const Icon(Icons.clear),
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, '');
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildResults();
  }

  Widget _buildResults() {
    final results = settings
        .where(
          (setting) => setting
          .toLowerCase()
          .contains(query.toLowerCase()),
    )
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(
            Icons.settings_outlined,
          ),
          title: Text(
            results[index],
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w600,
            ),
          ),
          onTap: () {
            close(context, results[index]);
          },
        );
      },
    );
  }
}