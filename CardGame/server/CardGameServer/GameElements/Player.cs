using System;
using System.Linq;
using CardGame.Server;
using HoldemHand;

namespace CardGame.GameElements {
    class Player {
        private readonly Card[] pocket = new Card[2];
        private int funds;
        public int Wins;
        public int Bet;
        public bool Folded = false;

        public int Funds {
            get { return this.funds; }
            set { this.funds = Math.Max(0, value); }
        }

        // Properties \\
        public Card Card1 {
            get { return this.pocket[0]; }
        }
        public Card Card2 {
            get { return this.pocket[1]; }
        }

        public string Name { get; private set; }

        public string Uuid { get; private set; }

        /*********************************/

        public Player(string name, string uuid) {
            this.Name = name;
            this.Uuid = uuid;
            // Load funds from db
            this.Funds = Database.getInstance().loadFunds(this.Uuid);
            this.Wins = Database.getInstance().loadWins(this.Uuid);
        }

        public void SetPocket(Card c1, Card c2) {
            this.pocket[0] = c1;
            this.pocket[1] = c2;
        }

        public Hand FindBestHand(string community) {
            return new Hand(String.Join(" ", this.pocket.Select(card => card.Serialize(true))), community);
        }

        public int RemoveFunds(int amt) {
            int before = this.Funds;
            this.Funds -= amt;
            return (before - this.Funds);
        }
    }
}
