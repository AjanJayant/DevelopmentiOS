PubNubAutoKeyUpdate
==============

PubNubAutoKeyUpdate provides a developer-friendly library for linking keys in different applications with a simple method call.

SETUP
====

1. This library requires you to add PubNub to your project. For more information, check out the [PubNub Objective-C library](https://github.com/pubnub/objective-c/tree/master/iOS). Also see 4.
2. After adding PubNub, simply drop the src directory into your application folder. 
3. Import the PubNubkeyUpdate.h file in the method file whose keys you want automatically updated. 
4. Guarantee that while setting up PubNub, your subscribe and publish keys match the applications across which you're trying synchronize keys-values
5. Start coding!

HOW TO
======

There are two class methods which you use to synchronize the key-values across the applications. They are: **subscribeToChannelWithUpdates** and **unsubscribeFromChannelWithUpdates**.
subscribeToChannelWithUpdates returns no value and is passed four arguments.
 
1. The first argument specifies the object whose keys must be updated. It must be of type id.
2. The second argument specifies the name channel which the developer wants to synchronize the keys on. It is a good idea not use this channel name for any other purpose. It must be of type NSString.
3. The third argument specifies a list of names for the keys whose values will be synchronized. Please note that if the developer wants an UI object's keys to be synchronized, the name of the key differs from the name of the variable. 
For example, if there's a UILabel called balanceLabel, they key will be called balanceLabel.text. The argument must be of type NSSArray.
4. The fourth argument specifies a block variable, which will be used in the event of an exception. The argument is a block variable of type void which has no arguments.
unsubscribeFromChannelWithUpdates must be passed the original name of the channel.

HELP
====

If there are any issues with using the library, feel free to send me an email at the address listed on my Github page. Cheers!