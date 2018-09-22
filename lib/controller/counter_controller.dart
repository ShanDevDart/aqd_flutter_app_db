import '../counter.dart';
import '../model/counter.dart';
import '../model/user.dart';

class CounterController extends HTTPController {
  CounterController(this.authServer);

  AuthServer authServer;

  @httpGet
  Future<Response> getCounters(
      {@HTTPQuery("created_after") DateTime createdAfter}) async {
    print('Inside GetCounters route');
    var query = new Query<Counter>()
      ..where.owner.id =
          whereEqualTo(request.authorization.resourceOwnerIdentifier);

    if (createdAfter != null) {
      query.where.createdAt = whereGreaterThan(createdAfter);
    }

    return new Response.ok(await query.fetch());
  }

  @httpGet
  Future<Response> getCounter() async {
    print('Inside GetCounter route');
    var requestingUserID = request.authorization.resourceOwnerIdentifier;
    var query = new Query<Counter>()
      ..where.owner.id = whereEqualTo(requestingUserID);

    var c = await query.fetchOne();
    if (c == null) {
      return new Response.notFound();
    }

    return new Response.ok(c);
  }

  @httpPost
  Future<Response> createCounter(@HTTPBody() Counter counter) async {
    print('Inside createCounter route');
    counter.owner = new User()
      ..id = request.authorization.resourceOwnerIdentifier;

    var query = new Query<Counter>()..values = counter;

    return new Response.ok(await query.insert());
  }

  @httpPut
  Future<Response> updateCounter(
      @HTTPBody() Counter counter) async {
    print('Inside UpdateCounter route');
    var requestingUserID = request.authorization.resourceOwnerIdentifier;
    var query = new Query<Counter>()
      ..where.owner.id = whereEqualTo(requestingUserID)
      ..values = counter;

    var u = await query.updateOne();
    if (u == null) {
      return new Response.notFound();
    }

    return new Response.ok(u);
  }

  @httpDelete
  Future<Response> deleteCounter(@HTTPPath("id") int id) async {
    print('Inside deleteCounter route');
    var requestingUserID = request.authorization.resourceOwnerIdentifier;
    var query = new Query<Counter>()
      ..where.id = whereEqualTo(id)
      ..where.owner.id = whereEqualTo(requestingUserID);

    if (await query.delete() > 0) {
      return new Response.ok(null);
    }

    return new Response.notFound();
  }
}
