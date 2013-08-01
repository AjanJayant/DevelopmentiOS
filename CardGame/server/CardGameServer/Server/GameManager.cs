using System;
using System.Collections.ObjectModel;
using System.Collections.Generic;
using System.Linq;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using CardGame.GameElements;

namespace CardGame.Server {
    class GameManager {

        public const int MEMBER_LIMIT = 8;
        private static readonly List<string> PublicGames = new List<string>(10);     // Names of public games
        private static readonly Dictionary<string, GameManager> Instances = new Dictionary<string, GameManager>();
        public enum Position { SmallBlind, BigBlind };
        public enum Round { Preflop, Flop, Turn, River };

        private Round round = Round.Preflop;

        private readonly string name;
        private string lastAct;

        private Deck deck;
        private readonly Card[] community = new Card[5];
        private readonly List<Player> players = new List<Player>(GameManager.MEMBER_LIMIT);
        private readonly Queue<Player> needToAct = new Queue<Player>(GameManager.MEMBER_LIMIT);

        private int pot = 0;
        private int currBet = 0;
        private int minRaise = 0;
        private int currPlayer = 0;
        private int CurrPlayer {
            set {
                this.currPlayer = value % this.players.Count;
            }
        }
        private int bigBlind = 4;  // Buy-in is $4

