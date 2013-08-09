using CardGame.GameElements;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;

namespace CardGame.Server {
    internal class GameManager {
        /**
         * Settings
         * -big blind
         * -max funds
         * -difficulty ratings
         **/
        public const int MEMBER_LIMIT = 8;
        private static readonly List<string> PublicGames = new List<string>(10);     // Names of public games
        private static readonly Dictionary<string, GameManager> Instances = new Dictionary<string, GameManager>();

        public enum Position { SmallBlind, BigBlind };

        public enum Round { Preflop, Flop, Turn, River };

        private Round round;

        private readonly string channel = System.Guid.NewGuid().ToString();
        private readonly string name;
        private string lastAct;

        private Deck deck;
        private readonly Card[] community = new Card[5];
        private readonly List<Player> players = new List<Player>(GameManager.MEMBER_LIMIT);
        private readonly Queue<Player> needToAct = new Queue<Player>(GameManager.MEMBER_LIMIT);
        private readonly Dictionary<string, Boolean> leaving = new Dictionary<string, bool>();

        private int responsesExpected = 0;
        private int pot = 0;
        private int currBet = 0;
        private int minRaise = 0;

        private readonly int bigBlind = 4;  // Buy-in is $4

        private GameManager(string name, string creator) {
            this.name = name;
            this.CreatorUuid = creator;
            Server s = Server.GetInstance();
            Console.WriteLine("{0} created.", this);
            s.Pubnub.Subscribe<string>(this.GameChannel, this.HandleMessage, this.DefaultCallback, this.ErrorCallback);
            //s.Pubnub.Presence<string>(this.GameChannel, this.HandlePresence, this.DefaultCallback, this.ErrorCallback);
        }

        #region Properties

        public int MemberCount {
            get { return this.players.Count; }
        }

        public string GameChannel {
            get { return "game-" + this.name;/* this.channel; */}
        }

        public string CreatorUuid { get; private set; }

        public bool Full {
            get { return (this.players.Count == GameManager.MEMBER_LIMIT); }
        }

        #endregion Properties

        #region Public Methods

        public bool Join(Player p) {
            this.players.Add(p);
            return true;
        }

        public override string ToString() {
            return ("GameManager[" + this.name + "]");
        }

        #endregion Public Methods

        #region Pubnub Callbacks

        private void HandleMessage(string json) {
            var coll = JsonConvert.DeserializeObject<ReadOnlyCollection<object>>(json);
            JContainer container = coll[0] as JContainer;
            if (container == null) {
                return;
            }
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
                        Player joining = Server.GetInstance().GetPlayer(msg["uuid"]);
                        if (joining != null) {
                            this.Join(joining);
                            // Tell new player who the existing players are
                            pJoin["usernames"] = String.Join<string>(",", this.players.Select(p => p.Name).ToList());
                            this.SendToPlayers(pJoin);
                        }
                    }
                    //this.sendMessage(new Card(2, 0).Serialize(), msg["uuid"]);
                    break;
                case "start":
                    this.StartHand();
                    break;
                case "play-again":
                    player = this.GetPlayer(msg["uuid"]);
                    bool staying = Boolean.Parse(msg["yes"]);

