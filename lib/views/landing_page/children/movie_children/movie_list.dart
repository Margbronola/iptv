// ignore_for_file: avoid_print, deprecated_member_use, use_build_context_synchronously

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:seizhiptv/data_containers/favorites.dart';
import 'package:seizhiptv/extension/m3u_entry.dart';
import 'package:seizhiptv/globals/data.dart';
import 'package:seizhiptv/globals/favorite_button.dart';
import 'package:seizhiptv/globals/network_image_viewer.dart';
import 'package:seizhiptv/globals/palette.dart';
import 'package:seizhiptv/globals/video_player.dart';
import 'package:seizhiptv/m3u/m3u_entry.dart';
import 'package:seizhiptv/m3u/zm3u_handler.dart';
import 'package:seizhiptv/models/get_video.dart';
import 'package:seizhiptv/models/topmovie.dart';
import 'package:seizhiptv/services/movie_api.dart';
import 'package:seizhiptv/viewmodel/movie_vm.dart';
import 'package:seizhiptv/viewmodel/video_vm.dart';
import 'package:seizhiptv/views/landing_page/children/movie_children/details.dart';

class MovieListPage extends StatefulWidget {
  const MovieListPage({
    super.key,
    required this.controller,
    required this.data,
    required this.showSearchField,
    required this.onUpdateCallback,
  });

  final ScrollController controller;
  final List<M3uEntry> data;
  final bool showSearchField;
  final ValueChanged<M3uEntry> onUpdateCallback;
  @override
  State<MovieListPage> createState() => MovieListPageState();
}

class MovieListPageState extends State<MovieListPage> {
  static final TopRatedMovieViewModel _viewModel =
      TopRatedMovieViewModel.instance;
  static final MovieVideoViewModel _videoViewModel =
      MovieVideoViewModel.instance;
  static final Favorites _vm = Favorites.instance;
  static final ZM3UHandler _handler = ZM3UHandler.instance;
  List<M3uEntry>? searchData;

  fetchFav() async {
    await _handler
        .getDataFrom(type: CollectionType.favorites, refId: refId!)
        .then((value) {
          if (value != null) {
            _vm.populate(value);
          }
        });
  }

  @override
  void initState() {
    super.initState();
    searchData = widget.data;
  }

  String searchText = "";

