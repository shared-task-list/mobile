const initScript = [
  '''
  CREATE TABLE if not exists tasks (
    Uid TEXT PRIMARY KEY,
    Title TEXT,
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
    name TEXT,
    password TEXT,
    updated_at TEXT
  );
  ''',
  '''
  CREATE TABLE if not exists categories (
    id INTEGER PRIMARY KEY,
    name TEXT
  );
  ''',
];
const tables = [
  'tasks',
  'task_lists',
  'categories',
];
final scriptMap = {
  'tasks': initScript[0],
  'task_lists': initScript[1],
  'categories': initScript[2],
};
const migrationScripts = [
  '''
  CREATE TABLE if not exists categories (
    id INTEGER PRIMARY KEY,
    name Text
  );
  ''',
  '''
  alter table task_lists add updated_at text;
  ''',
];
