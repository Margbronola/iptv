// ignore_for_file: unnecessary_overrides, deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ZNavbar extends StatefulWidget {
  const ZNavbar({
    super.key,
    required this.tabs,
    this.currentIndex = 0,
    this.indexCallback,
    this.backgroundColor = Colors.white,
    this.indicatorColor = Colors.blue,
    this.indicatorSize = 8,
    this.activeColor = Colors.blue,
    this.padding = const EdgeInsets.symmetric(horizontal: 10),
    this.inactiveColor = Colors.grey,
  });
  final List<ZTab> tabs;
  final Color indicatorColor;
  final double indicatorSize;
  final int currentIndex;
  final Color activeColor;
  final Color inactiveColor;
  final EdgeInsets padding;
  final Color backgroundColor;
  final ValueChanged<int>? indexCallback;
  @override
  State<ZNavbar> createState() => ZNavbarState();
}

class ZNavbarState extends State<ZNavbar> with TickerProviderStateMixin {
  int stCurrentIdx = 0;

  @override
  void initState() {
    stCurrentIdx = widget.currentIndex;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void updateIndex(int i) {
    stCurrentIdx = i;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        final double w = c.maxWidth;
        return Material(
          elevation: 1,

          color: widget.backgroundColor,
          // color: Colors.blue,
          child: SafeArea(
            child: Container(
              width: w,
              height: 50,
              padding: widget.padding,
              child: Column(
                children: [
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    alignment: FractionalOffset(
                      1 / (widget.tabs.length - 1) * stCurrentIdx,
                      0,
                    ),
                    child: FractionallySizedBox(
                      widthFactor: 1 / widget.tabs.length,
                      child: Container(
                        height: widget.indicatorSize,
                        color: widget.indicatorColor,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 50 - widget.indicatorSize,
                    width: w,
                    child: Row(
                      children:
                          widget.tabs.asMap().entries.map((e) {
                            final ZTab tab = widget.tabs[e.key];
                            return Expanded(
                              child: MaterialButton(
                                onPressed: () {
                                  stCurrentIdx = e.key;
                                  if (widget.indexCallback != null) {
                                    widget.indexCallback!(e.key);
                                  }
                                  if (mounted) setState(() {});
                                },
                                child: AnimatedScale(
                                  scale: stCurrentIdx == e.key ? 1 : .9,
                                  duration: const Duration(milliseconds: 500),
                                  child: Column(
                                    children: [
                                      SizedBox(height: widget.indicatorSize),
                                      Expanded(
                                        child:
                                            tab.text != null
                                                ? Tooltip(
                                                  message: tab.text,
                                                  child:
                                                      tab.type == ZType.icon
                                                          ? IconTheme(
                                                            data: IconThemeData(
                                                              color:
                                                                  stCurrentIdx ==
                                                                          e.key
                                                                      ? widget
                                                                          .activeColor
                                                                      : widget
                                                                          .inactiveColor,
                                                            ),
                                                            child: tab.child,
                                                          )
                                                          : imageBuilder(
                                                            e.key,
                                                            path: tab.value!,
                                                            type: tab.imgType!,
                                                          ),
                                                )
                                                : tab.type == ZType.icon
                                                ? IconTheme(
                                                  data: IconThemeData(
                                                    color:
                                                        stCurrentIdx == e.key
                                                            ? widget.activeColor
                                                            : widget
                                                                .inactiveColor,
                                                  ),
                                                  child: tab.child,
                                                )
                                                : imageBuilder(
                                                  e.key,
                                                  path: tab.value!,
                                                  type: tab.imgType!,
                                                ),
                                      ),
                                      if (widget.tabs[e.key].text != null) ...{
                                        AnimatedScale(
                                          scale:
                                              stCurrentIdx == e.key ? 1 : .95,
                                          duration: const Duration(
                                            milliseconds: 500,
                                          ),
                                          child: FittedBox(
                                            child: Text(
                                              widget.tabs[e.key].text!,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                // height: 1,
                                                fontSize:
                                                    (widget.tabs.length > 4
                                                        ? 11
                                                        : 12),
                                                color:
                                                    stCurrentIdx == e.key
                                                        ? widget.activeColor
                                                        : widget.inactiveColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      },
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget imageBuilder(
    int index, {
    required String path,
    required ZImageType type,
  }) {
    switch (type) {
      case ZImageType.asset:
        return Image.asset(
          path,
          color:
              stCurrentIdx == index ? widget.activeColor : widget.inactiveColor,
          errorBuilder:
              (_, __, ___) => Center(
                child: CircularProgressIndicator.adaptive(
                  backgroundColor: widget.inactiveColor,
                  valueColor: AlwaysStoppedAnimation<Color>(widget.activeColor),
                ),
              ),
          width: 25,
          height: 25,
        );
      case ZImageType.network:
        return Image.network(
          path,
          color:
              stCurrentIdx == index ? widget.activeColor : widget.inactiveColor,
          errorBuilder:
              (_, __, ___) => Center(
                child: CircularProgressIndicator.adaptive(
                  backgroundColor: widget.inactiveColor,
                  valueColor: AlwaysStoppedAnimation<Color>(widget.activeColor),
                ),
              ),
          width: 25,
          height: 25,
        );
      case ZImageType.file:
        return Image.file(
          File(path),
          color:
              stCurrentIdx == index ? widget.activeColor : widget.inactiveColor,
          errorBuilder:
              (_, __, ___) => Center(
                child: CircularProgressIndicator.adaptive(
                  backgroundColor: widget.inactiveColor,
                  valueColor: AlwaysStoppedAnimation<Color>(widget.activeColor),
                ),
              ),
          width: 25,
          height: 25,
        );
      case ZImageType.svgAsset:
        return SvgPicture.asset(
          path,
          color:
              stCurrentIdx == index ? widget.activeColor : widget.inactiveColor,
          width: 25,
          height: 25,
        );
      case ZImageType.svgNetwork:
        return SvgPicture.network(
          path,
          color:
              stCurrentIdx == index ? widget.activeColor : widget.inactiveColor,
          width: 25,
          height: 25,
        );
    }
  }
}

class ZTab {
  final String? value;
  final ZImageType? imgType;
  final String? text;
  final ZType type;
  final Widget child;
  const ZTab({
    this.text,
    required this.type,
    required this.child,
    this.value,
    this.imgType,
  });
}

class ZTabIcon extends ZTab {
  final Icon icon;

  ZTabIcon({required this.icon, super.text})
    : super(type: ZType.icon, child: icon);
}

class ZTabImage extends ZTab {
  final String path;
  final ZImageType imgType;
  ZTabImage({required this.path, this.imgType = ZImageType.asset, super.text})
    : super(
        type: ZType.image,
        child: Container(),
        imgType: imgType,
        value: path,
      );
}

enum ZType { icon, image }

enum ZImageType { asset, network, file, svgAsset, svgNetwork }
