using System;
using System.Collections.ObjectModel;
using System.Collections.Generic;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PubNubMessaging.Core;
using CardGame.GameElements;

namespace CardGame.Server {
    class Server {
        private static Server instance;

        private const string Channel = "PokerServer";
        private const string PubKey = "demo"; //"pub-c-b2d901ee-2a0f-4d89-8cd3-63039aa6dd90";
        private const string SubKey = "demo"; //"sub-c-c74c7cd8-cc8b-11e2-a2ac-02ee2ddab7fe";
        private const string SecretKey = "mySecret";
        private const string Uuid = "server";

        private readonly Dictionary<string, Player> players = new Dictionary<string, Player>();

        private readonly Database db;
        private readonly Pubnub pubnub;
        public Pubnub Pubnub {
            get {
                return this.pubnub;
            }
        }

        private Server() {
            this.pubnub = new Pubnub(PubKey, SubKey, SecretKey) { SessionUUID = Uuid };
            this.pubnub.Subscribe<string>(Channel, this.HandleMessage, DefaultCallback, ErrorCallback);
            //this.pubnub.Presence<string>(this.channel, this.handlePresence, this.defaultCallback);
            Console.WriteLine("Server created.");
            this.db = Database.getInstance();
        }

        /**
         * PubNub Callbacks
         **/
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
            switch (msg["type"]) {
                case "create-user":
                    success = !this.db.userExists(msg["username"]);
                    response["success"] = success.ToString();
                    if (success) {
                        player = this.db.addUser(msg["username"], msg["uuid"]);
                        if (player != null) {
                            this.players.Add(player.Uuid, player);
                        }
                    }
                    else {
                        response["message"] = String.Format("Username '{0}' is already taken.", msg["username"]);
                    }
                    response["username"] = msg["username"];
                    this.SendMessage(msg["uuid"], response);
                    break;
                case "login":
                    success = this.db.authenticateUser(msg["username"], msg["uuid"]);
                    response["success"] = success.ToString();
                    if (!success) {
                        response["message"] = String.Format("The username '{0}' is not associated with your device.", msg["username"]);
                    }
                    else if (!this.players.ContainsKey(msg["uuid"])) {
                        player = new Player(msg["username"], msg["uuid"]);
                        this.players.Add(player.Uuid, player);
                    }
                    this.SendMessage(msg["uuid"], response);
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
                    this.SendMessage(msg["uuid"], response);
                    break;
                case "create":
                    // Creating a new game
                    gameName = msg["game"];
                    message = null;
                    success = true;
                    game = GameManager.GetGame(gameName);
                    if (game == null) {
                        success = true;
                        GameManager.CreateGame(gameName, msg["uuid"]);
                        game = GameManager.GetGame(gameName);
                        game.Join(this.players[msg["uuid"]]);
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
                    this.SendMessage(msg["uuid"], response);
                    //Timer t = new Timer();
                    //t.Interval = 500;
                    //t.Elapsed += (object source, ElapsedEventArgs e) => {
                    //    if (success) {
                    //        response.Clear();
                    //        response["type"] = "player-join";
                    //        response["username"] = msg["username"];
                    //        pubnub.Publish(msg["uuid"], response, (object o) => { Console.WriteLine("Player-join message sent: {0}", msg["username"]); }, errorCallback);
                    //    }
                    //};
                    //t.AutoReset = false;
                    //t.Enabled = true;
                    break;
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

        public void SendMessage(string channel, object data) {
            var dict = data as Dictionary<string, string>;
            if (dict != null) {
                Console.Write("{0} sending <{1}>: ", "Server", channel);
                Util.printDict<string, string>(dict);
                Console.WriteLine();
            }
            this.pubnub.Publish<string>(channel, data, MessageSent, ErrorCallback);
        }

        public Player GetPlayer(string uuid) {
            Player p = null;
            this.players.TryGetValue(uuid, out p);
            return p;
        }

        public static void Init() {
            if (instance == null) {
                instance = new Server();
            }
        }

        public static Server GetInstance() {
            return instance;
        }
    }
}
