// ignore_for_file: avoid_print

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class FileDownloader {
  final Dio _dio = Dio();
  Future<String?> get savePath async {
    Directory? dir = await getApplicationSupportDirectory();
    return dir.path;
  }

  Future<File?> downloadFile(
    String url,
    ValueChanged<double>? downloadProgress,
  ) async {
    try {
      String? path = await savePath;
      if (path == null) return null;
      final Directory downloadDir = await Directory("$path/M3UDATA").create();

      if (!(await downloadDir.exists())) return null;
      print(url.replaceAll("http://", ""));
      return await _dio
          .downloadUri(
            Uri.parse(url),
            "${downloadDir.path}/data.m3u",
            onReceiveProgress:
                downloadProgress != null
                    ? (int received, int total) {
                      if (total != -1) {
                        downloadProgress(
                          double.parse(
                            (received / total * 100).floor().toString(),
                          ),
                        );
                      }
                    }
                    : null,
          )
          .then((response) async {
            if (response.statusCode == 200) {
              File ff = File("${downloadDir.path}/data.m3u");
              print(ff.path);
              return ff;
            }
            print("FAILED ");
            return null;
          });
    } on HttpException catch (e) {
      print("HTTP ERROR : $e");
      return null;
    } on DioException catch (e) {
      print("ERROR : ${e.error}");
      return null;
    } on SocketException catch (e) {
      print("NO INTERNET! : $e");
      return null;
    } on OutOfMemoryError {
      print(
        "RUN `flutter clean` and try again, this might've caused out of the heap space.",
      );
      return null;
    }
  }
}
