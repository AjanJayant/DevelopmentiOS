using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.SQLite;

namespace PNServerTest {
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

        public int addUser(string name) {
            SQLiteConnection conn = new SQLiteConnection(this.dataSource);
            SQLiteCommand cmd = new SQLiteCommand(conn);
            int rowsAffected = 0;
            try {
                cmd.CommandText = "INSERT INTO users(name, wins) VALUES ('" + name + "', 0);";
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

    }
}
