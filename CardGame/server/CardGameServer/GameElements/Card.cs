using System;

namespace CardGame.GameElements {
    internal class Card {

        //public enum Suit { Clubs = 0, Diamonds, Hearts, Spades };
        //public enum Rank {Ace = 0, Two, Three, Four, Five, Six, Seven, Eight, Nine, Ten, Jack, Queen, King};
        public static readonly string[] Suits = { "Clubs", "Diamonds", "Hearts", "Spades" };

        public static readonly string[] Ranks = { "Ace", "2", "3", "4", "5", "6", "7", "8", "9", "10", "Jack", "Queen", "King" };
        public int Suit { get; private set; }
        public int Rank { get; private set; }

        public Card(int Suit, int Rank) {
            this.Suit = Suit;
            this.Rank = Rank;
        }

        public string Serialize(bool forHandEval = false) {
            if (!forHandEval) {
                return String.Format("{0}{1}", Suits[this.Suit].ToLower().Substring(0, 1), this.Rank + 1);
            }
            // Special serialization format for hand evaluator
            return String.Format("{1}{0}", 
                Suits[this.Suit].ToLower().Substring(0, 1),
                Ranks[this.Rank].ToLower().Substring(0, (this.Rank == 9 ? 2 : 1))
            );
        }

        public override string ToString() {
            return String.Format("{0} of {1}", Ranks[this.Rank], Suits[this.Suit]);
        }

        public bool Equals(Card r) {
            return this.Rank == r.Rank && this.Suit == r.Suit;
        }
    }
}