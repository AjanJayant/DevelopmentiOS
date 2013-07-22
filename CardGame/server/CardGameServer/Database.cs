using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.SQLite;

namespace CardGame {
    class Database {
        private static Database instance;
        public static Database getInstance() {
            if (instance == null) {
                instance = new Database();
            }
            return instance;
        }

        private string dataSource;

        private Database() {
            this.dataSource = "Data Source=C:\\cygwin\\home\\Taylor\\pubnub\\DevelopmentiOS\\CardGame\\server\\CardGameServer\\database.sqlite";
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
            catch(SQLiteException e) {
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
            catch(SQLiteException e) {
                Console.WriteLine("SQLite exception: {0}", e);
            }
            finally {
                conn.Close();
            }

            if (result != null) {
                return result.ToString();
            }

            return "";
        }

        public bool addUser(string name, string uuid) {
          return (this.execNonQuery(String.Format("INSERT INTO users(name, uuid, wins) VALUES ('{0}', '{1}', 0);", name, uuid)) == 1);
        }

        public bool checkUser(string uuid) {
            return false;
        }

    }
}
