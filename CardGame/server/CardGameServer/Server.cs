using System;
using System.Collections.ObjectModel;
using System.Collections.Generic;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PubNubMessaging.Core;

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
            this.pubnub.Subscribe<string>(this.channel, this.handleMessage, this.defaultCallback);
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
            Console.WriteLine("Server message: {0}", container);
            Dictionary<string, string> msg = container.ToObject<Dictionary<string, string>>();

            /**
             * Local variables for the switch block
             **/
            Dictionary<string, string> response = new Dictionary<string, string>();
            GameManager game;
            string gameName;
            string message;
            bool success;
            Console.WriteLine(msg);
            switch (msg["type"]) {
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
                            response.Add("channel", game.GameChannel);
                            response.Add("message", game.MemberCount.ToString());

                            // If trying to join private game, notify creator to allow access for new person
                            if (!publicGame) {
                                Dictionary<string, string> promptAuth = new Dictionary<string, string>(2);
                                promptAuth.Add("target", game.CreatorUUID);
                                promptAuth.Add("requesterName", msg["username"]);
                                promptAuth.Add("requesterUUID", msg["uuid"]);
                                this.pubnub.Publish(this.channel, promptAuth, this.defaultCallback);
                            }
                        }
                    }
                    else {
                        success = false;
                        message = String.Format("Game '{0}' does not exist", gameName);
                    }
                    response.Add("target", msg["uuid"]);
                    response.Add("success", success.ToString());
                    if (message != null) {
                        response.Add("message", message);
                    }
                    this.pubnub.Publish(this.channel, response, (object d) => { Console.WriteLine("Message sent: {0}", d); });
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
                        response.Add("channel", game.GameChannel);
                    }
                    else {
                        success = false;
                        message = String.Format("Game '{0}' exists already", gameName);
                    }
                    response.Add("target", msg["uuid"]);
                    response.Add("success", success.ToString());
                    if (message != null) {
                        response.Add("message", message);
                    }
                    this.pubnub.Publish(this.channel, response, (object d) => { Console.WriteLine("Message sent: {0}", d); });
                    break;
            }
        }

        private void defaultCallback(object msg) {
            // okay great
            Console.WriteLine(msg);
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