  void search(String text) {
    try {
      print("TEXT SEARCH IN LIVE: $text");
      searchText = text;
      endIndex = widget.data.length < 30 ? widget.data.length : 30;
      if (text.isEmpty) {
        searchData = List.from(widget.data);
      } else {
        text.isEmpty
            ? searchData = List.from(widget.data)
            : searchData = List.from(
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
  late int endIndex = widget.data.length < 60 ? widget.data.length : 60;
  late List<M3uEntry> _displayData = List.from(
    widget.data.sublist(startIndex, endIndex),
  );

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Column(
      children: [
        Expanded(
          child:
              widget.showSearchField == true
                  ? searchData!.isEmpty
                      ? Center(
                        child: Text(
                          "No Result Found for `$searchText`",
                          style: TextStyle(color: Colors.white.withOpacity(.5)),
                        ),
                      )
                      : GridView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisExtent: 155,
                            ),
                        itemCount: searchData!.length,
                        itemBuilder: (context, i) {
                          final M3uEntry d = searchData![i];

                          return GestureDetector(
                            onTap: () async {
                              String result1 = d.title.replaceAll(
                                RegExp(r"[(]+[a-zA-Z]+[)]|[|]\s+[0-9]+\s[|]"),
                                '',
                              );
                              String result2 = result1.replaceAll(
                                RegExp(r"[|]+[a-zA-Z]+[|]|[a-zA-Z]+[|] "),
                                '',
                              );

                              print("MOVIEEE TITLE (result1): $result1");
                              print("MOVIEEE TITLE (result2): $result2");

                              Navigator.push(
                                context,
                                PageTransition(
                                  child: MovieDetailsPage(
                                    data: d,
                                    title: result2,
                                  ),
                                  type: PageTransitionType.rightToLeft,
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 1.5,
                              ),
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
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                          child: NetworkImageViewer(
                                            url: d.attributes['tvg-logo'],
                                            width: w,
                                            height: h,
                                            fit: BoxFit.cover,
                                            color: ColorPalette().highlight,
                                            title: d.title,
                                          ),
                                        );
                                      },
                                    ),
                                    // LayoutBuilder(
                                    //   builder: (context, c) {
                                    //     final double w = c.maxWidth;
                                    //     return Tooltip(
                                    //       message: d.title,
                                    //       child: Column(
                                    //         crossAxisAlignment:
                                    //             CrossAxisAlignment.start,
                                    //         children: [
                                    //           NetworkImageViewer(
                                    //             url: d.attributes['tvg-logo'],
                                    //             width: w,
                                    //             height: 90,
                                    //             fit: BoxFit.cover,
                                    //             color: highlight,
                                    //           ),
                                    //           const SizedBox(height: 3),
                                    //           Tooltip(
                                    //             message: d.title,
                                    // child: Text(
                                    //   d.title,
                                    //   style: const TextStyle(
                                    //       fontSize: 12),
                                    //   maxLines: 2,
                                    //   overflow:
                                    //       TextOverflow.ellipsis,
                                    // ),
                                    //           ),
                                    //         ],
                                    //       ),
                                    //     );
                                    //   },
                                    // ),
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
                                                    Navigator.of(
                                                      context,
                                                    ).pop(true);
                                                  },
                                                );
                                                return Dialog(
                                                  alignment:
                                                      Alignment.topCenter,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
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
                                                          "Added_to_Favorites"
                                                              .tr(),
                                                          style:
                                                              const TextStyle(
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
                                            await d.addToFavorites(refId!);
                                            widget.onUpdateCallback(d);
                                          } else {
                                            await d.removeFromFavorites(refId!);
                                            widget.onUpdateCallback(d);
                                          }
                                          await fetchFav();
                                        },
                                        initValue: d.existsInFavorites("movie"),
                                        iconSize: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                  : ListView(
                    controller: widget.controller..addListener(_scrollListener),
                    children: [
                      StreamBuilder<List<TopMovieModel>>(
                        stream: _viewModel.stream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData && !snapshot.hasError) {
                            if (snapshot.data!.isNotEmpty) {
                              final List<TopMovieModel> result = snapshot.data!;
                              for (final M3uEntry movdata in widget.data) {
                                for (final TopMovieModel toprated in result) {
                                  if (movdata.title == toprated.title) {
                                    MovieAPI().getMovieVideos(id: toprated.id);

                                    return SizedBox(
                                      width: size.width,
                                      child: Column(
                                        children: [
                                          StreamBuilder<List<Video>>(
                                            stream: _videoViewModel.stream,
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData &&
                                                  !snapshot.hasError) {
                                                if (snapshot.data!.isNotEmpty) {
                                                  final List<Video> result =
                                                      snapshot.data!;
                                                  final Iterable<Video>
                                                  trailer = result.where(
                                                    (element) => element.type
                                                        .contains("Trailer"),
                                                  );
                                                  return Videoplayer(
                                                    url: trailer.first.key,
                                                  );
                                                }
                                              }
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.grey,
                                                    ),
                                              );
                                            },
                                          ),
                                          MaterialButton(
                                            elevation: 0,
                                            color: Colors.transparent,
                                            padding: const EdgeInsets.all(0),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                PageTransition(
                                                  child: MovieDetailsPage(
                                                    data: movdata,
                                                    title: toprated.title,
                                                  ),
                                                  type:
                                                      PageTransitionType
                                                          .leftToRight,
                                                ),
                                              );
                                            },
                                            child: Container(
                                              width: size.width,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 15,
                                                  ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    toprated.title,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 22,
                                                      height: 1.1,
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        DateFormat(
                                                          'MMM dd, yyyy',
                                                        ).format(
                                                          toprated.date!,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 5,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          border: Border.all(
                                                            color: Colors.white,
                                                          ),
                                                          borderRadius:
                                                              const BorderRadius.all(
                                                                Radius.circular(
                                                                  5,
                                                                ),
                                                              ),
                                                        ),
                                                        child: Text(
                                                          "${toprated.voteAverage}",
                                                        ),
                                                      ),
                                                      const SizedBox(width: 15),
                                                      SizedBox(
                                                        height: 25,
                                                        width: 30,
                                                        child: MaterialButton(
                                                          color: Colors.grey,
                                                          padding:
                                                              const EdgeInsets.all(
                                                                0,
                                                              ),
                                                          onPressed: () {},
                                                          child: const Text(
                                                            "HD",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    Center(
                                      child: Text(
                                        "No_data_available".tr(),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  }
                                }
                              }
                            }
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.grey,
                              ),
                            );
                          }
                          return Center(
                            child: Text(
                              "No_data_available".tr(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                      ),
                      GridView.builder(
                        shrinkWrap: true,
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

                          return GestureDetector(
                            onTap: () async {
                              String result1 = item.title.replaceAll(
                                RegExp(
                                  r"[0-9]|[(]+[0-9]+[)]|[|]\s+[0-9]+\s[|]",
                                ),
                                '',
                              );
                              String result2 = result1.replaceAll(
                                RegExp(r"[|]+[a-zA-Z]+[|]|[a-zA-Z]+[|]"),
                                '',
                              );

                              String result3 = item.title.replaceAll(
                                RegExp('[^0-9]'),
                                '',
                              );

                              print("MOVIEEE TITLE: ${item.title}");
                              print("MOVIEEE TITLE (result1): $result1");
                              print("MOVIEEE TITLE (result2): $result2");
                              print("MOVIEEE TITLE (result3): $result3");

                              Navigator.push(
                                context,
                                PageTransition(
                                  child: MovieDetailsPage(
                                    data: item,
                                    title: result2,
                                    year: result3,
                                  ),
                                  type: PageTransitionType.rightToLeft,
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 1.5,
                              ),
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
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
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
                                    // LayoutBuilder(
                                    //   builder: (context, c) {
                                    //     final double w = c.maxWidth;
                                    //     return Tooltip(
                                    //       message: item.title,
                                    //       child: Column(
                                    //         crossAxisAlignment:
                                    //             CrossAxisAlignment.start,
                                    //         children: [
                                    //           Container(
                                    //             decoration: BoxDecoration(
                                    //               borderRadius:
                                    //                   BorderRadius.circular(10),
                                    //             ),
                                    //             child: NetworkImageViewer(
                                    //               url: item
                                    //                   .attributes['tvg-logo'],
                                    //               width: w,
                                    //               height: 75,
                                    //               fit: BoxFit.fitHeight,
                                    //               color: highlight,
                                    //             ),
                                    //           ),
                                    //           const SizedBox(height: 3),
                                    //           Tooltip(
                                    //             message: item.title,
                                    //             child: Text(
                                    //               item.title,
                                    //               style: const TextStyle(
                                    //                   fontSize: 12),
                                    //               maxLines: 2,
                                    //               overflow:
                                    //                   TextOverflow.ellipsis,
                                    //             ),
                                    //           ),
                                    //         ],
                                    //       ),
                                    //     );
                                    //   },
                                    // ),
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
                                                    Navigator.of(context).pop();
                                                  },
                                                );
                                                return Dialog(
                                                  alignment:
                                                      Alignment.topCenter,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
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
                                                          "Added_to_Favorites"
                                                              .tr(),
                                                          style:
                                                              const TextStyle(
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
                                            await item.removeFromFavorites(
                                              refId!,
                                            );
                                            widget.onUpdateCallback(item);
                                          }
                                          await fetchFav();
                                        },
                                        initValue: item.existsInFavorites(
                                          "movie",
                                        ),
                                        iconSize: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
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

  void _scrollListener() {
    if (widget.controller.offset >=
        widget.controller.position.maxScrollExtent) {
      setState(() {
        if (endIndex < widget.data.length) {
          endIndex += 6;
          if (endIndex > widget.data.length) {
            endIndex = widget.data.length;
          }
        }
        _displayData = List.from(
          widget.data.sublist(
            startIndex,
            endIndex > widget.data.length ? widget.data.length : endIndex,
          ),
        );
        print("DUGANG! ${_displayData.length}");
      });
    }
  }
}
