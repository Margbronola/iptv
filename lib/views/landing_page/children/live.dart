// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:seizhiptv/data_containers/favorites.dart';
import 'package:seizhiptv/data_containers/history.dart';
import 'package:seizhiptv/data_containers/loaded_m3u_data.dart';
import 'package:seizhiptv/extension/color.dart';
import 'package:seizhiptv/extension/list.dart';
import 'package:seizhiptv/extension/state.dart';
import 'package:seizhiptv/globals/data.dart';
import 'package:seizhiptv/globals/loader.dart';
import 'package:seizhiptv/globals/palette.dart';
import 'package:seizhiptv/globals/ui_additional.dart';
import 'package:seizhiptv/globals/video_loader.dart';
import 'package:seizhiptv/m3u/categorized_m3u_data.dart';
import 'package:seizhiptv/m3u/classified_data.dart';
import 'package:seizhiptv/m3u/m3u_entry.dart';
import 'package:seizhiptv/m3u/zm3u_handler.dart';
import 'package:seizhiptv/views/landing_page/children/live_children/fav_live.dart';
import 'package:seizhiptv/views/landing_page/children/live_children/live_category.dart';
import 'package:seizhiptv/views/landing_page/children/live_children/live_history.dart';
import 'package:seizhiptv/views/landing_page/children/live_children/live_list.dart';

class LivePage extends StatefulWidget {
  const LivePage({super.key});

  @override
  State<LivePage> createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> {
  late final StreamSubscription<CategorizedM3UData> _streamer;
  static final ZM3UHandler _handler = ZM3UHandler.instance;
  final LoadedM3uData _vm = LoadedM3uData.instance;
  final Favorites _favvm = Favorites.instance;
  final History _hisvm = History.instance;
  late List<ClassifiedData> sdata = [];
  late List<String>? categoryName = [];
  late List<ClassifiedData> _favdata;
  late List<ClassifiedData> _hisdata;
  late List<M3uEntry> favData = [];
  late List<M3uEntry> hisData = [];
  late List<M3uEntry> data = [];
  late List<M3uEntry> categorydata = [];
  late final List<M3uEntry> _data;
  List<M3uEntry>? displayData;
  late final ScrollController scrollController;
  late final TextEditingController search;
  bool showSearchField = false;
  String dropdownvalue = "";
  bool categorysearch = false;
  bool selected = true;
  bool update = false;
  int prevIndex = 1;
  int? ind = 0;

  initStream() {
    _streamer = _vm.stream.listen((event) {
      sdata = List.from(event.live);
      _data = List.from(
        event.live.expand((element) => element.data).toList().unique(),
      );
      displayData = List.from(_data.unique());
      displayData!.sort((a, b) => a.title.compareTo(b.title));
      categoryName = [
        "ALL (${displayData == null ? "" : displayData!.length})",
      ];
      for (final ClassifiedData cdata in sdata) {
        categoryName!.add("${cdata.name} (${cdata.data.length})");
      }
      categoryName!.sort((a, b) => a.compareTo(b));
      for (final String label in categoryName!) {
        if (label.contains(
          "ALL (${displayData == null ? "" : displayData!.length})",
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
            _favvm.populate(value);
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
    _favvm.stream.listen((event) {
      _favdata = List.from(event.live);
      favData = _favdata.expand((element) => element.data).toList();
    });
  }

  initHisStream() {
    _hisvm.stream.listen((event) {
      _hisdata = List.from(event.live);
      hisData = _hisdata.expand((element) => element.data).toList();
    });
  }

  @override
  void initState() {
    scrollController = ScrollController();
    search = TextEditingController();
    showSearchField = false;
    initStream();
    fetchFav();
    fetchHis();
    initFavStream();
    initHisStream();
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    search.dispose();
    _streamer.cancel();
    showSearchField = false;
    super.dispose();
  }

  final GlobalKey<LiveListPageState> _kList = GlobalKey<LiveListPageState>();
  final GlobalKey<FavLivePageState> _favPage = GlobalKey<FavLivePageState>();
  final GlobalKey<LiveHistoryPageState> _hisPage =
      GlobalKey<LiveHistoryPageState>();
  final GlobalKey<LiveCategoryPageState> _catPage =
      GlobalKey<LiveCategoryPageState>();

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
            1,
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
              print("CATEGORY SEARCH: $categorysearch");
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
                    const SizedBox(height: 10),
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
                                                      sdata
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
                                              // maxLines: 1,
                                              // overflow: TextOverflow.ellipsis,
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
                                      print("CURRENT INDEX $ind");
                                      print("PREV INDEX $prevIndex");
                                    });
                                  },
                                  child: Container(
                                    // width: 270,
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
                                            ? Expanded(
                                              child: DropdownButton(
                                                elevation: 0,
                                                isExpanded: true,
                                                padding: const EdgeInsets.all(
                                                  0,
                                                ),
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
                                                    String
                                                    result1 = dropdownvalue
                                                        .replaceAll(
                                                          RegExp(
                                                            r"[(]+[0-9]+[)]",
                                                          ),
                                                          '',
                                                        );

                                                    data =
                                                        sdata
                                                            .where(
                                                              (
                                                                element,
                                                              ) => element.name
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
                                                            (a, b) => a.title
                                                                .compareTo(
                                                                  b.title,
                                                                ),
                                                          );
                                                    categorydata = data;
                                                    showSearchField = false;
                                                    categorysearch = false;
                                                  });
                                                },
                                              ),
                                            )
                                            : Text(
                                              dropdownvalue,
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
                                                        }
                                                        // else if (_catPage
                                                        //         .currentState !=
                                                        //     null) {
                                                        //   _catPage
                                                        //       .currentState!
                                                        //       .search(text);
                                                        // }
                                                        else if (_favPage
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
                                                      controller: search,
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
                                      // _catPage.currentState?.search("");
                                      _favPage.currentState?.search("");
                                      _hisPage.currentState?.search("");
                                      search.text = "";
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
                        controller: scrollController,
                        child:
                            ind == 0
                                ? dropdownvalue.contains("ALL") ||
                                        dropdownvalue == ""
                                    ? LiveListPage(
                                      key: _kList,
                                      data: displayData!,
                                      controller: scrollController,
                                      onPressed: (M3uEntry entry) async {
                                        entry.addToHistory(refId!);
                                        await VideoLoader().loadVideo(
                                          context,
                                          entry,
                                        );
                                      },
                                      onUpdateCallback: (item) {
                                        setState(() {
                                          print("Valueee: $item");
                                        });
                                      },
                                    )
                                    : LiveCategoryPage(
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
                                ? FavLivePage(
                                  key: _favPage,
                                  data: favData,
                                  onPressed: (M3uEntry entry) async {
                                    entry.addToHistory(refId!);
                                    await VideoLoader().loadVideo(
                                      context,
                                      entry,
                                    );
                                  },
                                  onUpdateCallback: (item) {
                                    setState(() {
                                      print("Valueee: $item");
                                    });
                                  },
                                )
                                : LiveHistoryPage(
                                  key: _hisPage,
                                  data: hisData,
                                  onPressed: (M3uEntry entry) async {
                                    entry.addToHistory(refId!);
                                    await VideoLoader().loadVideo(
                                      context,
                                      entry,
                                    );
                                  },
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
