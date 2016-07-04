pragma Singleton
import QtQuick 2.4
import AsemanTools 1.0
import QtQuick.LocalStorage 2.0

AsemanObject {

    function getDatabase() {
        View.offlineStoragePath = AsemanApp.homePath
        var db = LocalStorage.openDatabaseSync("CutegramEmojis", "1.0", "Cutegram emojis database", 10000000);
        return db
    }

    function initDatabase() {
        var db = getDatabase()
        db.transaction(
            function(tx) {
                // Create the database if it doesn't already exist
                tx.executeSql('CREATE TABLE IF NOT EXISTS Emojis(name TEXT, shortname TEXT, unicode TEXT, unicode_alt TEXT, category TEXT, idx INT, PRIMARY KEY (name))');
                tx.executeSql('CREATE INDEX IF NOT EXISTS "Emojis.shortname_idx" ON "Emojis"("shortname")');
                tx.executeSql('CREATE INDEX IF NOT EXISTS "Emojis.unicode_idx" ON "Emojis"("unicode")');
                tx.executeSql('CREATE INDEX IF NOT EXISTS "Emojis.unicode_alt_idx" ON "Emojis"("unicode_alt")');
                tx.executeSql('CREATE INDEX IF NOT EXISTS "Emojis.category_idx" ON "Emojis"("category")');
                tx.executeSql('CREATE INDEX IF NOT EXISTS "Emojis.idx_idx" ON "Emojis"("idx")');

                tx.executeSql('CREATE TABLE IF NOT EXISTS Aliases(alias TEXT, emoji TEXT, PRIMARY KEY (alias, emoji))');
                tx.executeSql('CREATE TABLE IF NOT EXISTS AsciiAliases(asciiAlias TEXT, emoji TEXT, PRIMARY KEY (asciiAlias, emoji))');
                tx.executeSql('CREATE TABLE IF NOT EXISTS Keywords(keyword TEXT, emoji TEXT, PRIMARY KEY (keyword, emoji))');

                var rs = tx.executeSql('SELECT count(*) as count FROM Emojis');
                if(rs.rows.item(0).count == 0) {
                    initData()
                }
            }
        )
    }

    function getCategories(callback) {
        var db = getDatabase()
        db.readTransaction(
            function(tx) {
                // Create the database if it doesn't already exist
                var rs = tx.executeSql('SELECT name, category, unicode, MIN(idx) as minIdx FROM emojis GROUP BY category ORDER BY minIdx');
                var r = []
                for(var i = 0; i < rs.rows.length; i++) {
                    var row = rs.rows.item(i)
                    r[row.category] = {
                        "name": row.name,
                        "unicode": row.unicode
                    }
                }
                callback(r)
            }
        )
    }

    function getAllItems(callback) {
        var db = getDatabase()
        db.readTransaction(
            function(tx) {
                // Create the database if it doesn't already exist
                var rs = tx.executeSql('SELECT name, unicode, category FROM emojis ORDER BY idx');
                var r = []
                for(var i = 0; i < rs.rows.length; i++) {
                    var row = rs.rows.item(i)
                    r[i] = {
                        "category": row.category,
                        "name": row.name,
                        "unicode": row.unicode
                    }
                }
                callback(r)
            }
        )
    }

    function getItems(category, callback) {
        var db = getDatabase()
        db.readTransaction(
            function(tx) {
                // Create the database if it doesn't already exist
                var rs = tx.executeSql('SELECT name, unicode FROM emojis WHERE category=? ORDER BY idx',
                                       [category]);
                var r = []
                for(var i = 0; i < rs.rows.length; i++) {
                    var row = rs.rows.item(i)
                    r[i] = {
                        "category": row.category,
                        "name": row.name,
                        "unicode": row.unicode
                    }
                }
                callback(r)
            }
        )
    }

    function initData() {
        myWorker.source = "../thirdparty/emojicategories.js"
        myWorker.sendMessage({})
    }

    WorkerScript {
        id: myWorker
        onMessage: {
            var message = messageObject
            var db = getDatabase()
            db.transaction(
                function(tx) {
                    tx.executeSql('INSERT OR REPLACE INTO Emojis VALUES(?, ?, ?, ?, ?, ?)',
                                  [message.name, message.shortname, message.unicode, message.unicode_alternates,
                                   message.category, message.emoji_order])

                    var i
                    for(i=0; i<message.aliases.length; i++)
                        tx.executeSql('INSERT OR REPLACE INTO Aliases VALUES(?, ?)',
                                      [message.aliases[i], message.name])
                    for(i=0; i<message.aliases_ascii.length; i++)
                        tx.executeSql('INSERT OR REPLACE INTO AsciiAliases VALUES(?, ?)',
                                      [message.aliases_ascii[i], message.name])
                    for(i=0; i<message.keywords.length; i++)
                        tx.executeSql('INSERT OR REPLACE INTO Keywords VALUES(?, ?)',
                                      [message.keywords[i], message.name])

                })
        }
    }
}

