using System;
using System.Collections.ObjectModel;
using System.Collections.Generic;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PubNubMessaging.Core;

namespace PNServerTest {
    class Server {
        private static Server instance;

        private string channel = "csharptest";
        private string pubKey = "pub-c-b2d901ee-2a0f-4d89-8cd3-63039aa6dd90";
        private string subKey = "sub-c-c74c7cd8-cc8b-11e2-a2ac-02ee2ddab7fe";

        private DBConnector db;

        private Pubnub pubnub;
        private string uuid = "trivia-server";

        private Server() {
            this.pubnub = new Pubnub(this.pubKey, this.subKey);
            this.pubnub.SessionUUID = this.uuid;
            this.pubnub.Subscribe<string>(this.channel, this.handleMessage, this.defaultCallback);
            Console.WriteLine("Server created.");
            this.db = DBConnector.getInstance();
        }

        /**
         * PubNub Callbacks
         **/
        private void handlePresence(string msg) {
        }

        private void handleMessage(string json) {
            var coll = JsonConvert.DeserializeObject<ReadOnlyCollection<object>>(json);
            JContainer container = coll[0] as JContainer;
            Console.WriteLine(container);
            if (container["uuid"] != null) {
                Console.WriteLine("User added: {0}", 1 == this.db.addUser((string)container["uuid"]));
            }
        }

        private void defaultCallback(string msg) {
            // okay great
        }

        public static void init() {
            if (instance == null) {
                instance = new Server();
            }
        }
    }
}
