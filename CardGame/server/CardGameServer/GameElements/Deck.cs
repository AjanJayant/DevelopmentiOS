using System;
using System.Collections.Generic;

namespace CardGame.GameElements {
    class Deck {
        private static readonly Random Rand = new Random();

        private readonly Stack<Card> cards = new Stack<Card>(52);

        public Deck() {
            // Populate the cards list randomly
            const int numSuits = 4;
            const int numValues = 13;
            int suit, value;
            bool[,] added = new bool[4, 13];
            while (cards.Count < 52) {
                suit = Rand.Next(numSuits);
                value = Rand.Next(numValues);
                if (added[suit, value]) {
                    continue;
                }
                added[suit, value] = true;
                cards.Push(new Card(suit, value));
            }
        }

        public Card Draw() {
            return this.cards.Pop();
        }

        public bool IsEmpty {
            get {
                return (this.cards.Count == 0);
            }
        }

    }
}
