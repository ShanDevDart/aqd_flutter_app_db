import '../counter.dart';
import '../model/user.dart';

class RegisterController extends QueryController<User> {
  RegisterController(ManagedContext context, this.authServer) : super(context);

  final AuthServer authServer;

  @Operation.post()
  Future<Response> createUser() async {
    if (query.values.username == null || query.values.password == null) {
      return new Response.badRequest(
          body: {"error": "username and password required."});
    }

    query.values.username = query.values.username.toLowerCase();

    var salt = AuthUtility.generateRandomSalt();
    var hashedPassword =
        AuthUtility.generatePasswordHash(query.values.password, salt);

    query.values.hashedPassword = hashedPassword;
    query.values.salt = salt;
    query.values.email = query.values.username;

    var u = await query.insert();
    var token = await authServer.authenticate(
        u.username,
        query.values.password,
        request.authorization.credentials.username,
        request.authorization.credentials.password);

    return AuthController.tokenResponse(token);
  }
}
