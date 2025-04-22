// ignore_for_file: must_be_immutable, avoid_print, deprecated_member_use

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:seizhiptv/data_containers/favorites.dart';
import 'package:seizhiptv/extension/color.dart';
import 'package:seizhiptv/extension/m3u_entry.dart';
import 'package:seizhiptv/globals/data.dart';
import 'package:seizhiptv/globals/favorite_button.dart';
import 'package:seizhiptv/globals/network_image_viewer.dart';
import 'package:seizhiptv/globals/palette.dart';
import 'package:seizhiptv/globals/video_loader.dart';
import 'package:seizhiptv/m3u/m3u_entry.dart';
import 'package:seizhiptv/m3u/zm3u_handler.dart';

class LiveCategoryPage extends StatefulWidget {
  LiveCategoryPage({
    super.key,
    required this.categorydata,
    required this.showsearchfield,
    required this.onUpdateCallback,
  });

  final List<M3uEntry> categorydata;
  late bool showsearchfield;
  final ValueChanged<M3uEntry> onUpdateCallback;

  @override
  State<LiveCategoryPage> createState() => LiveCategoryPageState();
}

class LiveCategoryPageState extends State<LiveCategoryPage> {
  static final Favorites _vm1 = Favorites.instance;
  static final ZM3UHandler _handler = ZM3UHandler.instance;
  final TextEditingController _search = TextEditingController();
  late List<M3uEntry> _displayData = [];
  String searchText = "";

  fetchFav() async {
    await _handler
        .getDataFrom(type: CollectionType.favorites, refId: refId!)
        .then((value) {
          if (value != null) {
            _vm1.populate(value);
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        widget.showsearchfield == true
            ? AnimatedPadding(
              duration: const Duration(milliseconds: 400),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: 50,
                width: double.maxFinite,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: ColorPalette().highlight,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: ColorPalette().highlight
                                  .darken()
                                  .withOpacity(1),
                              offset: const Offset(2, 2),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              "assets/icons/search.svg",
                              height: 20,
                              width: 20,
                              color: ColorPalette().white,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: TextField(
                                  onChanged: (text) {
                                    print("SEARCH TEXT: $text");
                                    if (text.isEmpty) {
                                      _displayData = List.from(
                                        widget.categorydata,
                                      );
                                    } else {
                                      text.isEmpty
                                          ? _displayData = List.from(
                                            widget.categorydata,
                                          )
                                          : _displayData = List.from(
                                            widget.categorydata
                                                .where(
                                                  (element) => element.title
                                                      .toLowerCase()
                                                      .contains(
                                                        text.toLowerCase(),
                                                      ),
                                                )
                                                .toList(),
                                          );
                                    }
                                    if (mounted) setState(() {});
                                    searchText = text;
                                  },
                                  cursorColor: ColorPalette().orange,
                                  controller: _search,
                                  decoration: InputDecoration(
                                    hintText: "Search".tr(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          searchText = "";
                          _search.text = "";
                          widget.showsearchfield = false;
                        });
                      },
                      child: Text(
                        "Cancel".tr(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            )
            : const SizedBox(),
        const SizedBox(height: 10),
        Expanded(
          child:
              searchText != "" && _displayData.isEmpty
                  ? Center(
                    child: Text(
                      "No Result Found for `${_search.text}`",
                      style: TextStyle(color: Colors.white.withOpacity(.5)),
                    ),
                  )
                  : GridView.builder(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: calculateCrossAxisCount(context),
                      childAspectRatio: 1.2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 15,
                    ),
                    itemCount:
                        searchText == ""
                            ? widget.categorydata.length
                            : _displayData.length,
                    itemBuilder: (context, index) {
                      print("DISPLAY DATA LENGHT: ${_displayData.length}");
                      print("DATA LENGHT: ${widget.categorydata.length}");
                      final M3uEntry item =
                          searchText == ""
                              ? widget.categorydata[index]
                              : _displayData[index];

                      return GestureDetector(
                        onTap: () async {
                          print(item.title);
                          item.addToHistory(refId!);
                          await VideoLoader().loadVideo(context, item);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                          child: Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                  top: 10,
                                  right: 10,
                                ),
                                child: LayoutBuilder(
                                  builder: (context, c) {
                                    final double w = c.maxWidth;
                                    final double h = c.maxHeight;
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: NetworkImageViewer(
                                        url: item.attributes['tvg-logo'],
                                        width: w,
                                        height: h,
                                        fit: BoxFit.fitWidth,
                                        color: ColorPalette().highlight,
                                        title: item.title,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: SizedBox(
                                  height: 25,
                                  width: 25,
                                  child: FavoriteIconButton(
                                    onPressedCallback: (bool f) async {
                                      if (f) {
                                        showDialog(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (BuildContext context) {
                                            Future.delayed(
                                              const Duration(seconds: 3),
                                              () {
                                                Navigator.of(context).pop(true);
                                              },
                                            );
                                            return Dialog(
                                              alignment: Alignment.topCenter,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                    ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Added_to_Favorites".tr(),
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    IconButton(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            0,
                                                          ),
                                                      onPressed: () {
                                                        Navigator.of(
                                                          context,
                                                        ).pop();
                                                      },
                                                      icon: const Icon(
                                                        Icons.close_rounded,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                        await item.addToFavorites(refId!);
                                        widget.onUpdateCallback(item);
                                      } else {
                                        await item.removeFromFavorites(refId!);
                                        widget.onUpdateCallback(item);
                                      }
                                      await fetchFav();
                                    },
                                    initValue: item.existsInFavorites("live"),
                                    iconSize: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                      // return LayoutBuilder(
                      //   builder: (context, c) {
                      //     final double w = c.maxWidth;
                      //     return Stack(
                      //       children: [
                      //         GestureDetector(
                      //           onTap: () async {
                      // print(item.title);
                      // item.addToHistory(refId!);
                      // await loadVideo(context, item);
                      //           },
                      //           child: Container(
                      //             margin:
                      //                 const EdgeInsets.only(top: 10, right: 10),
                      //             child: Column(
                      //               crossAxisAlignment: CrossAxisAlignment.start,
                      //               mainAxisAlignment: MainAxisAlignment.start,
                      //               children: [
                      //                 ClipRRect(
                      //                   borderRadius: BorderRadius.circular(10),
                      //                   child: NetworkImageViewer(
                      //                     url: item.attributes['tvg-logo'],
                      //                     title: "false",
                      //                     width: w,
                      //                     height: 75,
                      //                     color: highlight,
                      //                     fit: BoxFit.cover,
                      //                   ),
                      //                 ),
                      //                 const SizedBox(height: 7),
                      //                 Text(
                      //                   item.title,
                      //                   maxLines: 2,
                      //                   overflow: TextOverflow.ellipsis,
                      //                   style: const TextStyle(height: 1),
                      //                 ),
                      //               ],
                      //             ),
                      //           ),
                      //         ),

                      //       ],
                      //     );
                      //   },
                      // );
                    },
                  ),
        ),
      ],
    );
  }

  int calculateCrossAxisCount(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount =
        (screenWidth / 150).floor(); // Calculate based on item width
    return crossAxisCount < 3 ? 3 : crossAxisCount;
  }
}
