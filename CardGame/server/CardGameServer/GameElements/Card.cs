using System;

namespace CardGame.GameElements {
    internal class Card {

        //public enum Suit { Clubs = 1, Diamonds, Hearts, Spades };
        //public enum Value {Ace = 1, Two, Three, Four, Five, Six, Seven, Eight, Nine, Ten, Jack, Queen, King};
        public static readonly string[] Suits = { "Clubs", "Diamonds", "Hearts", "Spades" };

        public static readonly string[] Ranks = { "Ace", "2", "3", "4", "5", "6", "7", "8", "9", "10", "Jack", "Queen", "King" };
        private readonly int suit;
        private readonly int rank;

        public Card(int suit, int rank) {
            this.suit = suit;
            this.rank = rank;
        }

        public string Serialize(bool forHandEval = false) {
            if (!forHandEval) {
                return String.Format("{0}{1}", Suits[this.suit].ToLower().Substring(0, 1), this.rank + 1);
            }
            // Special serialization format for hand evaluator
            return String.Format("{1}{0}", 
                Suits[this.suit].ToLower().Substring(0, 1),
                Ranks[this.rank].ToLower().Substring(0, (this.rank == 9 ? 2 : 1))
            );
        }

        public override string ToString() {
            return String.Format("{0} of {1}", Ranks[this.rank], Suits[this.suit]);
        }
    }
}