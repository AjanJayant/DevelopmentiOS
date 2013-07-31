using System;
using System.Collections.ObjectModel;
using System.Collections.Generic;

namespace CardGame {
    class Player {
        private string name;
        private string uuid;

        private Card[] hand = new Card[2];
        private int funds;
        public int Bet;
        public bool Folded = false;

        public int Funds {
            get { return this.funds; }
            set { this.funds = Math.Max(0, value); }
        }

        // Properties \\
        public Card Card1 {
            get { return this.hand[0]; }
        }
        public Card Card2 {
            get { return this.hand[1]; }
        }

        public string Name {
            get { return this.name; }
        }
        public string UUID {
            get { return this.uuid; }
        }
        /*********************************/

        public Player(string name, string uuid) {
            this.name = name;
            this.uuid = uuid;
            // Load funds from db
            this.funds = Database.getInstance().loadFunds(this.uuid);
        }

        public void setHand(Card c1, Card c2) {
            this.hand[0] = c1;
            this.hand[1] = c2;
        }

        public int removeFunds(int amt) {
            int before = this.Funds;
            this.Funds -= amt;
            return (before - this.Funds);
        }
    }
}