        private GameManager(string name, string creator) {
            this.name = name;
            this.CreatorUuid = creator;
            Server s = Server.GetInstance();
            Console.WriteLine("{0} created.", this);
            s.Pubnub.Subscribe<string>(this.GameChannel, this.HandleMessage, this.DefaultCallback, this.ErrorCallback);
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

        public string CreatorUuid { get; private set; }

        public bool Full {
            get {
                return (this.players.Count == GameManager.MEMBER_LIMIT);
            }
        }

        /*******************
         * Public Methods  *
         *******************/
        public bool Join(Player p) {
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
        private void HandleMessage(string json) {
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
                    this.SendMessage(msg["uuid"], response);

                    if (success) {
                        Dictionary<string, string> pJoin = new Dictionary<string, string>(2);
                        pJoin["type"] = "player-join";
                        pJoin["usernames"] = msg["username"];

                        // Tell all players that the new guy has joined
                        this.SendToPlayers(pJoin);

                        // Tell new player who the existing players are
                        List<string> list = this.players.Select(p => p.Name).ToList();
                        pJoin["usernames"] = String.Join<string>(",", list);
                        this.SendMessage(msg["uuid"], pJoin);
                        this.Join(Server.GetInstance().GetPlayer(msg["uuid"]));
                    }
                    //this.sendMessage(new Card(2, 0).Serialize(), msg["uuid"]);
                    break;
                case "start":
                    this.StartHand();
                    break;
                case "check":
                    // Okay, doesn't really do anything
                    player = this.GetPlayer(msg["uuid"]);
                    this.lastAct = String.Format("{0} checks", player.Name);
                    this.UpdateClients();
                    Util.setTimeout(this.TakeTurn, 500);
                    break;
                case "call":
                    player = this.GetPlayer(msg["uuid"]);
                    this.HandleCall(player);
                    this.UpdateClients();
                    Util.setTimeout(this.TakeTurn, 500);
                    break;
                case "raise":
                    player = this.GetPlayer(msg["uuid"]);
                    this.HandleRaise(player, int.Parse(msg["amount"]));
                    this.UpdateClients();
                    Util.setTimeout(this.TakeTurn, 500);
                    break;
                case "fold":
                    player = this.GetPlayer(msg["uuid"]);
                    player.Folded = true;
                    this.lastAct = String.Format("{0} folds", player.Name);
                    this.UpdateClients();
                    this.UpdateClients();
                    Util.setTimeout(this.TakeTurn, 500);
                    break;
            }
        }

        private void HandlePresence(string json) {
            var coll = JsonConvert.DeserializeObject<ReadOnlyCollection<object>>(json);
            JContainer container = coll[0] as JContainer;
            Console.WriteLine("{0} presence: {1}", this, container);
        }

        private void DefaultCallback(string e) {
            Console.WriteLine("{0} default callback: {1}", this, e);
        }

        private void MessageSent(string e) {
            Console.WriteLine("{0} message sent: {1}", this, e);
        }


        private void ErrorCallback(string e) {
            Console.WriteLine("{0} error occurred: {1}", this, e);
        }
        //end Callbacks\\

        private void SendToPlayers(object data) {
            foreach (Player p in this.players) {
                this.SendMessage(p.Uuid, data);
            }
        }

        private void SendMessage(string channel, object data) {
            Dictionary<string, string> dict = data as Dictionary<string, string>;
            if (dict != null) {
                Console.Write("{0} sending <{1}>: ", this, channel);
                Util.printDict(dict);
                Console.WriteLine();
            }
            Server.GetInstance().Pubnub.Publish<string>(channel, data, this.MessageSent, this.ErrorCallback);
        }

        /// <summary>
        /// Informs each player that the game is starting. Notifies a player if he is the small/big blind, and
        /// deals him a two card hand.
        /// </summary>
        private void StartHand() {
            Console.WriteLine("{0} starting game...", this);
            this.InitVars();
            Player p;
            Dictionary<string, string> start = new Dictionary<string, string>(2);
            start["type"] = "start";
            start["success"] = true.ToString();
            for (int i = 0, len = this.players.Count; i < len; i++) {
                p = this.players[i];
                p.Folded = false;
                start["initial-funds"] = "$" + p.Funds;
                switch (i) {
                    case (int)Position.SmallBlind:
                        this.HandleRaise(p, this.bigBlind / 2);
                        this.lastAct = String.Format("{0} posts small blind of ${1}", p.Name, this.bigBlind / 2);
                        break;
                    case (int)Position.BigBlind:
                        this.HandleRaise(p, this.bigBlind);
                        this.lastAct = String.Format("{0} posts big blind of ${1}", p.Name, this.bigBlind);
                        break;
                }
                if (Enum.IsDefined(typeof(Position), i)) {
                    start["blind"] = Enum.GetName(typeof(Position), i).ToLower();
                }
                p.SetPocket(this.deck.Draw(), this.deck.Draw());
                start["card1"] = p.Card1.Serialize();
                start["card2"] = p.Card2.Serialize();
                start["my-funds"] = "$" + p.Funds;
                this.SendMessage(p.Uuid, start);
            }
            // Blinds 'automatically' put money in the pot
            this.CurrPlayer = (int)Position.BigBlind + 1;
            this.QueueActors();
            this.needToAct.Dequeue();   // Small blind 'acts'
            this.needToAct.Dequeue();   // Big blind 'acts'
            Util.setTimeout(this.UpdateClients, 500);
            Util.setTimeout(this.TakeTurn, 1000);
        }

        private void TakeTurn() {
            if (this.needToAct.Count <= 0) {
                return;
            }
            Player actor = this.needToAct.Dequeue();
            Dictionary<string, string> data = new Dictionary<string, string>(2);
            data["type"] = "take-turn";
            data["min-raise"] = this.minRaise.ToString();
            this.SendMessage(actor.Uuid, data);
        }

        private void DeclareWinner(Player winner) {
            Dictionary<string, string> end = new Dictionary<string, string>(2);
            end["type"] = "end";
            end["winner"] = winner.Name;
            end["message"] = this.lastAct;
            string comm = this.SerializeCommunity();
            end["hands"] = String.Join("\n", this.players.Select(p => p.FindBestHand(comm).Description));
            winner.Funds += this.pot;
            winner.Wins++;
            Database db = Database.getInstance();
            foreach (Player p in this.players) {
                db.savePlayer(p);
            }
            this.SendToPlayers(end);
        }

        private void UpdateClients() {
            if (this.RoundOver()) {
                if (this.round != Round.River) {
                    this.AdvanceRound();
                    if (this.needToAct.Count == 1) {
                        // One man standing, everyone else folded
                        Player p = this.needToAct.Dequeue();
                        this.lastAct = String.Format("{0} wins by default", p.Name);
                        this.DeclareWinner(p);
                        return;
                    }
                }
                else {
                    // Showdown
                    this.DeclareWinner(this.DetermineWinner());
                    return;
                }
            }
            Dictionary<string, string> state = new Dictionary<string, string>();
            state["type"] = "update";
            state["pot"] = "$" + this.pot;
            state["current-bet"] = this.currBet.ToString();
            state["last-act"] = this.lastAct;
            state["community"] = this.SerializeCommunity();
            foreach (Player p in this.players) {
                state["my-bet"] = p.Bet.ToString();
                state["my-funds"] = "$" + p.Funds;
                this.SendMessage(p.Uuid, state);
            }
        }

        private Player DetermineWinner() {
            string commStr = this.SerializeCommunity();
            this.players.Sort((a, b) => (int) (b.FindBestHand(commStr).HandValue - a.FindBestHand(commStr).HandValue));
            Player winner = this.players[0];
            this.lastAct = String.Format("{0} wins with {1}", winner.Name, winner.FindBestHand(commStr).Description);
            return winner;
        }

        private string SerializeCommunity() {
            return String.Join(" ", this.community
                .Where(card => card != null)
                .Select(card => card.Serialize()));
        }

        private void AdvanceRound() {
            this.round++;
            switch (this.round) {
                case Round.Flop:
                    this.community[0] = this.deck.Draw();
                    this.community[1] = this.deck.Draw();
                    this.community[2] = this.deck.Draw();
                    break;
                case Round.Turn:
                    this.community[3] = this.deck.Draw();
                    break;
                case Round.River:
                    this.community[4] = this.deck.Draw();
                    break;
            }
            this.QueueActors();
        }

        private bool RoundOver() {
            if (this.needToAct.Count > 0) {
                return false;
            }
            if (!this.players.Any(p => p.Bet != this.currBet && !p.Folded && p.Funds > 0)) {
                return true;
            }
            this.QueueActors();
            return false;
        }

        private void QueueActors() {
            foreach (Player p in this.players.Where(p => !p.Folded)) {
                this.needToAct.Enqueue(p);
            }
        }

        private void InitVars() {
            this.pot = 0;
            this.deck = new Deck();
            this.round = Round.Preflop;
            this.lastAct = "A new hand has been dealt";
            for (int i = 0; i < this.community.Length; i++) {
                this.community[i] = null;
            }
            foreach (Player p in this.players) {
                p.Folded = false;
                p.Bet = 0;
            }
        }

        private void HandleCall(Player player) {
            int moneyAdded = player.RemoveFunds(this.currBet - player.Bet);
            player.Bet = this.currBet;
            this.pot += moneyAdded;
            this.lastAct = String.Format("{0} calls ${1}", player.Name, this.currBet);
            Console.WriteLine("{0}: {1}", this, this.lastAct);
        }

        private void HandleRaise(Player player, int bet) {
            int moneyAdded = player.RemoveFunds(bet - player.Bet);
            player.Bet += moneyAdded;
            this.pot += moneyAdded;
            this.currBet = player.Bet;
            this.minRaise = this.currBet + moneyAdded;
            this.lastAct = String.Format("{0} raises ${1}", player.Name, this.currBet);
            Console.WriteLine("{0}: {1}", this, this.lastAct);
        }

        private Player GetPlayer(string uuid) {
            return this.players.FirstOrDefault(p => p.Uuid.Equals(uuid));
        }

        /******************
         * Static Methods *
         ******************/

        public static GameManager GetGame(string name) {
            GameManager g;
            Instances.TryGetValue(name, out g);
            return g;
        }

        public static void CreateGame(string name, string creator) {
            Instances[name] = new GameManager(name, creator);
        }

        /// <returns>The name of the first available (not full) public game. A new game will be created if none are open.</returns>
        public static string FindPublicGame() {
            foreach (string name in PublicGames.Where(name => Instances[name].MemberCount < MEMBER_LIMIT)) {
                return name;
            }
            string newName = "public" + PublicGames.Count;
            PublicGames.Add(newName);
            GameManager.CreateGame(newName, null);
            return newName;
        }
    }
}
