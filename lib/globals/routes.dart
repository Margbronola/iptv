import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:seizhiptv/views/auth/children/playlist.dart';
import 'package:seizhiptv/views/auth/login.dart';
import 'package:seizhiptv/views/landing_page/children/home_children/history.dart';
import 'package:seizhiptv/views/landing_page/children/profile.dart';
import 'package:seizhiptv/views/landing_page/main_landing_page.dart';
import 'package:seizhiptv/views/splashscreen.dart';

class Routes {
  Routes._pr();
  static final Routes _instance = Routes._pr();
  static Routes get instance => _instance;
  static const Duration _transitionDuration = Duration(milliseconds: 500);
  Route<dynamic>? Function(RouteSettings) settings = (RouteSettings settings) {
    switch (settings.name) {
      // case "/search-live-page":
      //   return PageTransition(
      //     child: const SearchLive(),
      //     type: PageTransitionType.rightToLeft,
      //     duration: _transitionDuration,
      //     reverseDuration: _transitionDuration,
      //   );
      // case "/search-movies-page":
      //   return PageTransition(
      //     child: const SearchMovies(),
      //     type: PageTransitionType.rightToLeft,
      //     duration: _transitionDuration,
      //     reverseDuration: _transitionDuration,
      //   );
      // case "/search-series-page":
      //   return PageTransition(
      //     child: const SearchSeries(),
      //     type: PageTransitionType.rightToLeft,
      //     duration: _transitionDuration,
      //     reverseDuration: _transitionDuration,
      //   );
      case "/history-page":
        return PageTransition(
          child: const HistoryPage(),
          type: PageTransitionType.rightToLeft,
          duration: _transitionDuration,
          reverseDuration: _transitionDuration,
        );
      // case "/series-details":
      //   final ClassifiedData data = settings.arguments as ClassifiedData;
      //   return PageTransition(
      //     child: SeriesDetails(
      //       data: data,
      //     ),
      //     type: PageTransitionType.rightToLeft,
      //     duration: _transitionDuration,
      //     reverseDuration: _transitionDuration,
      //   );
      case "/profile-page":
        return PageTransition(
          child: const ProfilePage(),
          type: PageTransitionType.rightToLeft,
          duration: _transitionDuration,
          reverseDuration: _transitionDuration,
        );
      case "/landing-page":
        return PageTransition(
          child: const MainLandingPage(),
          type: PageTransitionType.rightToLeft,
          duration: _transitionDuration,
          reverseDuration: _transitionDuration,
        );
      case "/load-playlist":
        return PageTransition(
          child: PlaylistPage(),
          type: PageTransitionType.rightToLeft,
          duration: _transitionDuration,
          reverseDuration: _transitionDuration,
        );
      case "/auth":
        return PageTransition(
          child: const LoginPage(),
          type: PageTransitionType.rightToLeft,
          duration: _transitionDuration,
          reverseDuration: _transitionDuration,
        );
      default:
        return PageTransition(
          child: const SplashscreenPage(),
          type: PageTransitionType.rightToLeft,
          duration: _transitionDuration,
          reverseDuration: _transitionDuration,
        );
    }
  };
}
