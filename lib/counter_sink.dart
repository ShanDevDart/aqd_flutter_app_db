import 'counter.dart';

import 'controller/identity_controller.dart';
import 'controller/register_controller.dart';
import 'controller/counter_controller.dart';
import 'controller/priceQuotes_controller.dart';
import 'model/user.dart';

/*
note: figure out if you want to store initial migration in git or make user generate it

create database todo_app;
create user todo with password 'todo';
grant all on database todo_app to todo;
aqueduct db generate
aqueduct db upgrade --connect postgres://todo:todo@localhost:5432/todo_app

aqueduct auth add-client --id com.dart.demo --secret abcd --connect postgres://todo:todo@localhost:5432/todo_app

aqueduct serve --port 8082
 */

class CounterSink extends ApplicationChannel {
  ManagedContext context;
  AuthServer authServer;

  @override
  Future prepare() async {
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));

    final config = CounterConfiguration(options.configurationFilePath);
    context = contextWithConnectionInfo(config.database);

    authServer = AuthServer(ManagedAuthDelegate<User>(context));
  }

  @override
  Controller get entryPoint {
    final router = Router();

    /* OAuth 2.0 Resource Owner Grant Endpoint */
    router.route("/auth/token").link(() => AuthController(authServer));

    router.route("/tzinfo").linkFunction((request) async {
      var now = new DateTime.now();
      return new Response.ok({"tzinfo": "TZ Name : " + now.timeZoneName.toString() + ", TZ Offset : " + now.timeZoneOffset.toString() + ", Time : " + now.hour.toString() + ":" + now.minute.toString() +":"+ now.second.toString()});
    });

    router.route("/time").linkFunction((request) async {
      var now = new DateTime.now();
      return new Response.ok({"time": now.hour.toString() + ":" + now.minute.toString() +":"+ now.second.toString()});
    });

    /* Gold price generator */
    router.route("/getpq/:productType").link(() => PriceQuotesController());

    /* Create an account */
    router
        .route("/register")
        .link(() => Authorizer.basic(authServer))
        .link(() => RegisterController(context, authServer));

    /* Gets profile for user with bearer token */
    router
        .route("/me")
        .link(() => Authorizer.bearer(authServer))
        .link(() => IdentityController(context));

    /* Creates, updates, deletes and gets notes */
    router
        .route("/counter")
        .link(() => Authorizer(authServer))
        .link(() => new CounterController(context,authServer));

router
      .route("/*")
.link(() => ReroutingFileController("web"));

    return router;
  }

  /*
   * Helper methods
   */

  ManagedContext contextWithConnectionInfo(
      DatabaseConfiguration connectionInfo) {
    var dataModel = new ManagedDataModel.fromCurrentMirrorSystem();
    var psc = new PostgreSQLPersistentStore.fromConnectionInfo(
        connectionInfo.username,
        connectionInfo.password,
        connectionInfo.host,
        connectionInfo.port,
        connectionInfo.databaseName);

    return new ManagedContext(dataModel, psc);
  }

  /*
   * Overrides
   */

/*
  @override
  Map<String, APISecurityScheme> documentSecuritySchemes(
      PackagePathResolver resolver) {
    return authServer.documentSecuritySchemes(resolver);
  }
  */
}

class CounterConfiguration extends Configuration {
  CounterConfiguration(String fileName) : super.fromFile(File(fileName));

  DatabaseConfiguration database;
}

class ReroutingFileController extends FileController {
  ReroutingFileController(String directory) : super(directory);

  @override
  Future<RequestOrResponse> handle(Request req) async {
    Response potentialResponse = await super.handle(req);
    var acceptsHTML =
        req.raw.headers.value(HttpHeaders.acceptHeader).contains("text/html");

    if (potentialResponse.statusCode == 404 && acceptsHTML) {
      return new Response(
          302,
          {
            HttpHeaders.locationHeader: "/",
            "X-JS-Route": req.path.remainingPath
          },
          null);
    }

    return potentialResponse;
  }
}