                    // Don't handle duplicate responses
                    if (player.Responded) {
                        return;
                    }
                    player.Responded = true;
                    this.responsesExpected--;
                    if (!staying) {
                        this.HandleLeave(player);
                    }
                    Dictionary<string, string> membersUpdate = new Dictionary<string, string>(2);
                    membersUpdate["type"] = "player-join";
                    membersUpdate["usernames"] = String.Join(",", this.players.Select(p => p.Name));
                    this.SendToPlayers(membersUpdate);
                    // If everyone has made a decision on whether to play again, we can automatically start
                    if (this.responsesExpected == 0) {
                        Util.setTimeout(this.StartHand, 5000);
                    }
                    else if (staying) {
                        this.SendMessage(player.Uuid, this.getStats(player));
                    }
                    break;
                case "check":
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
                    this.HandleFold(player);
                    this.UpdateClients();
                    Util.setTimeout(this.TakeTurn, 500);
                    break;
            }
        }

        private void HandlePresence(string json) {
            return; // Presence is buggy atm
            var coll = JsonConvert.DeserializeObject<ReadOnlyCollection<object>>(json);
            JContainer container = coll[0] as JContainer;
            if (container == null) {
                return;
            }
            Console.WriteLine("{0} presence: {1}", this, container);
            var dict = container.ToObject<Dictionary<string, string>>();
            string uuid = dict["uuid"];
            if (dict["action"] == "leave") {
                this.leaving[uuid] = true;
                // Don't kick them immediately, wait a few seconds
                Util.setTimeout(() => {
                    Player leaving = this.GetPlayer(uuid);
                    if (leaving != null && this.leaving[uuid]) {
                        // Don't let them get out of bad situations by quitting and keeping their betted money...they will lose any money they've bet so far
                        Database.getInstance().savePlayer(leaving);
                        this.HandleLeave(leaving);
                    }
                }, 5000);
            }
            else {
                this.leaving[uuid] = false;
            }
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

        #endregion Pubnub Callbacks

        #region Convenience Methods

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

        private Player GetPlayer(string uuid) {
            return this.players.FirstOrDefault(p => p.Uuid.Equals(uuid));
        }

        private string SerializeCommunity(bool forHandEval = false) {
            return String.Join(" ", this.community
                .Where(card => card != null)
                .Select(card => card.Serialize(forHandEval)));
        }

        private void InitVars() {
            this.pot = 0;
            this.deck = new Deck();
            this.round = Round.Preflop;
            this.lastAct = "A new hand has been dealt";
            Array.Clear(this.community, 0, this.community.Length);
            foreach (Player p in this.players) {
                p.Folded = false;
                p.Bet = 0;
                this.needToAct.Enqueue(p);
            }
        }

        private Dictionary<string, string> getStats(Player p) {
            Dictionary<string, string> stats = new Dictionary<string, string>();
            stats["type"] = "stats";
            stats["hands-won"] = p.HandsWon.ToString();
            stats["hands-played"] = p.HandsPlayed.ToString();
            stats["life-winnings"] = p.LifetimeWinnings.ToString();
            stats["highest-bet"] = p.HighestBet.ToString();
            stats["funds"] = p.Funds.ToString();
            return stats;
        }

        private void Dispose() {
            //Server.GetInstance().Pubnub.PresenceUnsubscribe<string>(this.GameChannel, this.DefaultCallback, this.DefaultCallback, this.DefaultCallback, this.DefaultCallback);
            //Server.GetInstance().Pubnub.Unsubscribe<string>(this.GameChannel, this.DefaultCallback, this.DefaultCallback, this.DefaultCallback, this.DefaultCallback);
        }

        #endregion Convenience Methods

        #region Game Events

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
                p.SetPocket(this.deck.Draw(), this.deck.Draw());
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
                start["card1"] = p.Card1.Serialize();
                start["card2"] = p.Card2.Serialize();
                start["my-funds"] = "$" + p.Funds;
                this.SendMessage(p.Uuid, start);
            }
            // Blinds 'automatically' put money in the pot
            this.QueueActors();
            this.needToAct.Dequeue();   // Small blind 'acts'
            this.needToAct.Dequeue();   // Big blind 'acts'
            Util.setTimeout(this.UpdateClients, 500);
            Util.setTimeout(this.TakeTurn, 1000);
        }

        /// <summary>
        /// Sorts the Players by strength of the best hand they can make with the community cards.
        /// </summary>
        /// <returns>The Player with the strongest hand</returns>
        private Player DetermineWinner() {
            string commStr = this.SerializeCommunity(true);
            this.players.Sort((a, b) => {
                if (a.Folded) return 1;
                return (int)(b.FindBestHand(commStr).HandValue - a.FindBestHand(commStr).HandValue);
            });
            Player winner = this.players[0];
            this.lastAct = String.Format("{0} wins with {1}", winner.Name, winner.FindBestHand(commStr).Description);
            return winner;
        }

        /// <summary>
        /// Sends a message indicating the hand has ended, and who takes the pot
        /// </summary>
        /// <param name="winner"></param>
        private void DeclareWinner(Player winner) {
            Dictionary<string, string> end = new Dictionary<string, string>(2);
            end["type"] = "end";
            end["winner"] = winner.Name;
            end["message"] = this.lastAct;
            string comm = this.SerializeCommunity();
            //end["hands"] = String.Join("\n", this.players.Select(p => p.FindBestHand(comm).Description));
            winner.Funds += this.pot;
            winner.HandsWon++;
            Database db = Database.getInstance();
            this.responsesExpected = 0;
            foreach (Player p in this.players) {
                p.HandsPlayed++;
                db.savePlayer(p);
                p.Responded = false;
                this.responsesExpected++;
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

        #endregion Game Events

        #region Betting Round Logic

        private void TakeTurn() {
            if (this.needToAct.Count <= 0) {
                return;
            }
            Player actor = this.needToAct.Dequeue();
            Dictionary<string, string> data = new Dictionary<string, string>(2);
            data["type"] = "take-turn";
            data["current-bet"] = this.currBet.ToString();
            data["my-bet"] = actor.Bet.ToString();
            data["min-raise"] = this.minRaise.ToString();
            this.SendMessage(actor.Uuid, data);
        }

        private void QueueActors() {
            foreach (Player p in this.players.Where(p => !p.Folded)) {
                this.needToAct.Enqueue(p);
            }
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

        #endregion Betting Round Logic

        #region Player Actions

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
            player.HighestBet = Math.Max(player.HighestBet, player.Bet);
            this.pot += moneyAdded;
            this.currBet = player.Bet;
            this.minRaise = this.currBet + moneyAdded;
            this.lastAct = String.Format("{0} raises ${1}", player.Name, this.currBet);
            Console.WriteLine("{0}: {1}", this, this.lastAct);
        }

        private void HandleFold(Player player) {
            player.Folded = true;
            this.lastAct = String.Format("{0} folds", player.Name);
            // If the last person who needs to act is also the last man standing, he doesn't need to take his turn
            if (this.needToAct.Count == 1 && this.players.Count(p => !p.Folded) == 1) {
                this.needToAct.Clear();
            }
        }

        private void HandleLeave(Player player) {
            this.players.Remove(player);
            if (this.players.Count == 1) {
                // Everybody left, scrap this game
                GameManager.Instances.Remove(this.name);
                this.Dispose();
            }
            else if (this.CreatorUuid == player.Uuid) {
                this.CreatorUuid = this.players[0].Uuid;
            }
        }

        #endregion Player Actions

        #region Static Methods

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

        #endregion Static Methods
    }
}