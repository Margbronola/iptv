// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:seizhiptv/globals/logo.dart';
import 'package:seizhiptv/globals/palette.dart';
import 'package:seizhiptv/models/source.dart';
import 'package:seizhiptv/views/auth/children/playlist.dart';

class LoadPlaylistPage extends StatefulWidget {
  LoadPlaylistPage({super.key, required this.isUpdate, this.data});

  final bool isUpdate;
  M3uSource? data;

  @override
  State<LoadPlaylistPage> createState() => _LoadPlaylistPageState();
}

class _LoadPlaylistPageState extends State<LoadPlaylistPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // refId = await getUniqueID();
      // await _cacher.saveRefID(refId!);
      if (mounted) setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.grey.shade800,
        body:
        // refId == null
        //     ? const SeizhTvLoader(hasBackgroundColor: false)
        //     :
        Container(
          decoration: BoxDecoration(gradient: ColorPalette().gradient),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const SizedBox(height: 50),
              Hero(
                tag: "auth-logo",
                child: Center(child: LogoSVG(bottomText: 'Load_your_m3u'.tr())),
              ),
              PlaylistPage(isUpdate: widget.isUpdate, data: widget.data),
              MaterialButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                height: 50,
                color: Colors.white,
                child: Center(
                  child: Text(
                    "Cancel".tr(),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
