using System;
using System.Collections.Generic;

namespace CardGame.GameElements {
    class Deck {
        private static readonly Random Rand = new Random();

        private readonly Card[] cards = new Card[52];
        private int curr = 0;

        public Deck() {
            // Populate the cards list randomly
            const int numSuits = 4;
            const int numValues = 13;
            for (int i = 0; i < numSuits; i++) {
                for (int j = 0; j < numValues; j++) {
                    this.cards[i*numValues + j] = new Card(i, j);
                }
            }
            for (int i = 0; i < 52; i++) {
                int j = Rand.Next(i, 52);
                Card temp = this.cards[i];
                this.cards[i] = this.cards[j];
                this.cards[j] = temp;
            }

            //int suit, value;
            //bool[,] added = new bool[4, 13];
            //while (cards.Count < 52) {
            //    suit = Rand.Next(numSuits);
            //    value = Rand.Next(numValues);
            //    if (added[suit, value]) {
            //        continue;
            //    }
            //    added[suit, value] = true;
            //    cards.Push(new Card(suit, value));
            //}
        }

        public Card Draw() {
            return this.cards[curr++];
            //return this.cards.Pop();
        }

        public bool IsEmpty {
            get {
                return this.curr == 52;
                //return (this.cards.Count == 0);
            }
        }

    }
}
