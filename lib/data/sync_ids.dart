import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// A szerver uuid oszlopokat vár. Az Apple Health azonosítókból determinisztikus
/// uuid5-öt készítünk, hogy ne legyen ütközés a helyi deduplikációval.
String ensureSyncId(String id) {
  if (id.isEmpty) {
    return _uuid.v4();
  }
  if (Uuid.isValidUUID(fromString: id)) {
    return id;
  }
  return _uuid.v5(Namespace.url.value, "flexio:$id");
}

bool isValidSyncId(String id) => Uuid.isValidUUID(fromString: id);
