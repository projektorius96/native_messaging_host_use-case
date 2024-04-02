import 'dart:io' as dart_io;
import 'package:native_messaging_host/native_messaging_host.dart' show decodeMessage;

void main(List<String> arguments) {
  // Define the path to the log file
  var logFilePath = 'main.log';

  // Create a File object for the log file
  var logFile = dart_io.File(logFilePath);

  // Open the log file in write mode and create it if it doesn't exist
  var sink = logFile.openWrite(mode: dart_io.FileMode.append);

  dart_io.stdin.listen((data) {
    /// DEV_NOTE # somewhy [String.fromCharCodes] forces Chrome to exit native messaging host with Error: Native host has exited.
    /* sink.write( String.fromCharCodes(decodeMessage(data)) ); */// DOES NOT WORK
    
    /// [cont'd] # yet calling sink.write( decodeMessage(data) ) writes [123, 34, 116, 101, 120, 116, 34, 58, 34, 72, 101, 108, 108, 111, 34, 125] to .\\bin\\main.log
    sink.write(decodeMessage(data)); // WORKS JUST FINE
  });

  // Graceful termination on Ctrl+C (SIGINT), see [cont'd] below
  dart_io.ProcessSignal.sigint.watch().listen((signal) {
    // Close the log file
    sink.close();

    // [cont'd]
    dart_io.exit(0);
  });
}
