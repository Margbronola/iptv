// ignore_for_file: unnecessary_null_comparison, deprecated_member_use, avoid_print

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:seizhiptv/data_containers/favorites.dart';
import 'package:seizhiptv/data_containers/history.dart';
import 'package:seizhiptv/data_containers/loaded_m3u_data.dart';
import 'package:seizhiptv/extension/color.dart';
import 'package:seizhiptv/extension/state.dart';
import 'package:seizhiptv/globals/data.dart';
import 'package:seizhiptv/globals/loader.dart';
import 'package:seizhiptv/globals/palette.dart';
import 'package:seizhiptv/globals/ui_additional.dart';
import 'package:seizhiptv/m3u/classified_data.dart';
import 'package:seizhiptv/m3u/m3u_entry.dart';
import 'package:seizhiptv/m3u/zm3u_handler.dart';
import 'package:seizhiptv/views/landing_page/children/movie_children/fav_movie.dart';
import 'package:seizhiptv/views/landing_page/children/movie_children/movie_category.dart';
import 'package:seizhiptv/views/landing_page/children/movie_children/movie_history.dart';
import 'package:seizhiptv/views/landing_page/children/movie_children/movie_list.dart';

class MoviePage extends StatefulWidget {
  const MoviePage({super.key});

  @override
  State<MoviePage> createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage> {
  static final ZM3UHandler _handler = ZM3UHandler.instance;
  final LoadedM3uData _vm = LoadedM3uData.instance;
  late final ScrollController _scrollController;
  final Favorites _vm1 = Favorites.instance;
  final History _hisvm = History.instance;
  late List<ClassifiedData> _favdata;
  late List<ClassifiedData> _hisdata;
  late List<M3uEntry> favData = [];
  late List<M3uEntry> hisData = [];
  bool showSearchField = false;
  bool update = false;
  late final TextEditingController _search;
  List<M3uEntry> movieData = [];
  late List<String>? categoryName = [];
  List<ClassifiedData>? displayData;
  late List<M3uEntry> data = [];
  late List<M3uEntry> categorydata = [];
  bool categorysearch = false;
  String dropdownvalue = "";
  int? ind = 0;
  int? prevIndex;
  bool selected = true;

  initStream() {
    _vm.stream.listen((event) {
      displayData = List.from(event.movies);
      for (final ClassifiedData item in event.movies) {
        late final List<M3uEntry> data = item.data;
        movieData.addAll(List.from(data));
      }
      categoryName = ["ALL (${movieData == null ? "" : movieData.length})"];
      for (final ClassifiedData cdata in displayData!) {
        categoryName!.add("${cdata.name} (${cdata.data.length})");
      }
      categoryName!.sort((a, b) => a.compareTo(b));
      movieData.sort((a, b) => a.title.compareTo(b.title));
      for (final String label in categoryName!) {
        if (label.contains(
          "ALL (${movieData == null ? "" : movieData.length})",
        )) {
          dropdownvalue = label;
        }
      }
      if (mounted) setState(() {});
    });
  }

  fetchFav() async {
    await _handler
        .getDataFrom(type: CollectionType.favorites, refId: refId!)
        .then((value) {
          if (value != null) {
            _vm1.populate(value);
          }
        });
  }

  fetchHis() async {
    await _handler
        .getDataFrom(type: CollectionType.history, refId: refId!)
        .then((value) {
          if (value != null) {
            _hisvm.populate(value);
          }
        });
  }

  initFavStream() {
    _vm1.stream.listen((event) {
      _favdata = List.from(event.movies);
      favData =
          _favdata.expand((element) => element.data).toList()
            ..sort((a, b) => a.title.compareTo(b.title));
    });
  }

  initHisStream() {
    _hisvm.stream.listen((event) {
      _hisdata = List.from(event.movies);
      hisData =
          _hisdata.expand((element) => element.data).toList()
            ..sort((a, b) => a.title.compareTo(b.title));
    });
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    _search = TextEditingController();
    fetchFav();
    fetchHis();
    initFavStream();
    initHisStream();
    initStream();
    super.initState();
  }

  final GlobalKey<MovieListPageState> _kList = GlobalKey<MovieListPageState>();
  final GlobalKey<FavMoviePageState> _favPage = GlobalKey<FavMoviePageState>();
  final GlobalKey<MovieHistoryPageState> _hisPage =
      GlobalKey<MovieHistoryPageState>();
  final GlobalKey<MovieCategoryPageState> _catPage =
      GlobalKey<MovieCategoryPageState>();

  @override
  void dispose() {
    _scrollController.dispose();
    favData = [];
    hisData = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: ColorPalette().card,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: appbar(
            2,
            onSearchPressed: () async {
              showSearchField = !showSearchField;
              if (showSearchField == true) {
                if (ind == 0) {
                  if (dropdownvalue.contains("ALL") || dropdownvalue == "") {
                    categorysearch = false;
                  } else {
                    categorysearch = true;
                  }
                } else {
                  categorysearch = false;
                }
              }
              if (mounted) setState(() {});
            },
            onUpdateChannel: () {
              setState(() {
                update = true;
                Future.delayed(const Duration(seconds: 6), () {
                  setState(() {
                    update = false;
                  });
                });
              });
            },
          ),
        ),
        body: Stack(
          children: [
            displayData == null
                ? SeizhTvLoader(
                  label: Text(
                    "Retrieving_data".tr(),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                )
                : Column(
                  children: [
                    Container(
                      height: 50,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ind == 0
                                ? Container(
                                  width: 270,
                                  height: 50,
                                  padding: const EdgeInsets.all(10),
                                  alignment: Alignment.centerLeft,
                                  decoration: BoxDecoration(
                                    color:
                                        ind == 0
                                            ? ColorPalette().topColor
                                            : ColorPalette().highlight,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color:
                                          ind == 0
                                              ? ColorPalette().topColor
                                              : Colors.grey,
                                    ),
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        prevIndex = ind!;
                                        ind = 0;
                                        showSearchField = false;
                                        print("CURRENT INDEX $ind");
                                        print("PREV INDEX $prevIndex");
                                      });
                                    },
                                    child:
                                        ind == 0 && prevIndex != 0
                                            ? DropdownButton(
                                              elevation: 0,
                                              isExpanded: true,
                                              padding: const EdgeInsets.all(0),
                                              underline: Container(),
                                              onTap: () {
                                                setState(() {
                                                  selected = true;
                                                  ind = 0;
                                                });
                                              },
                                              items:
                                                  categoryName!.map((value) {
                                                    return DropdownMenuItem(
                                                      value: value,
                                                      child: Text(
                                                        value,
                                                        // maxLines: 1,
                                                        // overflow:
                                                        //     TextOverflow.ellipsis,
                                                      ),
                                                    );
                                                  }).toList(),
                                              value:
                                                  dropdownvalue == ""
                                                      ? categoryName == []
                                                          ? ""
                                                          : categoryName![3]
                                                      : dropdownvalue,
                                              style: const TextStyle(
                                                fontFamily: "Poppins",
                                              ),
                                              onChanged: (value) {
                                                setState(() {
                                                  dropdownvalue = value!;
                                                  String result1 = dropdownvalue
                                                      .replaceAll(
                                                        RegExp(
                                                          r"[(]+[0-9]+[)]",
                                                        ),
                                                        '',
                                                      );

                                                  data =
                                                      displayData!
                                                          .where(
                                                            (element) => element
                                                                .name
                                                                .contains(
                                                                  result1
                                                                      .trimRight(),
                                                                ),
                                                          )
                                                          .expand(
                                                            (element) =>
                                                                element.data,
                                                          )
                                                          .toList()
                                                        ..sort(
                                                          (a, b) =>
                                                              a.title.compareTo(
                                                                b.title,
                                                              ),
                                                        );
                                                  categorydata = data;
                                                  showSearchField = false;
                                                  categorysearch = false;
                                                });
                                              },
                                            )
                                            : Text(
                                              dropdownvalue,
                                              style: const TextStyle(
                                                fontFamily: "Poppins",
                                              ),
                                            ),
                                  ),
                                )
                                : GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      prevIndex = ind!;
                                      ind = 0;
                                      showSearchField = false;
                                    });
                                  },
                                  child: Container(
                                    // width: 180,
                                    height: 50,
                                    padding: const EdgeInsets.all(10),
                                    alignment: Alignment.centerLeft,
                                    decoration: BoxDecoration(
                                      color:
                                          ind == 0
                                              ? ColorPalette().topColor
                                              : ColorPalette().highlight,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color:
                                            ind == 0
                                                ? ColorPalette().topColor
                                                : Colors.grey,
                                      ),
                                    ),
                                    child:
                                        ind == 0 && prevIndex != 0
                                            ? DropdownButton(
                                              elevation: 0,
                                              isExpanded: true,
                                              padding: const EdgeInsets.all(0),
                                              underline: Container(),
                                              onTap: () {
                                                setState(() {
                                                  selected = true;
                                                  ind = 0;
                                                });
                                              },
                                              items:
                                                  categoryName!.map((value) {
                                                    return DropdownMenuItem(
                                                      value: value,
                                                      child: Text(
                                                        value,
                                                        maxLines: 1,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                      ),
                                                    );
                                                  }).toList(),
                                              value:
                                                  dropdownvalue == ""
                                                      ? categoryName == []
                                                          ? ""
                                                          : categoryName![3]
                                                      : dropdownvalue,
                                              style: const TextStyle(
                                                fontFamily: "Poppins",
                                              ),
                                              onChanged: (value) {
                                                setState(() {
                                                  dropdownvalue = value!;
                                                  String result1 = dropdownvalue
                                                      .replaceAll(
                                                        RegExp(
                                                          r"[(]+[0-9]+[)]",
                                                        ),
                                                        '',
                                                      );

                                                  data =
                                                      displayData!
                                                          .where(
                                                            (element) => element
                                                                .name
                                                                .contains(
                                                                  result1
                                                                      .trimRight(),
                                                                ),
                                                          )
                                                          .expand(
                                                            (element) =>
                                                                element.data,
                                                          )
                                                          .toList()
                                                        ..sort(
                                                          (a, b) =>
                                                              a.title.compareTo(
                                                                b.title,
                                                              ),
                                                        );
                                                  categorydata = data;
                                                  showSearchField = false;
                                                  categorysearch = false;
                                                });
                                              },
                                            )
                                            : Text(
                                              dropdownvalue,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontFamily: "Poppins",
                                              ),
                                            ),
                                  ),
                                ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  prevIndex = ind!;
                                  ind = 1;
                                  showSearchField = false;
                                  print("CURRENT INDEX $ind");
                                  print("PREV INDEX $prevIndex");
                                });
                              },
                              child: Container(
                                height: 50,
                                padding: const EdgeInsets.all(10),
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                  color:
                                      ind == 1
                                          ? ColorPalette().topColor
                                          : ColorPalette().highlight,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color:
                                        ind == 1
                                            ? ColorPalette().topColor
                                            : Colors.grey,
                                  ),
                                ),
                                child: Text(
                                  "${"favorites".tr().toUpperCase()} (${favData.length})",
                                  style: const TextStyle(fontFamily: "Poppins"),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  prevIndex = ind!;
                                  ind = 2;
                                  showSearchField = false;
                                  print("CURRENT INDEX $ind");
                                  print("PREV INDEX $prevIndex");
                                });
                              },
                              child: Container(
                                height: 50,
                                padding: const EdgeInsets.all(10),
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                  color:
                                      ind == 2
                                          ? ColorPalette().topColor
                                          : ColorPalette().highlight,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color:
                                        ind == 2
                                            ? ColorPalette().topColor
                                            : Colors.grey,
                                  ),
                                ),
                                child: Text(
                                  "${"Channels_History".tr().toUpperCase()} (${hisData.length})",
                                  style: const TextStyle(fontFamily: "Poppins"),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),
                    categorysearch == false
                        ? AnimatedPadding(
                          duration: const Duration(milliseconds: 400),
                          padding: EdgeInsets.symmetric(
                            horizontal: showSearchField ? 20 : 0,
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            height: showSearchField ? 50 : 0,
                            width: double.maxFinite,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 50,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
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
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            child:
                                                showSearchField
                                                    ? TextField(
                                                      onChanged: (text) {
                                                        if (_kList
                                                                .currentState !=
                                                            null) {
                                                          _kList.currentState!
                                                              .search(text);
                                                        } else if (_favPage
                                                                .currentState !=
                                                            null) {
                                                          _favPage.currentState!
                                                              .search(text);
                                                        } else if (_hisPage
                                                                .currentState !=
                                                            null) {
                                                          _hisPage.currentState!
                                                              .search(text);
                                                        }
                                                        if (mounted) {
                                                          setState(() {});
                                                        }
                                                      },
                                                      cursorColor:
                                                          ColorPalette().orange,
                                                      controller: _search,
                                                      decoration:
                                                          InputDecoration(
                                                            hintText:
                                                                "Search".tr(),
                                                          ),
                                                    )
                                                    : Container(),
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
                                      _kList.currentState?.search("");
                                      _favPage.currentState?.search("");
                                      _hisPage.currentState?.search("");
                                      _search.text = "";
                                      showSearchField = !showSearchField;
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
                    if (showSearchField) ...{const SizedBox(height: 20)},
                    Expanded(
                      child: Scrollbar(
                        controller: _scrollController,
                        child:
                            ind == 0
                                ? dropdownvalue.contains("ALL") ||
                                        dropdownvalue == ""
                                    ? MovieListPage(
                                      key: _kList,
                                      controller: _scrollController,
                                      data: movieData,
                                      showSearchField: showSearchField,
                                      onUpdateCallback: (item) {
                                        setState(() {
                                          print("Valueee: $item");
                                        });
                                      },
                                    )
                                    : MovieCategoryPage(
                                      key: _catPage,
                                      categorydata: categorydata,
                                      showsearchfield: categorysearch,
                                      onUpdateCallback: (item) {
                                        setState(() {
                                          print("Valueee: $item");
                                        });
                                      },
                                    )
                                : ind == 1
                                ? FavMoviePage(
                                  key: _favPage,
                                  data: favData,
                                  onUpdateCallback: (item) {
                                    setState(() {
                                      print("Valueee: $item");
                                    });
                                  },
                                )
                                : MovieHistoryPage(
                                  key: _hisPage,
                                  data: hisData,
                                ),
                      ),
                    ),
                  ],
                ),
            update == true ? UIAdditional().loader() : Container(),
          ],
        ),
      ),
    );
  }
}
