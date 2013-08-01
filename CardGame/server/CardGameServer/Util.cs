using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Timers;

namespace CardGame {
    class Util {
        public static void printDict<K, V>(Dictionary<K, V> d) {
            Console.WriteLine("{");
            foreach (KeyValuePair<K, V> entry in d) {
                Console.WriteLine("  {0}: {1}", entry.Key, entry.Value);
            }
            Console.WriteLine("}");
        }

        public static void setTimeout(Action func, double delay) {
            Timer t = new Timer(delay);
            t.AutoReset = false;
            t.Elapsed += (object src, ElapsedEventArgs e) => {
                func();
            };
            t.Enabled = true;
        }
    }
}
