import '../counter.dart';
import '../model/counter.dart';
import '../model/user.dart';

class CounterController extends ResourceController {
  CounterController(this.context, this.authServer);

  final AuthServer authServer;
  final ManagedContext context;

/*
  @Operation.get()
  Future<Response> getCounters(
      {@Bind.query("created_after") DateTime createdAfter}) async {
    print('Inside GetCounters route');
    var query = Query<Counter>(context)
..where((n) => n.owner).identifiedBy(request.authorization.ownerID);

    if (createdAfter != null) {
      query.where((n) => n.createdAt).greaterThan(createdAfter);
    }

    return new Response.ok(await query.fetch());
  }
*/
  @Operation.get()
  Future<Response> getCounter() async {
    print('Inside GetCounter route');
    var requestingUserID = request.authorization.ownerID;
    var query = new Query<Counter>(context)
      ..where((n) => n.owner).identifiedBy(requestingUserID);
      //..where.owner.id = whereEqualTo(requestingUserID);

    var c = await query.fetchOne();
    if (c == null) {
      return new Response.notFound();
    }

    return new Response.ok(c);
  }

/*
  @httpPost
  Future<Response> createCounter(@HTTPBody() Counter counter) async {
    print('Inside createCounter route');
    counter.owner = new User()
      ..id = request.authorization.resourceOwnerIdentifier;

    var query = new Query<Counter>()..values = counter;

    return new Response.ok(await query.insert());
  }
*/

@Operation.post()
  Future<Response> createNote(@Bind.body() Counter counter) async {
    counter.owner = new User()
      ..id = request.authorization.ownerID;

    return Response.ok(await Query.insertObject(context, counter));
}

/*
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
*/

@Operation.put()
  Future<Response> updateNote(@Bind.body() Counter counter) async {
    var requestingUserID = request.authorization.ownerID;
    var query = Query<Counter>(context)
      ..where((n) => n.owner).identifiedBy(requestingUserID)
      ..values = counter;

    var u = await query.updateOne();
    if (u == null) {
      return Response.notFound();
    }

    return Response.ok(u);
}

/*
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
  */
  @Operation.delete()
  Future<Response> deleteNote() async {
    var requestingUserID = request.authorization.ownerID;
    var query = Query<Counter>(context)
      ..where((n) => n.owner).identifiedBy(requestingUserID);

    if (await query.delete() > 0) {
      return Response.ok(null);
    }

    return Response.notFound();
}
}
