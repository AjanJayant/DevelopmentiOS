using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CardGame {
    class Driver {
        static void deckTest() {
            Deck a = new Deck();
            Deck b = new Deck();
            while (!a.IsEmpty && !b.IsEmpty) {
                Console.WriteLine("{0} --- {1}", a.draw().ToString().PadRight(17, ' '), b.draw());
            }
        }

        static void Main(string[] args) {
            Server.init();
            Console.WriteLine("Commands: cleardb, decktest, quit");
            string input;
            do {
                input = Console.ReadLine();
                if (input == "cleardb") {
                    Console.WriteLine(Database.getInstance().clear() + " rows deleted.");
                }
                else if (input == "decktest") {
                    deckTest();
                }
            } while (input.Length == 0 || !"quit".StartsWith(input));
        }
    }
}
