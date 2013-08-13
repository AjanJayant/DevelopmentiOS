DevelopmentiOS
==============

This repository contains apps written for the iOS platform. It contains:

GMv2
====

This uses the PubNub and UIBubbleTable libraries. It allows users to  
easily send messages to multiple users at the same time.

Card  Game
==========

This iPhone and iPad app uses the PubNub API to implement a poker game.
It is composed of two parts: a client and a server. The server is written in C#, uses SQL-lite
maintains a record of users' money, and implements the rules and games logic. The client 
contains all the UI, and listens to the server while sending messaging to it. Both client and 
server use the PubNub API for communication.
