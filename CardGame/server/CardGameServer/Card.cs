using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CardGame {
    class Card {
        public static readonly string[] Suits = { "Clubs", "Diamonds", "Hearts", "Spades" };
        public static readonly string[] Values = { "2", "3", "4", "5", "6", "7", "8", "9", "10", "Jack", "Queen", "King", "Ace" };
        private int suit;
        private int value;

        public Card(int suit, int value) {
            this.suit = suit;
            this.value = value;
        }

        public override string ToString() {
            return String.Format("{0} of {1}", Card.Values[this.value], Card.Suits[this.suit]);
        }
    }
}
