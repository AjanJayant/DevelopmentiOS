using CardGame.GameElements;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PubNubMessaging.Core;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;

namespace CardGame.Server {
    internal class Server {
        private static Server instance;

        /**
         * USE YOUR OWN KEYS HERE
         **/
        private const string Channel = "PokerServer";
        private const string Uuid = "server";
        private const string PubKey = "demo";
        private const string SubKey = "demo";
        private const string SecretKey = "mySecret";

        private readonly Database db;
        public Pubnub Pubnub { get; private set; }

        private readonly Dictionary<string, Player> players = new Dictionary<string, Player>();

        private Server() {
            this.Pubnub = new Pubnub(PubKey, SubKey, SecretKey) { SessionUUID = Uuid };
            this.Pubnub.Subscribe<string>(Channel, this.HandleMessage, DefaultCallback, ErrorCallback);
            //this.pubnub.Presence<string>(this.channel, this.handlePresence, this.defaultCallback);
            Console.WriteLine("Server created.");
            this.db = Database.getInstance();
        }

        #region PubNub Callbacks

        private void HandlePresence(string json) {
            var coll = JsonConvert.DeserializeObject<ReadOnlyCollection<object>>(json);
            JContainer container = coll[0] as JContainer;
            Console.WriteLine("Server presence: {0}", container);
        }

        private void HandleMessage(string json) {
            var coll = JsonConvert.DeserializeObject<ReadOnlyCollection<object>>(json);
            JContainer container = coll[0] as JContainer;
            Dictionary<string, string> msg = container.ToObject<Dictionary<string, string>>();

            Console.WriteLine();
            Console.WriteLine("---------------------------");
            Console.WriteLine();
            Console.WriteLine("Server incoming message: {0}", container);

            if (!msg.ContainsKey("uuid") || !msg.ContainsKey("username") || !msg.ContainsKey("type")) {
                Console.WriteLine("Invalid message received");
                return;
            }

            /**
             * Local variables for the switch block
             **/
            Dictionary<string, string> response = new Dictionary<string, string>();
            GameManager game;
            Player player;
            string gameName;
            string message;
            bool success;

            response["type"] = msg["type"];
            try {
                switch (msg["type"]) {
                    case "create-user":
                        bool uuidExists = this.db.uuidExists(msg["uuid"]);
                        bool nameExists = this.db.userExists(msg["username"]);
                        success = (!uuidExists && !nameExists);
                        response["success"] = success.ToString();
                        if (success) {
                            player = this.db.addUser(msg["username"], msg["uuid"]);
                            if (player != null) {
                                this.players.Add(player.Uuid, player);
                            }
                        }
                        else if (nameExists) {
                            response["message"] = String.Format("Username '{0}' is already taken.", msg["username"]);
                        }
                        else if (uuidExists) {
                            response["message"] = String.Format("You have already created a user for this device");
                        }
                        response["username"] = msg["username"];
                        break;
                    case "login":
                        success = this.db.authenticateUser(msg["username"], msg["uuid"]);
                        if (!success) {
                            response["message"] = String.Format("The username '{0}' is not associated with your device.", msg["username"]);
                        }
                        else if (!this.players.ContainsKey(msg["uuid"])) {
                            player = db.loadPlayer(msg["uuid"]);
                            if (player != null) {
                                this.players.Add(player.Uuid, player);
                            }
                            else {
                                success = false;
                                response["message"] = String.Format("An error occurred during login.");
                            }
                        }
                        response["success"] = success.ToString();
                        response["username"] = msg["username"];
                        break;
                    case "joinable":
                        // Trying to join game
                        bool publicGame = true;
                        if (msg.ContainsKey("game") && msg["game"].Length > 0) {
                            gameName = msg["game"];
                            publicGame = false;
                        }
                        else {
                            gameName = GameManager.FindPublicGame();
                        }
                        message = null;
                        success = true;
                        game = GameManager.GetGame(gameName);
                        if (game != null) {
                            success = game.MemberCount < GameManager.MEMBER_LIMIT;
                            if (!success) {
                                message = String.Format("Game '{0}' is full.", gameName);
                            }
                            else {
                                // Success is true
                                response["channel"] = game.GameChannel;
                                response["message"] = game.MemberCount.ToString();

                                // If trying to join private game, notify creator to allow access for new person
                                if (!publicGame) {
                                    Dictionary<string, string> promptAuth = new Dictionary<string, string>(3);
                                    promptAuth["type"] = "authrequest";
                                    promptAuth["requester-name"] = msg["username"];
                                    promptAuth["requester-uuid"] = msg["uuid"];
                                    this.SendMessage(game.CreatorUuid, promptAuth);
                                }
                            }
                        }
                        else {
                            success = false;
                            message = String.Format("Game '{0}' does not exist", gameName);
                        }
                        response["success"] = success.ToString();
                        if (message != null) {
                            response["message"] = message;
                        }
                        break;
                    case "create":
                        // Creating a new game
                        gameName = msg["game"];
                        message = null;
                        success = true;
                        game = GameManager.GetGame(gameName);
                        player = this.GetPlayer(msg["uuid"]);
                        if (player == null) {
                            success = false;
                            message = String.Format("{0} is not a logged in user", msg["username"]);
                        }
                        else if (game == null) {
                            success = true;
                            GameManager.CreateGame(gameName, msg["uuid"]);
                            game = GameManager.GetGame(gameName);
                            game.Join(player);
                            response["channel"] = game.GameChannel;
                        }
                        else {
                            success = false;
                            message = String.Format("Game '{0}' exists already", gameName);
                        }
                        response["success"] = success.ToString();
                        if (message != null) {
                            response["message"] = message;
                        }
                        break;
                    case "stats":
                        player = this.GetPlayer(msg["uuid"]);
                        if (player != null) {
                            response = player.GetStats();
                            response["success"] = true.ToString();
                        }
                        else {
                            response["success"] = false.ToString();
                        }
                        break;
                }
            }
            catch (Exception e) {
                response["type"] = "exception";
            }
            finally {
                this.SendMessage(msg["uuid"], response);
            }
        }

        private static void DefaultCallback(string msg) {
            // okay great
            //Console.WriteLine(msg);
        }

        private static void ErrorCallback(string e) {
            Console.WriteLine("Server error occurred: {0}", e);
        }

        private static void MessageSent(string e) {
            Console.WriteLine("Message sent: {0}", e);
        }

        #endregion PubNub Callbacks

        #region Convenience Methods

        public void SendMessage(string channel, object data) {
            var dict = data as Dictionary<string, string>;
            if (dict != null) {
                Console.Write("{0} sending <{1}>: ", "Server", channel);
                Util.printDict<string, string>(dict);
                Console.WriteLine();
            }
            this.Pubnub.Publish<string>(channel, data, MessageSent, ErrorCallback);
        }

        public Player GetPlayer(string uuid) {
            Player p = null;
            this.players.TryGetValue(uuid, out p);
            return p;
        }

        #endregion Convenience Methods

        #region Statics

        public static void Init() {
            if (instance == null) {
                instance = new Server();
            }
        }

        public static Server GetInstance() {
            return instance;
        }

        #endregion Statics
    }
}