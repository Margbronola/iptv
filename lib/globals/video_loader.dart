// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:seizhiptv/m3u/m3u_entry.dart';
import 'package:seizhiptv/views/custom_player.dart';

class VideoLoader {
  loadVideo(BuildContext context, M3uEntry data) async {
    await showGeneralDialog(
      context: context,
      transitionDuration: const Duration(milliseconds: 500),
      barrierColor: Colors.black.withOpacity(.5),
      barrierLabel: "",
      barrierDismissible: false,
      transitionBuilder:
          (_, a1, a2, x) => Transform.scale(
            scale: a1.value,
            child: FadeTransition(
              opacity: a1,
              child: Material(
                color: Colors.transparent,
                elevation: 0,
                child: CustomPlayer(
                  link: data.link,
                  id: data.title,
                  name: data.title,
                  image: data.attributes['tvg-logo'] ?? "",
                  popOnError: true,
                ),
              ),
            ),
          ),
      pageBuilder: (_, a1, a2) => Container(),
    );
  }
}
