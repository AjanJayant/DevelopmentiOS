using System;
using System.Collections.ObjectModel;
using System.Collections.Generic;

namespace CardGame {
    class Player {
        private string name;

        public string Name {
            get { return this.name; }
        }

        public Player(string name) {
            this.name = name;
        }
    }
}
