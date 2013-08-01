using System;
using System.Collections.ObjectModel;
using System.Collections.Generic;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace CardGame {
    class GameManager {

        public static int MEMBER_LIMIT = 8;
        private static List<string> publicGames = new List<string>(10);     // Names of public games
        private static Dictionary<string, GameManager> instances = new Dictionary<string, GameManager>();
        public enum Position { SmallBlind, BigBlind };
        public enum Round { Preflop, Flop, Turn, River };

        private Round round = Round.Preflop;

        private string name;
        private string creatorUUID;
        private string lastAct;

        private Deck deck;
        private Card[] community = new Card[5];
        private List<Player> players = new List<Player>(GameManager.MEMBER_LIMIT);
        private Queue<Player> needToAct = new Queue<Player>(GameManager.MEMBER_LIMIT);

        private int pot = 0;
        private int currBet = 0;
        private int minRaise = 0;
        private int currPlayer = 0;
        private int CurrPlayer {
            get {
                return this.currPlayer;
            }
            set {
                this.currPlayer = value % this.players.Count;
            }
        }
        private int BIG_BLIND = 4;  // Buy-in is $4

        private GameManager(string name, string creator) {
            this.name = name;
            this.creatorUUID = creator;
            Server s = Server.getInstance();
            Console.WriteLine("{0} created.", this);
            s.Pubnub.Subscribe<string>(this.GameChannel, this.handleMessage, this.defaultCallback, this.errorCallback);
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

        public bool Full {
            get {
                return (this.players.Count == GameManager.MEMBER_LIMIT);
            }
        }

        /*******************
         * Public Methods  *
         *******************/
        public bool join(string uuid, string username) {
            Player p = new Player(username, uuid);
            this.players.Add(p);
            return true;
        }

        public override string ToString() {
            return ("GameManager[" + this.name + "]");
        }

        /*******************
         * Private Methods *
         *******************/

        // Callbacks \\
        private void handleMessage(string json) {
            var coll = JsonConvert.DeserializeObject<ReadOnlyCollection<object>>(json);
            JContainer container = coll[0] as JContainer;
            Dictionary<string, string> msg = container.ToObject<Dictionary<string, string>>();
            if (!msg.ContainsKey("uuid") || !msg.ContainsKey("username") || !msg.ContainsKey("type")) {
                Console.WriteLine("Invalid message received");
                return;
            }

            Console.WriteLine();
            Console.WriteLine("---------------------------");
            Console.WriteLine();
            Console.WriteLine("{0} incoming message: {1}", this, container);
            Dictionary<string, string> response = new Dictionary<string, string>();
            Player player;

            if (msg.ContainsKey("type")) {
                response["type"] = msg["type"];
            }
            switch (msg["type"]) {
                case "join":
                    // Player is entering game
                    bool success = !this.Full;
                    response["success"] = success.ToString();
                    if (!success) {
                        response["message"] = String.Format("Game '{0}' is full.", this.name);
                    }
                    this.sendMessage(msg["uuid"], response);

                    if (success) {
                        Dictionary<string, string> pJoin = new Dictionary<string, string>(2);
                        pJoin["type"] = "player-join";
                        pJoin["usernames"] = msg["username"];

                        // Tell all players that the new guy has joined
                        this.sendToPlayers(pJoin);

                        // Tell new player who the existing players are
                        List<string> list = new List<string>();
                        foreach (Player p in this.players) {
                            list.Add(p.Name);
                        }
                        pJoin["usernames"] = String.Join<string>(",", list);
                        this.sendMessage(msg["uuid"], pJoin);
                        this.join(msg["uuid"], msg["username"]);
                    }
                    //this.sendMessage(new Card(2, 0).Serialize(), msg["uuid"]);
                    break;
                case "start":
                    this.startHand();
                    break;
                case "check":
                    // Okay, doesn't really do anything
                    player = this.getPlayer(msg["uuid"]);
                    this.lastAct = String.Format("{0} checks", player.Name);
                    Util.setTimeout(this.updateClients, 500);
                    Util.setTimeout(this.takeTurn, 1000);
                    break;
                case "call":
                    player = this.getPlayer(msg["uuid"]);
                    this.handleCall(player);
                    Util.setTimeout(this.updateClients, 500);
                    Util.setTimeout(this.takeTurn, 1000);
                    break;
                case "raise":
                    player = this.getPlayer(msg["uuid"]);
                    this.handleRaise(player, int.Parse(msg["amount"]));
                    Util.setTimeout(this.updateClients, 500);
                    Util.setTimeout(this.takeTurn, 1000);
                    break;
                case "fold":
                    player = this.getPlayer(msg["uuid"]);
                    player.Folded = true;
                    this.lastAct = String.Format("{0} folds", player.Name);
                    this.updateClients();
                    Util.setTimeout(this.updateClients, 500);
                    Util.setTimeout(this.takeTurn, 1000);
                    break;
            }
        }

        private void handlePresence(string json) {
            var coll = JsonConvert.DeserializeObject<ReadOnlyCollection<object>>(json);
            JContainer container = coll[0] as JContainer;
            Console.WriteLine("{0} presence: {1}", this, container);
        }

        private void defaultCallback(string e) {
            Console.WriteLine("{0} default callback: {1}", this, e);
        }

        private void messageSent(string e) {
            Console.WriteLine("{0} message sent: {1}", this, e);
        }


        private void errorCallback(string e) {
            Console.WriteLine("{0} error occurred: {1}", this, e);
        }
        //end Callbacks\\

        private void sendToPlayers(object data) {
            foreach (Player p in this.players) {
                this.sendMessage(p.UUID, data);
            }
        }

        private void sendMessage(string channel, object data) {
            var dict = data as Dictionary<string, string>;
            if (dict != null) {
                Console.Write("{0} sending <{1}>: ", this, channel);
                Util.printDict<string, string>(dict);
                Console.WriteLine();
            }
            Server.getInstance().Pubnub.Publish<string>(channel, data, this.messageSent, this.errorCallback);
        }

        /// <summary>
        /// Informs each player that the game is starting. Notifies a player if he is the small/big blind, and
        /// deals him a two card hand.
        /// </summary>
        private void startHand() {
            Console.WriteLine("{0} starting game...", this);
            this.deck = new Deck();
            this.round = Round.Preflop;
            this.lastAct = "The new hand has been dealt";
            Dictionary<string, string> start = new Dictionary<string, string>(2);
            start["type"] = "start";
            start["success"] = true.ToString();
            Player p;
            for (int i = 0, len = this.players.Count; i < len; i++) {
                p = this.players[i];
                p.Folded = false;
                start["initial-funds"] = "$" + p.Funds.ToString();
                if (i == (int)Position.SmallBlind) {
                    this.handleRaise(p, this.BIG_BLIND / 2);
                    this.lastAct = String.Format("{0} posts small blind of ${1}", p.Name, this.BIG_BLIND / 2);
                }
                else if (i == (int)Position.BigBlind) {
                    this.handleRaise(p, this.BIG_BLIND);
                    this.lastAct = String.Format("{0} posts big blind of ${1}", p.Name, this.BIG_BLIND);
                }
                if (Enum.IsDefined(typeof(Position), i)) {
                    start["blind"] = Enum.GetName(typeof(Position), i).ToLower();
                }
                p.setHand(this.deck.draw(), this.deck.draw());
                start["card1"] = p.Card1.Serialize();
                start["card2"] = p.Card2.Serialize();
                start["my-funds"] = "$" + p.Funds.ToString();
                this.sendMessage(p.UUID, start);
            }
            // Blinds 'automatically' put money in the pot
            this.CurrPlayer = (int)Position.BigBlind + 1;
            this.queueActors();
            this.needToAct.Dequeue();   // Small blind 'acts'
            this.needToAct.Dequeue();   // Big blind 'acts'
            Util.setTimeout(this.updateClients, 500);
            Util.setTimeout(this.takeTurn, 1000);
        }

        private void updateClients() {
            if (this.roundOver()) {
                if (this.round != Round.River) {
                    this.advanceRound();
                    if (this.needToAct.Count == 1) {
                        // One man standing, everyone else folded
                    }
                }
                else {
                    // Showdown
                }
            }
            Dictionary<string, string> state = new Dictionary<string, string>();
            state["type"] = "update";
            state["pot"] = "$" + this.pot.ToString();
            state["current-bet"] = this.currBet.ToString();
            state["last-act"] = this.lastAct;
            state["community"] = this.serializeCommunity();
            foreach (Player p in this.players) {
                state["my-bet"] = p.Bet.ToString();
                state["my-funds"] = "$" + p.Funds.ToString();
                this.sendMessage(p.UUID, state);
            }
        }

        private string serializeCommunity() {
            string s = "";
            Card c = this.community[0];
            if (c != null) {
                s = c.Serialize();
            }
            for (int i = 1; i < this.community.Length; i++) {
                c = this.community[i];
                if (c != null) {
                    s += "," + c.Serialize();
                }
            }
            return s;
        }

        private void advanceRound() {
            this.round++;
            if (this.round == Round.Flop) {
                this.community[0] = this.deck.draw();
                this.community[1] = this.deck.draw();
                this.community[2] = this.deck.draw();
            }
            else if (this.round == Round.Turn) {
                this.community[3] = this.deck.draw();
            }
            else if (this.round == Round.River) {
                this.community[4] = this.deck.draw();
            }
            this.queueActors();
        }

        private bool roundOver() {
            if (this.needToAct.Count > 0) {
                return false;
            }
            foreach (Player p in this.players) {
                if (p.Bet != this.currBet && !p.Folded && p.Funds > 0) {
                    this.queueActors();
                    return false;
                }
            }
            return true;
        }

        private void queueActors() {
            foreach (Player p in this.players) {
                if (!p.Folded) {
                    this.needToAct.Enqueue(p);
                }
            }
        }

        private void takeTurn() {
            if (this.needToAct.Count > 0) {
                Player actor = this.needToAct.Dequeue();
                Dictionary<string, string> data = new Dictionary<string, string>(2);
                data["type"] = "take-turn";
                data["min-raise"] = this.minRaise.ToString();
                this.sendMessage(actor.UUID, data);
            }
        }

        private void handleCall(Player player) {
            int moneyAdded = player.removeFunds(this.currBet - player.Bet);
            player.Bet = this.currBet;
            this.pot += moneyAdded;
            this.lastAct = String.Format("{0} calls ${1}", player.Name, this.currBet);
            Console.WriteLine("{0}: {1}", this, this.lastAct);
        }

        private void handleRaise(Player player, int bet) {
            int moneyAdded = player.removeFunds(bet - player.Bet);
            player.Bet += moneyAdded;
            this.pot += moneyAdded;
            this.currBet = player.Bet;
            this.minRaise = this.currBet + moneyAdded;
            this.lastAct = String.Format("{0} raises ${1}", player.Name, this.currBet);
            Console.WriteLine("{0}: {1}", this, this.lastAct);
        }

        private Player getPlayer(string uuid) {
            foreach (Player p in this.players) {
                if (p.UUID.Equals(uuid)) {
                    return p;
                }
            }
            return null;
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
            instances[name] = new GameManager(name, creator);
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
