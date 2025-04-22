// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:seizhiptv/globals/data.dart';
import 'package:seizhiptv/globals/data_cacher.dart';
import 'package:seizhiptv/globals/loader.dart';
import 'package:seizhiptv/globals/logo.dart';
import 'package:seizhiptv/globals/palette.dart';
import 'package:seizhiptv/globals/ui_additional.dart';
import 'package:seizhiptv/m3u/m3u_handler.dart';
import 'package:seizhiptv/m3u/zm3u_handler.dart';
import 'package:seizhiptv/models/source.dart';
import 'package:seizhiptv/views/auth/children/load_playlist.dart';
import 'package:seizhiptv/views/auth/children/load_xtream_code.dart';

class SourceManagementPage extends StatefulWidget {
  const SourceManagementPage({super.key});

  @override
  State<SourceManagementPage> createState() => _SourceManagementPageState();
}

class _SourceManagementPageState extends State<SourceManagementPage> {
  final M3uFirestoreServices _service = M3uFirestoreServices();
  final ZM3UHandler handler = ZM3UHandler.instance;
  final DataCacher _cacher = DataCacher.instance;
  bool isLoading = false;

  Future<void> onSuccess(File? data) async {
    if (data == null) return;
    isLoading = true;
    if (mounted) setState(() {});
    await _cacher.saveFile(data);
    await _cacher.saveDate(DateTime.now().toString());
    print("DATA ON SUCESS: $data");
    await Navigator.pushReplacementNamed(context, "/landing-page");
    isLoading = false;
    if (mounted) setState(() {});
  }

  Widget? label;
  download(M3uSource source) {
    print("DOWNLOADINGGGGG");
    FocusScope.of(context).unfocus();
    setState(() {
      isLoading = true;
      label = Text(
        "Preparing_download".tr(),
        style: const TextStyle(color: Colors.white, fontSize: 16),
      );
    });

    // await downloadFile(
    //   source: source,
    //   filename: "data.m3u",
    // );

    handler
        .network(
          source.source,
          progressCallback: (value) {
            label = RichText(
              text: TextSpan(
                text: 'Downloading'.tr(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: "Poppins",
                ),
                children: [TextSpan(text: " ${value.ceil()}%")],
              ),
            );
            if (mounted) setState(() {});
          },
          onFinished: () {
            isLoading = false;
            if (mounted) setState(() {});
          },
        )
        .then((value) async {
          print("FILE IN DOWNLOAD: $value");
          if (value == null) return;
          _cacher.savePlaylistName(source.name);
          await _cacher.saveUrl(source.source);
          await onSuccess(value);
        })
        .onError((error, stackTrace) {
          _cacher.clearData();
        });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return Scaffold(
      backgroundColor: Colors.grey.shade800,
      body: Container(
        decoration: BoxDecoration(gradient: ColorPalette().gradient),
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 80),
                    Hero(
                      tag: "auth-logo",
                      child: LogoSVG(bottomText: "Manage_Sources".tr()),
                    ),
                    StreamBuilder(
                      stream: _service.getListener(
                        collection: "user-source",
                        docId: refId!,
                      ),
                      builder: (_, snapshot) {
                        if (snapshot.hasError || !snapshot.hasData) {
                          return Container();
                        }
                        if (snapshot.data!.data() == null) return Container();
                        final List<M3uSource> sources =
                            ((snapshot.data!.data() as Map)['sources'] as List)
                                .map((e) => M3uSource.fromFirestore(e))
                                .toList();

                        print("REFID: $refId");
                        print("SOURCE: $sources");
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (_, i) {
                            final M3uSource source = sources[i];
                            return GestureDetector(
                              onTap: () async {
                                print("SOURCE (ONTAP): ${source.source}");
                                if (source.isFile) {
                                  await onSuccess(File(source.source));
                                  await _cacher.savePlaylistName(source.name);
                                } else {
                                  await download(source);
                                  await _cacher.savePlaylistName(source.name);
                                }
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Container(
                                  color: ColorPalette().card,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 5,
                                  ),
                                  child: ListTile(
                                    title: Text(source.name),
                                    trailing: PopupMenuButton<String>(
                                      itemBuilder:
                                          (_) =>
                                              [
                                                    "Load_Source".tr(),
                                                    "Update_source".tr(),
                                                    "Delete_Source".tr(),
                                                  ]
                                                  .map(
                                                    (e) =>
                                                        PopupMenuItem<String>(
                                                          value: e,
                                                          child: Text(e),
                                                        ),
                                                  )
                                                  .toList(),
                                      onSelected: (String? value) async {
                                        if (value == null) return;
                                        print(value);
                                        if (value == "Load_Source".tr()) {
                                          if (source.isFile) {
                                            _cacher.savePlaylistName(
                                              source.name,
                                            );
                                            await onSuccess(
                                              File(source.source),
                                            );
                                          } else {
                                            await download(source);
                                          }
                                        } else if (value ==
                                            "Update_source".tr()) {
                                          print("Update_source".tr());
                                          Navigator.push(
                                            context,
                                            PageTransition(
                                              child: LoadPlaylistPage(
                                                isUpdate: true,
                                                data: source,
                                              ),
                                              type:
                                                  PageTransitionType
                                                      .leftToRight,
                                            ),
                                          );
                                        } else {
                                          await _service.firestore
                                              .collection("user-source")
                                              .doc(refId)
                                              .set({
                                                "sources":
                                                    FieldValue.arrayRemove([
                                                      source.toJson(),
                                                    ]),
                                              });
                                        }
                                      },
                                      offset: const Offset(0, 30),
                                    ),
                                    subtitle: Text(
                                      source.source,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(60),
                                      child:
                                          user == null
                                              ? Image.asset(
                                                "assets/icons/default-picture.jpeg",
                                                height: 40,
                                                width: 40,
                                                fit: BoxFit.cover,
                                              )
                                              : user!.photoUrl == null
                                              ? Image.asset(
                                                "assets/icons/default-picture.jpeg",
                                                height: 40,
                                                width: 40,
                                                fit: BoxFit.cover,
                                              )
                                              : CachedNetworkImage(
                                                imageUrl: user!.photoUrl!,
                                                height: 40,
                                                width: 40,
                                              ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          separatorBuilder:
                              (_, i) => const SizedBox(height: 10),
                          itemCount: sources.length,
                        );
                      },
                    ),
                    const SizedBox(height: 50),
                    UIAdditional().button2(
                      title: 'Load_your_source'.tr(),
                      assetPath: "assets/icons/users.svg",
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          PageTransition(
                            child: const LoadXtreamCodePage(),
                            type: PageTransitionType.rightToLeft,
                          ),
                        );
                      },
                      foregroundColor: Colors.black,
                    ),
                    const SizedBox(height: 10),
                    UIAdditional().button2(
                      title: 'Load_your_m3u'.tr(),
                      assetPath: "assets/icons/folder.svg",
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          PageTransition(
                            child: LoadPlaylistPage(
                              isUpdate: false,
                              data: null,
                            ),
                            type: PageTransitionType.rightToLeft,
                          ),
                        );
                      },
                      foregroundColor: Colors.black,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            if (isLoading) ...{
              Positioned.fill(child: SeizhTvLoader(label: label)),
            },
          ],
        ),
      ),
    );
  }
}
