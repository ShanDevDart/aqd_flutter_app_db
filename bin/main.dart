import 'package:counter/counter.dart';
import 'package:aqueduct/aqueduct.dart';

Future main() async {
  var app = new Application<CounterSink>()
    ..options.configurationFilePath = "config.yaml"
    ..options.port = 8082;
  await app.start();

  print("Application started on port: ${app.options.port}.");
  print("Use Ctrl-C (SIGINT) to stop running the application.");
}