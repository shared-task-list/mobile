const initScript = [
  '''
  CREATE TABLE if not exists tasks (
    Uid TEXT PRIMARY KEY,
    Title Text,
    AuthorUid TEXT,
    Author TEXT,
    Category TEXT,
    Comment TEXT,
    IsDone INTEGER,
    Timestamp TEXT
  );
  ''',
  '''
  CREATE TABLE if not exists task_lists (
    id INTEGER PRIMARY KEY,
    name Text,
    password TEXT
  );
  ''',
  '''
  CREATE TABLE if not exists categories (
    id INTEGER PRIMARY KEY,
    name Text
  );
  ''',
];
const migrationScripts = [
  '''
  CREATE TABLE if not exists categories (
    id INTEGER PRIMARY KEY,
    name Text
  );
  ''',
];
