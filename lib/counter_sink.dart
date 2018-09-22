import 'counter.dart';

import 'controller/identity_controller.dart';
import 'controller/register_controller.dart';
import 'controller/counter_controller.dart';
import 'controller/goldPrice_controller.dart';
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

class CounterSink extends RequestSink {
  CounterSink(ApplicationConfiguration appConfig) : super(appConfig) {
    logger.onRecord.listen((rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));

    var options = new TodoConfiguration(appConfig.configurationFilePath);

    ManagedContext.defaultContext = contextWithConnectionInfo(options.database);

    var authStorage = new ManagedAuthStorage<User>(ManagedContext.defaultContext);
    authServer = new AuthServer(authStorage);
  }

  AuthServer authServer;

  static Future initializeApplication(ApplicationConfiguration appConfig) async {
    if (appConfig.configurationFilePath == null) {
      throw new ApplicationStartupException(
          "No configuration file found. See README.md.");
    }
  }

  @override
  void setupRouter(Router router) {
    /* OAuth 2.0 Resource Owner Grant Endpoint */
    router.route("/auth/token").generate(() => new AuthController(authServer));
    
    router
      .route("/example")
      .listen((request) async {
        return new Response.ok({"key": "Hello World"});
      });

    /* Gold price generator */
    router
        .route("/gold")
        .generate(() => new GoldPriceController());

    /* Create an account */
    router
        .route("/register")
        .pipe(new Authorizer.basic(authServer))
        .generate(() => new RegisterController(authServer));

    /* Gets profile for user with bearer token */
    router
        .route("/me")
        .pipe(new Authorizer.bearer(authServer))
        .generate(() => new IdentityController());

    /* Creates, updates, deletes and gets notes */
    router
        .route("/counter")
        .pipe(new Authorizer(authServer))
        .generate(() => new CounterController(authServer));

    router
      .route("/*")
      .pipe(new ReroutingFileController("web"));
  }

  /*
   * Helper methods
   */

  ManagedContext contextWithConnectionInfo(
      DatabaseConnectionConfiguration connectionInfo) {
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

  @override
  Map<String, APISecurityScheme> documentSecuritySchemes(
      PackagePathResolver resolver) {
    return authServer.documentSecuritySchemes(resolver);
  }
}

class TodoConfiguration extends ConfigurationItem {
  TodoConfiguration(String fileName) : super.fromFile(fileName);

  DatabaseConnectionConfiguration database;
}


class ReroutingFileController extends HTTPFileController {
  ReroutingFileController(String directory) : super(directory);

  @override
  Future<RequestOrResponse> processRequest(Request req) async {
    Response potentialResponse = await super.processRequest(req);
    var acceptsHTML = req.innerRequest
        .headers.value(HttpHeaders.ACCEPT).contains("text/html");

    if (potentialResponse.statusCode == 404 && acceptsHTML)  {
        return new Response(302, {
          HttpHeaders.LOCATION: "/",
          "X-JS-Route": req.path.remainingPath
        }, null);
    }

    return potentialResponse;
  }
}