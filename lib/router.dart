import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:note_x/pages/home.dart';
import 'package:note_x/pages/favorites.dart';
import 'package:note_x/pages/trash.dart';
import 'package:note_x/pages/settings.dart';
import 'package:note_x/pages/all_notes.dart';
import 'package:note_x/pages/edit_note.dart';
import 'package:note_x/pages/search.dart';
import 'package:note_x/note/model.dart';

final router = GoRouter(
  initialLocation: '/home',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => HomePage(),
        ),
        GoRoute(
          path: '/favorites',
          builder: (context, state) => FavoritesPage(),
        ),
        GoRoute(
          path: '/trash',
          builder: (context, state) => TrashPage()
        )
      ]
    ),

    GoRoute(
      path: '/search',
      builder: (context, state) {
        final notes = state.extra as List<NoteModel>? ?? [];
        return SearchNotePage(notes: notes);
      },
    ),
    GoRoute(
      path: '/note/:id/edit',
      builder: (context, state) {
        final noteId = state.pathParameters['id']!;
        return EditNotePage(noteId: noteId);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => SettingsPage(),
    ),
    GoRoute(
      path: '/all_notes',
      builder: (context, state) => AllNotes(),
    )

  ]
);


class MainScaffold extends StatelessWidget {
  final Widget child;
  

  const MainScaffold({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    int currentPageIndex = 0;
    switch(location){
      case '/home':
        currentPageIndex = 0;
        break;
      case '/favorites':
        currentPageIndex = 1;
        break;
      case '/trash':
        currentPageIndex = 2;
        break;
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: _navBar(currentPageIndex, context)
    );
  }

  Widget _navBar(int currentIndex, BuildContext context) {
  return SafeArea(
    child: SizedBox(
      height: 88,
      child: Center(
        child: Container(
          width: 340,
          height: 68,
          decoration: BoxDecoration(
            color: const Color(0xfffcf6ec),
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: const Color(0xfff7a307),
              unselectedItemColor: const Color(0xff595a5c),
              onTap: (index) {
                switch (index) {
                  case 0:
                    context.go('/home');
                    break;
                  case 1:
                    context.go('/favorites');
                    break;
                  case 2:
                    context.go('/trash');
                    break;
                }
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Accueil',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.star_border_outlined),
                  activeIcon: Icon(Icons.star),
                  label: 'Favoris',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.delete_outline),
                  activeIcon: Icon(Icons.delete),
                  label: 'Corbeille',
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

}