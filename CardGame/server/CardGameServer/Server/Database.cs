using System;
using System.IO;
using System.Data.SQLite;
using System.Reflection;
using CardGame.GameElements;

//TODO: Parameterize SQL commands

namespace CardGame.Server {
    class Database {
        private static Database instance;
        public static Database getInstance() {
            return instance ?? (instance = new Database());
        }
        private readonly string dataSource;

        private Database() {
            //this.dataSource = String.Format("Data Source=C:\\cygwin\\home\\Taylor\\pubnub\\DevelopmentiOS\\CardGame\\server\\CardGameServer\\database.sqlite");
            string[] delim = {"file:///"};
            string dir = Assembly.GetExecutingAssembly().CodeBase;
            this.dataSource = String.Format("Data Source={0}{1}{2}", Path.GetDirectoryName(dir.Split(delim, StringSplitOptions.None)[1]), Path.DirectorySeparatorChar, "game-database.sqlite");
            Console.WriteLine("Database created");
        }

        private int execNonQuery(string sql) {
            SQLiteConnection conn = new SQLiteConnection(this.dataSource);
            SQLiteCommand cmd = new SQLiteCommand(conn);
            int rowsAffected = 0;
            try {
                cmd.CommandText = sql;
                cmd.Prepare();
                conn.Open();
                rowsAffected = cmd.ExecuteNonQuery();
            }
            catch (SQLiteException e) {
                Console.WriteLine("SQLite exception: {0}", e);
            }
            finally {
                conn.Close();
            }

            return rowsAffected;
        }

        private string execScalar(string sql) {
            SQLiteConnection conn = new SQLiteConnection(this.dataSource);
            SQLiteCommand cmd = new SQLiteCommand(conn);
            object result = null;
            try {
                cmd.CommandText = sql;
                cmd.Prepare();
                conn.Open();
                result = cmd.ExecuteScalar();
            }
            catch (SQLiteException e) {
                Console.WriteLine("SQLite exception: {0}", e);
            }
            finally {
                conn.Close();
            }

            return result != null ? result.ToString() : "";
        }

        public int clear() {
            return this.execNonQuery("DELETE FROM users;");
        }

        public Player addUser(string username, string uuid) {
            int startingFunds = 100;
            return (this.execNonQuery(String.Format("INSERT INTO users(name, uuid, handsWon, funds, handsPlayed, lifetimeWinnings, highestBet) VALUES ('{0}', '{1}', 0, {2}, 0, 0, 0);", username, uuid, startingFunds)) == 1)
                ? new Player(username, uuid, startingFunds, 0, 0, 0, 0) : null;
        }

        public bool userExists(string username) {
            return "" != this.execScalar(String.Format("SELECT name FROM users WHERE name='{0}';", username));
        }

        public bool authenticateUser(string username, string uuid) {
            return uuid == this.execScalar(String.Format("SELECT uuid FROM users WHERE name='{0}';", username));
        }

        public Player loadPlayer(string uuid) {
            SQLiteConnection conn = new SQLiteConnection(this.dataSource);
            SQLiteCommand cmd = new SQLiteCommand(conn);
            Player loaded = null;
            try {
                cmd.CommandText = String.Format("SELECT * FROM users WHERE uuid='{0}';", uuid);
                cmd.Prepare();
                conn.Open();
                SQLiteDataReader reader = cmd.ExecuteReader();
                while (reader.Read()) {
                    loaded = new Player(reader.GetString(reader.GetOrdinal("name")), uuid,
                        reader.GetInt32(reader.GetOrdinal("funds")),
                        reader.GetInt32(reader.GetOrdinal("handsWon")), reader.GetInt32(reader.GetOrdinal("lifetimeWinnings")),
                        reader.GetInt32(reader.GetOrdinal("handsPlayed")),
                        reader.GetInt32(reader.GetOrdinal("highestBet")));
                }
                reader.Close();
            }
            catch (SQLiteException e) {
                Console.WriteLine("SQLite exception: {0}", e);
            }
            finally {
                conn.Close();
            }
            return loaded;
        }



        public int loadFunds(string uuid) {
            int funds = 0;
            int.TryParse(this.execScalar(String.Format("SELECT funds FROM users WHERE uuid='{0}';", uuid)), out funds);
            return funds;
        }

        public int loadWins(string uuid) {
            int wins = 0;
            int.TryParse(this.execScalar(String.Format("SELECT handsWon FROM users WHERE uuid='{0}';", uuid)), out wins);
            return wins;
        }

        public bool savePlayer(Player p) {
            return (this.execNonQuery(String.Format("UPDATE users SET funds={1}, handsWon={2}, handsPlayed={3}, lifetimeWinnings={4}, highestBet={5} WHERE uuid='{0}';", p.Uuid, p.Funds, p.HandsWon, p.HandsPlayed, p.LifetimeWinnings, p.HighestBet)) == 1);
        }

    }
}
