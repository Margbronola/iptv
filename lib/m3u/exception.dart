class InvalidFormatException implements Exception {
  InvalidFormatException(
    this.formatType, {
    this.originalValue,
    this.customMessage,
  }) : super();
  InvalidFormatType formatType;
  String? originalValue;
  String? customMessage;

  @override
  String toString() {
    final finalMessage = StringBuffer('');

    switch (formatType) {
      case InvalidFormatType.header:
        finalMessage.writeln('Invalid Header found');
        break;
      default:
    }

    if (originalValue != null) {
      finalMessage
        ..write('Value: [')
        ..write(originalValue)
        ..writeln(']');
    }

    if (customMessage != null) {
      finalMessage.writeln(customMessage);
    }
    return finalMessage.toString();
  }
}

enum InvalidFormatType { header, other }
