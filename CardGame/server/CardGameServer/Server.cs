using System;
using System.Collections.ObjectModel;
using System.Collections.Generic;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PubNubMessaging.Core;
using System.Timers;

namespace CardGame {
    class Server {
        private static Server instance;

        private string channel = "PokerServer";
        private string pubKey = "demo"; //"pub-c-b2d901ee-2a0f-4d89-8cd3-63039aa6dd90";
        private string subKey = "demo"; //"sub-c-c74c7cd8-cc8b-11e2-a2ac-02ee2ddab7fe";
        private string secretKey = "mySecret";

        private Database db;

        private Pubnub pubnub;
        public Pubnub Pubnub {
            get {
                return this.pubnub;
            }
        }
        private string uuid = "server";

        private Server() {
            this.pubnub = new Pubnub(this.pubKey, this.subKey, this.secretKey);
            this.pubnub.SessionUUID = this.uuid;
            this.pubnub.Subscribe<string>(this.channel, this.handleMessage, this.defaultCallback, errorCallback);
            //this.pubnub.Presence<string>(this.channel, this.handlePresence, this.defaultCallback);
            Console.WriteLine("Server created.");
            this.db = Database.getInstance();
        }

        /**
         * PubNub Callbacks
         **/
        private void handlePresence(string json) {
            var coll = JsonConvert.DeserializeObject<ReadOnlyCollection<object>>(json);
            JContainer container = coll[0] as JContainer;
            Console.WriteLine("Server presence: {0}", container);
        }

        private void handleMessage(string json) {
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
            string gameName;
            string message;
            bool success;

            response["type"] = msg["type"];
            switch (msg["type"]) {
                case "create-user":
                    success = !this.db.userExists(msg["username"]);
                    response["success"] = success.ToString();
                    if (success) {
                        this.db.addUser(msg["username"], msg["uuid"]);
                    }
                    else {
                        response["message"] = String.Format("Username '{0}' is already taken.", msg["username"]);
                    }
                    response["username"] = msg["username"];
                    this.sendMessage(msg["uuid"], response);
                    break;
                case "login":
                    success = this.db.authenticateUser(msg["username"], msg["uuid"]);
                    response["success"] = success.ToString();
                    if (!success) {
                        response["message"] = String.Format("The username '{0}' is not associated with your device.", msg["username"]);
                    }
                    this.sendMessage(msg["uuid"], response);
                    break;
                case "joinable":
                    // Trying to join game
                    bool publicGame = true;
                    if (msg.ContainsKey("game") && msg["game"].Length > 0) {
                        gameName = msg["game"];
                        publicGame = false;
                    }
                    else {
                        gameName = GameManager.findPublicGame();
                    }
                    message = null;
                    success = true;
                    game = GameManager.getGame(gameName);
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
                                this.sendMessage(game.CreatorUUID, promptAuth);
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
                    this.sendMessage(msg["uuid"], response);
                    break;
                case "create":
                    // Creating a new game
                    gameName = msg["game"];
                    message = null;
                    success = true;
                    game = GameManager.getGame(gameName);
                    if (game == null) {
                        success = true;
                        GameManager.createGame(gameName, msg["uuid"]);
                        game = GameManager.getGame(gameName);
                        game.join(msg["uuid"], msg["username"]);
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
                    this.sendMessage(msg["uuid"], response);
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

        private void defaultCallback(string msg) {
            // okay great
            //Console.WriteLine(msg);
        }

        private void errorCallback(string e) {
            Console.WriteLine("Server error occurred: {0}", e);
        }

        private void messageSent(string e) {
            Console.WriteLine("Message sent: {0}", e);
        }

        public void sendMessage(string channel, object data) {
            var dict = data as Dictionary<string, string>;
            if (dict != null) {
                Console.Write("{0} sending <{1}>: ", "Server", channel);
                Util.printDict<string, string>(dict);
                Console.WriteLine();
            }
            this.pubnub.Publish<string>(channel, data, this.messageSent, this.errorCallback);
        }
        /**
         * PubNub Callbacks
         **/
        public static void init() {
            if (instance == null) {
                instance = new Server();
            }
        }

        public static Server getInstance() {
            return instance;
        }
    }
}
