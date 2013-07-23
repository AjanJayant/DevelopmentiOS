using System;
using System.Collections.ObjectModel;
using System.Collections.Generic;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace CardGame {
    class GameManager {

        public static int MEMBER_LIMIT = 5;
        private static List<string> publicGames = new List<string>(10);     // Names of public games
        private static Dictionary<string, GameManager> instances = new Dictionary<string, GameManager>();

        private string name;
        private string creatorUUID;
        private Deck deck = new Deck();
        private Dictionary<string, Player> players = new Dictionary<string, Player>(GameManager.MEMBER_LIMIT);

        private GameManager(string name, string creator) {
            this.name = name;
            this.creatorUUID = creator;
            Server s = Server.getInstance();
            //s.Pubnub.Subscribe<string>(this.GameChannel, this.handleMessage, this.defaultCallback);
            //s.Pubnub.Presence<string>(this.GameChannel, this.handlePresence, this.defaultCallback);
        }

        /*********************
         * Public Properties *
         *********************/

        public int MemberCount {
            get {
                return this.players.Count;
            }
        }

        public string GameChannel {
            get {
                return "game-" + this.name;
            }
        }

        public string CreatorUUID {
            get {
                return this.creatorUUID;
            }
        }

        /*******************
         * Public Methods  *
         *******************/

        public bool tryJoin(string uuid, string username) {
            if (this.players.Count == GameManager.MEMBER_LIMIT) {
                return false;
            }

            this.players.Add(uuid, new Player(username));
            return true;
        }

        public override string ToString() {
            return ("GameManager[" + this.name + "]");
        }

        /*******************
         * Private Methods *
         *******************/

        private void handleMessage(string json) {
            var coll = JsonConvert.DeserializeObject<ReadOnlyCollection<object>>(json);
            JContainer container = coll[0] as JContainer;
            Dictionary<string, string> msg = container.ToObject<Dictionary<string, string>>();
            if (msg.ContainsKey("target")) {
                return;
            }

            Console.WriteLine("{0} message: {1}", this, container);
            switch (msg["type"]) {
                case "join":
                    // Player is entering game
                    bool success = this.tryJoin(msg["uuid"], msg["username"]);

                    break;
                case "bet":
                    // Player makes bet
                    break;
                // ...
            }
        }

        private void handlePresence(string json) {
            var coll = JsonConvert.DeserializeObject<ReadOnlyCollection<object>>(json);
            JContainer container = coll[0] as JContainer;
            Console.WriteLine("{0} presence: {1}", this, container);
        }

        private void defaultCallback(string json) {
        }


        /******************
         * Static Methods *
         ******************/

        public static GameManager getGame(string name) {
            if (!instances.ContainsKey(name)) {
                return null;
            }
            return instances[name];
        }

        public static void createGame(string name, string creator) {
            instances.Add(name, new GameManager(name, creator));
        }

        /// <returns>The name of the first available (not full) public game. A new game will be created if none are open.</returns>
        public static string findPublicGame() {
            foreach (string name in publicGames) {
                if (instances[name].MemberCount < MEMBER_LIMIT) {
                    return name;
                }
            }
            string newName = "public" + publicGames.Count;
            publicGames.Add(newName);
            GameManager.createGame(newName, null);
            return newName;
        }
    }
}
