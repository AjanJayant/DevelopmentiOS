using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.SQLite;

namespace PNServerTest {
    class DBConnector {
        private static DBConnector instance;
        public static DBConnector getInstance() {
            if (instance == null) {
                instance = new DBConnector();
            }
            return instance;
        }

        private string database;

        private DBConnector() {
            this.database = "Data Source=c:\\users\\taylor\\documents\\visual studio 2012\\Projects\\PNServerTest\\PNServerTest\\database.sqlite";
            Console.WriteLine("DBConnector created");
        }

        public int addUser(string name) {
            SQLiteConnection conn = new SQLiteConnection(this.database);
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
