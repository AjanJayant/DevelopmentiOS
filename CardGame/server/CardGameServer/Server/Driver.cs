using CardGame.GameElements;
using HoldemHand;
using System;
using System.Linq;

namespace CardGame.Server {
    internal class Driver {

        private static void DeckTest() {
            Deck a = new Deck();
            Deck b = new Deck();
            while (!a.IsEmpty && !b.IsEmpty) {
                Console.WriteLine("{0} --- {1}", a.Draw().Serialize(), b.Draw().Serialize());
            }
        }

        private static void HandTest() {
            Deck d = new Deck();
            Card[] pocket = { d.Draw(), d.Draw() };
            Card[] community = { d.Draw(), d.Draw(), d.Draw(), d.Draw(), d.Draw() };
            Console.WriteLine("{0}\n{1}", String.Join("\n", pocket.Select(card => card.ToString())),
                String.Join("\n", community.Select(card => card.ToString())));
            Console.WriteLine(
                new Hand(String.Join(" ", pocket.Select(card => card.Serialize(true))),
                    String.Join(" ", community.Select(card => card.Serialize(true)))).Description);
        }

        private static void TestGame() {
            Deck d = new Deck();
            Player p = new Player("Robot1", "Robot1");
            Player q = new Player("Robot2", "Robot2");
            p.SetPocket(d.Draw(), d.Draw());
            q.SetPocket(d.Draw(), d.Draw());
            Card[] community = { d.Draw(), d.Draw(), d.Draw(), d.Draw(), d.Draw() };
            Console.WriteLine(p.FindBestHand(SerializeCommunity(community)).Description);
            Console.WriteLine(q.FindBestHand(SerializeCommunity(community)).Description);
        }

        private static string SerializeCommunity(Card[] community) {
            return String.Join(" ", community
                .Where(card => card != null)
                .Select(card => card.Serialize(true)));
        }

        private static void Main(string[] args) {
            Server.Init();
            Console.WriteLine("Commands: cleardb, decktest, handtest, quit");
            string input;
            do {
                input = Console.ReadLine();
                //Console.Beep(r.Next(37, 20000), 300);
                switch (input) {
                    case "cleardb":
                        Console.WriteLine(Database.getInstance().clear() + " rows deleted.");
                        break;
                    case "decktest":
                        DeckTest();
                        break;
                    case "handtest":
                        HandTest();
                        break;
                    case "gametest":
                        TestGame();
                        break;
                }
            } while (input != null && (input.Length == 0 || !"quit".StartsWith(input)));
        }
    }
}