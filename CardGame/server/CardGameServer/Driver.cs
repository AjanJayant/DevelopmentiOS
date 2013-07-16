using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PNServerTest {
    class Driver {
        static void Main(string[] args) {
            Server.init();
            Console.WriteLine("Press any key to kill the server...");
            Console.ReadKey();
        }
    }
}
