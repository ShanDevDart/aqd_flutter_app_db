import '../counter.dart';
import 'user.dart';

class Counter extends ManagedObject<_Counter> implements _Counter {
  @override
  void willUpdate() {
    updatedAt = new DateTime.now().toUtc();
  }

  @override
  void willInsert() {
    createdAt = new DateTime.now().toUtc();
    updatedAt = new DateTime.now().toUtc();
  }
}

class _Counter {
  @primaryKey
  int id;

  int counter;

  @Column(indexed: true)
  DateTime createdAt;

  @Column(indexed: true)
  DateTime updatedAt;

  @Relate(#counter, onDelete: DeleteRule.cascade, isRequired: true)
  User owner;
}
