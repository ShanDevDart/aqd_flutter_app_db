import 'package:counter/model/user.dart';
import 'package:counter/counter.dart';
import 'package:aqueduct_test/aqueduct_test.dart';

export 'package:counter/counter.dart';
export 'package:aqueduct_test/aqueduct_test.dart';
export 'package:test/test.dart';
export 'package:aqueduct/aqueduct.dart';

/// A harness for testing an aqueduct application. Example test file:
///
///         void main() {
///           Harness harness = Harness()..install();
///
///           test("Make request", () async {
///             final response = await harness.agent.get("/path");
///             expectResponse(response, 200);
///           });
///         }
///
/// Use instances of this class to start/stop the test aqd_flutter_app_db server. Use [client] to execute
/// requests against the test server.  This instance will use configuration values
/// from config.src.yaml.
class Harness extends TestHarness<CounterSink> with TestHarnessAuthMixin<CounterSink>, TestHarnessORMMixin {
  @override
  ManagedContext get context => channel.context;

  @override
  AuthServer get authServer => channel.authServer;

  Agent publicAgent;

  @override
  Future onSetUp() async {
    // add initialization code that will run once the test application has started
    await resetData();

    publicAgent = await addClient("com.aqueduct.public");
  }

  Future<Agent> registerUser(User user, {Agent withClient}) async {
    withClient ??= publicAgent;

    final req = withClient.request("/register")
      ..body = {"username": user.username, "password": user.password};
    await req.post();

    return loginUser(withClient, user.username, user.password);
  }
}
