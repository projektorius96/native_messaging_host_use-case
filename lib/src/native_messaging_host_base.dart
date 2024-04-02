import 'dart:convert' as dart_converter;
import 'dart:typed_data' as dart_buffer;

encodeMessage(message) {
  // Encode the message to JSON string
  final jsonString = dart_converter.jsonEncode(message);

  // hard-coded offset
  final offset = 4;

  // Allocate a buffer with space for message length and data
  final bufferLength = jsonString.length + offset;
  final buffer = dart_buffer.Uint8List(bufferLength);

  // Explicitly write message length at idiomatic buffer[index:=0] with 32-bit host endian (most likely little endian)
  buffer.buffer
      .asByteData()
      .setUint32(0, jsonString.length, dart_buffer.Endian.host);

  // Copy encoded data to the buffer
  buffer.setAll(offset, jsonString.codeUnits);

  return buffer;
}

decodeMessage(buffer) {
  // Read message length with letting Dart VM itself to decide what Endian to use with respect tho host (most likely little endian)
  final messageLength =
      buffer.buffer.asByteData().getInt32(0, dart_buffer.Endian.host);

  // hard-coded offset
  final offset = 4;

  // Get the payload without the 32-bit prefix
  final payload = buffer.sublist(offset, messageLength + offset);

  // Decode the payload from UTF-8 to a string
  final jsonString = dart_converter.jsonDecode(payload.toString());

  return jsonString;
}
