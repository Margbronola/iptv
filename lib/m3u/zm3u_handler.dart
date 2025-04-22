// ignore_for_file: avoid_print

library z_m3u_handler;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:seizhiptv/m3u/categorized_m3u_data.dart';
import 'package:seizhiptv/m3u/extension.dart';
import 'package:seizhiptv/m3u/file_downloader.dart';
import 'package:seizhiptv/m3u/m3u_entry.dart';
import 'package:seizhiptv/m3u/m3u_handler.dart';
import 'package:seizhiptv/m3u/parser.dart';

class ZM3UHandler {
  ZM3UHandler._pr();
  static final ZM3UHandler _instance = ZM3UHandler._pr();
  static ZM3UHandler get instance => _instance;
  static final M3uFirestoreServices _firestore = M3uFirestoreServices();
  Future<File?> network(
    String url, {
    ValueChanged<double>? progressCallback,
    VoidCallback? onFinished,
  }) async {
    try {
      return await _downloader.downloadFile(url, progressCallback);
    } catch (e) {
      return null;
    }
  }

  Future<CategorizedM3UData?> getData(File file) async {
    try {
      final String data = await file.readAsString();
      final List<M3uEntry> _res = await _parse(data);
      return CategorizedM3UData(
        live: _res
            .where((element) => element.link.getType <= 1)
            .toList()
            .sortedCategories(attributeName: "group-title"),
        movies: _res
            .where((element) => element.link.getType == 2)
            .toList()
            .sortedCategories(attributeName: "group-title"),
        series: _res
            .where((element) => element.link.getType == 3)
            .toList()
            .sortedCategories(attributeName: "group-title"),
      );
    } catch (e, s) {
      print("Error pag get data : $e ");
      print("STCKTRC : $s");
      return null;
    }
  }
  // Future<CategorizedM3UData?> network(
  //   String url,
  //   ValueChanged<double> progressCallback, {
  //   VoidCallback? onFinished,
  //   ValueChanged<double>? onExtractionCallback,
  // }) async {
  //   try {
  //     final File? _file = await _downloader.downloadFile(
  //       url,
  //       progressCallback,
  //     );
  //     if (_file == null) return null;
  //     final String data = await _file.readAsString();
  //     // await _file.delete();
  //     final List<M3uEntry> _res = await _parse(data);
  //     // await _extract(_res, extractionProgressCallback: onExtractionCallback);
  //     if (onFinished != null) {
  //       onFinished();
  //     }
  //     // return await savedData;
  //   } catch (e, s) {
  //     return null;
  //   }
  // }

  // Future<CategorizedM3UData?> file(File file,
  //     {required VoidCallback onFinished,
  //     ValueChanged<double>? extractionProgressCallback}) async {
  //   try {
  //     final String data = await file.readAsString();
  //     final List<M3uEntry> _res = await _parse(data);
  //     // await _extract(_res,
  //     //     extractionProgressCallback: extractionProgressCallback);
  //     // onFinished();
  //     // return await savedData;
  //   } catch (e) {
  //     return null;
  //   }
  // }

  // Future<void> _extract(List<M3uEntry> data,
  //     {ValueChanged<double>? extractionProgressCallback}) async {
  //   try {
  //     assert(data.isNotEmpty, "DATA RETURNED IS EMPTY");
  //     await _dbHandler.clearTable();
  //     Map<String, List<M3uEntry>> _cats =
  //         data.categorize(needle: "group-title");
  //     final entries = _cats.entries.toList();
  //     final numEntries = entries.length;
  //     for (var i = 0; i < numEntries; i++) {
  //       final mentry = entries[i];
  //       final catId = await _dbHandler.addCategory(mentry.key);
  //       final List<M3uEntry> genEnts = mentry.value;
  //       print(genEnts.length);
  //       for (M3uEntry entry in genEnts) {
  //         await _dbHandler.addEntry(catId, entry);
  //       }
  //       if (extractionProgressCallback != null) {
  //         extractionProgressCallback((i / numEntries) * 100);
  //       }
  //     }
  //     return;
  //   } catch (e, s) {
  //     rethrow;
  //   }
  // }

  // // Future<CategorizedM3UData?> get savedData async {
  // //   try {
  // //     return await _dbHandler.getData();
  // //   } catch (e) {
  // //     return null;
  // //   }
  // // }

  // ///Fetch data from firestore
  // ///[type] is the collection name
  // ///from firestore database
  Future<CategorizedM3UData?> getDataFrom({
    required CollectionType type,
    required String refId,
  }) async {
    return await _firestore.getDataFrom(
      refId,
      collection:
          type == CollectionType.favorites ? "user-favorites" : "user-history",
    );
  }

  static final FileDownloader _downloader = FileDownloader();

  static final M3uParser _parser = M3uParser.instance;
  // static final DBHandler _dbHandler = DBHandler.instance;
  Future<List<M3uEntry>> _parse(String source) async {
    return await _parser.parse(source);
  }
}

enum CollectionType { favorites, history }
