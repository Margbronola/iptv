// ignore_for_file: must_be_immutable, use_build_context_synchronously, deprecated_member_use, avoid_print

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:seizhiptv/data_containers/favorites.dart';
import 'package:seizhiptv/extension/m3u_entry.dart';
import 'package:seizhiptv/globals/data.dart';
import 'package:seizhiptv/globals/favorite_button.dart';
import 'package:seizhiptv/globals/network_image_viewer.dart';
import 'package:seizhiptv/globals/palette.dart';
import 'package:seizhiptv/m3u/m3u_entry.dart';
import 'package:seizhiptv/m3u/zm3u_handler.dart';
import 'package:seizhiptv/views/landing_page/children/movie_children/details.dart';

class FavMoviePage extends StatefulWidget {
  FavMoviePage({
    super.key,
    required this.data,
    this.showSearchField = false,
    required this.onUpdateCallback,
  });
  final List<M3uEntry> data;
  final ValueChanged<M3uEntry> onUpdateCallback;
  bool showSearchField;

  @override
  State<FavMoviePage> createState() => FavMoviePageState();
}

class FavMoviePageState extends State<FavMoviePage> {
  final Favorites _favvm = Favorites.instance;
  static final ZM3UHandler _handler = ZM3UHandler.instance;
  List<M3uEntry>? searchData;

  fetchFav() async {
    await _handler
        .getDataFrom(type: CollectionType.favorites, refId: refId!)
        .then((value) {
          if (value != null) {
            _favvm.populate(value);
          }
        });
  }

  String searchText = "";

  void search(String text) {
    try {
      print("TEXT SEARCH IN CATEGORY LIVE: $text");
      searchText = text;
      endIndex = widget.data.length < 30 ? widget.data.length : 30;
      if (text.isEmpty) {
        _displayData = List.from(widget.data);
      } else {
        text.isEmpty
            ? _displayData = List.from(widget.data)
            : _displayData = List.from(
              widget.data
                  .where(
                    (element) => element.title.toLowerCase().contains(
                      text.toLowerCase(),
                    ),
                  )
                  .toList(),
            );
      }
      _displayData.sort((a, b) => a.title.compareTo(b.title));

      print("DISPLAY DATA LENGHT: ${_displayData.length}");
      if (mounted) setState(() {});
    } on RangeError {
      _displayData = [];
      if (mounted) setState(() {});
    }
  }

  final int startIndex = 0;
  late int endIndex = widget.data.length;
  late List<M3uEntry> _displayData = List.from(
    widget.data.sublist(startIndex, endIndex),
  );

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const Center(child: Text("No data added to favorites"));
    }
    return Column(
      children: [
        Expanded(
          child:
              _displayData.isEmpty
                  ? Center(
                    child: Text(
                      "No Result Found for `$searchText`",
                      style: TextStyle(color: Colors.white.withOpacity(.5)),
                    ),
                  )
                  : GridView.builder(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: calculateCrossAxisCount(context),
                      childAspectRatio: .8,
                      crossAxisSpacing: 10,
                    ),
                    itemCount: _displayData.length,
                    itemBuilder: (context, index) {
                      final M3uEntry item = _displayData[index];

                      return Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              String result1 = item.title.replaceAll(
                                RegExp(
                                  r"[0-9]|[(]+[0-9]+[)]|[|]\s+[0-9]+\s[|]",
                                ),
                                '',
                              );
                              String result2 = result1.replaceAll(
                                RegExp(r"[|]+[a-zA-Z]+[|]|[a-zA-Z]+[|] "),
                                '',
                              );

                              Navigator.push(
                                context,
                                PageTransition(
                                  child: MovieDetailsPage(
                                    data: item,
                                    title: result2,
                                  ),
                                  type: PageTransitionType.rightToLeft,
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(top: 10, right: 10),
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
                                      fit: BoxFit.cover,
                                      color: ColorPalette().highlight,
                                      title: item.title,
                                    ),
                                  );
                                },
                              ),
                              // Column(
                              //   crossAxisAlignment: CrossAxisAlignment.start,
                              //   mainAxisAlignment: MainAxisAlignment.start,
                              //   children: [
                              //     ClipRRect(
                              //       borderRadius: BorderRadius.circular(10),
                              //       child: NetworkImageViewer(
                              //         url: item.attributes['tvg-logo'],
                              //         width: w,
                              //         height: 75,
                              //         color: highlight,
                              //         fit: BoxFit.cover,
                              //       ),
                              //     ),
                              //     const SizedBox(height: 7),
                              //     Text(
                              //       item.title,
                              //       maxLines: 2,
                              //       overflow: TextOverflow.ellipsis,
                              //       style: const TextStyle(height: 1),
                              //     ),
                              //   ],
                              // ),
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
                                            borderRadius: BorderRadius.circular(
                                              10.0,
                                            ),
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
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
                                                  padding: const EdgeInsets.all(
                                                    0,
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
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
                                initValue: item.existsInFavorites("movie"),
                                iconSize: 20,
                              ),
                            ),
                          ),
                        ],
                      );
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
