Poker Server
============

This is a server written in C# that manages games and users in a Poker game app. It uses PubNub to
communicate with clients.

Running it
==========

Once you clone the code from Git, open the Visual Studio Solution file (.sln). From here you should
be able to run the server.

Configuring
===========

If you're actually adapting this code for your own purposes, you'll probably want to substitute your
own publish/subscribe/secret keys in Server.js at the top of the file.
