using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CardGame {
    class Driver {
        static void Main(string[] args) {
            //Deck a = new Deck();
            //Deck b = new Deck();
            //while (!a.IsEmpty && !b.IsEmpty) {
            //    Console.WriteLine("{0} --- {1}", a.draw(), b.draw());
            //}
            Server.init();
            Console.WriteLine("Press any key to kill the server...");
            Console.ReadKey();
        }
    }
}
