using CardGame.Server;
using HoldemHand;
using System;
using System.Collections.Generic;
using System.Linq;

namespace CardGame.GameElements {
    internal class Player {
        private readonly Card[] pocket = new Card[2];
        private int funds;

        #region Properties

        public Card Card1 {
            get { return this.pocket[0]; }
        }
        public Card Card2 {
            get { return this.pocket[1]; }
        }
        public int Funds {
            get { return this.funds; }
            set {
                int before = this.funds;
                this.funds = Math.Max(0, value);
                this.LifetimeWinnings += Math.Max(0, this.funds - before);
            }
        }
        public int Bet { get; set; }
        public bool Folded { get; set; }
        public int HandsWon { get; set; }
        public int HandsPlayed { get; set; }
        public int HighestBet { get; set; }
        public int LifetimeWinnings {
            get;
            private set;
        }
        public string Name { get; private set; }
        public string Uuid { get; private set; }

        public bool Responded { get; set; }

        #endregion Properties

        public Player(string name, string uuid) {
            this.Name = name;
            this.Uuid = uuid;
            // Load funds from db
            this.funds = Database.getInstance().loadFunds(this.Uuid);
            this.HandsWon = Database.getInstance().loadWins(this.Uuid);
        }

        public Player(string name, string uuid, int funds, int wins, int lifeWinnings, int handsPlayed, int highestBet) {
            this.Name = name;
            this.Uuid = uuid;
            this.funds = funds;
            this.HandsWon = wins;
            this.HandsPlayed = handsPlayed;
            this.LifetimeWinnings = lifeWinnings;
            this.HighestBet = highestBet;
        }

        public void SetPocket(Card c1, Card c2) {
            this.pocket[0] = c1;
            this.pocket[1] = c2;
        }

        public Hand FindBestHand(string community) {
            Console.WriteLine("{0}'s best hand: {1} {2}", this.Name, String.Join(" ", this.pocket.Select(card => card.Serialize(true))), community);
            return new Hand(String.Join(" ", this.pocket.Select(card => card.Serialize(true))), community);
        }

        public int RemoveFunds(int amt) {
            int before = this.Funds;
            this.Funds -= amt;
            return (before - this.Funds);
        }

        public Dictionary<string, string> GetStats() {
            Dictionary<string, string> stats = new Dictionary<string, string>();
            stats["type"] = "stats";
            stats["hands-won"] = this.HandsWon.ToString();
            stats["hands-played"] = this.HandsPlayed.ToString();
            stats["life-winnings"] = this.LifetimeWinnings.ToString();
            stats["highest-bet"] = this.HighestBet.ToString();
            stats["funds"] = this.Funds.ToString();
            return stats;
        }
    }
}