// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:seizhiptv/m3u/entry_info.dart';
import 'package:seizhiptv/m3u/enum.dart';
import 'package:seizhiptv/m3u/exception.dart';
import 'package:seizhiptv/m3u/file_type.dart';
import 'package:seizhiptv/m3u/m3u_entry.dart';
import 'package:seizhiptv/m3u/m3u_extension.dart';

class M3uParser {
  M3uParser._pr();
  static final M3uParser _instance = M3uParser._pr();
  static M3uParser get instance => _instance;
  Future<List<M3uEntry>> parse(String source) async => _parse(source);

  FileTypeHeader? _fileType;

  LineParsedType _nextLineExpected = LineParsedType.header;

  EntryInfo? _currentInfoEntry;

  static Map<String, List<M3uEntry>> sortedCategories({
    required List<M3uEntry> entries,
    required String attributeName,
    String defaultAttribute = 'other',
  }) => entries.fold(<String, List<M3uEntry>>{}, (acc, current) {
    final property = current.attributes[attributeName] ?? defaultAttribute;

    if (!acc.containsKey(property)) {
      acc[property] = [current];
    } else {
      acc[property]!.add(current);
    }
    return acc;
  });
  final List<M3uEntry> _playlist = <M3uEntry>[];
  Future<List<M3uEntry>> _parse(String source) async {
    LineSplitter.split(source).forEach(_parseLine);
    return _playlist;
  }

  void _parseLine(String line) {
    switch (_nextLineExpected) {
      case LineParsedType.header:
        _fileType = FileTypeHeader.fromString(line);
        _nextLineExpected = LineParsedType.info;
        break;
      case LineParsedType.info:
        final parsedEntry = _parseInfoRow(line, _fileType);
        if (parsedEntry == null) {
          break;
        }
        _currentInfoEntry = parsedEntry;
        _nextLineExpected = LineParsedType.source;
        break;
      case LineParsedType.source:
        if (_currentInfoEntry == null) {
          _nextLineExpected = LineParsedType.info;
          _parseLine(line);
          break;
        }
        _playlist.add(
          M3uEntry.fromEntryInformation(
            information: _currentInfoEntry!,
            link: line,
            type: line.toString().getType,
          ),
        );
        _currentInfoEntry = null;
        _nextLineExpected = LineParsedType.info;
        break;
    }
  }

  EntryInfo? _parseInfoRow(String line, FileTypeHeader? fileType) {
    switch (fileType) {
      case FileTypeHeader.m3u:
        return _regexParse(line);
      case FileTypeHeader.m3uPlus:
        return _regexParse(line);
      default:
        throw InvalidFormatException(
          InvalidFormatType.other,
          originalValue: line,
        );
    }
  }

  EntryInfo _regexParse(String line) {
    final regexExpression = RegExp(r' (.*?)=\"(.*?)"|,(.*)');
    final matches = regexExpression.allMatches(line);
    final attributes = <String, String?>{};
    String? title = '';

    for (var match in matches) {
      if (match[1] != null && match[2] != null) {
        attributes[match[1]!] = match[2];
      } else if (match[3] != null) {
        title = match[3];
      } else {
        print('ERROR regexing against -> ${match[0]}');
      }
    }
    return EntryInfo(title: title!, attributes: attributes, duration: -1);
  }
}
