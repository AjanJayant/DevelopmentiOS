using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CardGame {
    class Deck {
        private static Random rand = new Random();

        private Stack<Card> cards = new Stack<Card>(52);

        public Deck() {
            // Populate the cards list randomly
            int numSuits = 4;
            int numValues = 13;
            int suit, value;
            bool[,] added = new bool[4, 13];
            while (cards.Count < 52) {
                suit = rand.Next(numSuits);
                value = rand.Next(numValues);
                if (!added[suit, value]) {
                    added[suit, value] = true;
                    cards.Push(new Card((Card.Suit)(suit + 1), (Card.Value)(value + 1)));
                }
            }
        }

        public Card draw() {
            return this.cards.Pop();
        }

        public bool IsEmpty {
            get {
                return (this.cards.Count == 0);
            }
        }

    }
}
