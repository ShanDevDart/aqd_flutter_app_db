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
  @managedPrimaryKey
  int id;

  int counter;

  @ManagedColumnAttributes(indexed: true)
  DateTime createdAt;

  @ManagedColumnAttributes(indexed: true)
  DateTime updatedAt;

  @ManagedRelationship(#counter, onDelete: ManagedRelationshipDeleteRule.cascade, isRequired: true)
  User owner;
}
