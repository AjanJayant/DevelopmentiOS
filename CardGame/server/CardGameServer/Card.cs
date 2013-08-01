using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CardGame {
    class Card {
        public enum Suit { Clubs = 1, Diamonds, Hearts, Spades };
        public enum Value {Ace = 1, Two, Three, Four, Five, Six, Seven, Eight, Nine, Ten, Jack, Queen, King};
        //public static readonly string[] Suits = { "Clubs", "Diamonds", "Hearts", "Spades" };
        //public static readonly string[] Values = { "2", "3", "4", "5", "6", "7", "8", "9", "10", "Jack", "Queen", "King", "Ace" };
        private Suit suit;
        private Value value;

        public Card(Suit suit, Value value) {
            this.suit = suit;
            this.value = value;
        }

        public string Serialize() {
            return String.Format("{1}{0}", (int)this.value, Enum.GetName(typeof(Suit), this.suit).Substring(0, 1).ToLower());
        }

        public override string ToString() {
            return String.Format("{0} of {1}", Enum.GetName(typeof(Card.Value), this.value), Enum.GetName(typeof(Card.Suit), this.suit));
        }
    }
}
