# snap-websockets-broken
A simple example project that shows that Snap does not log errors from within the Snap Websocket handler


Run using `stack build && stack exec snap-websockets-broken`

The example HTML will send a request to the server, and hope for many responses. 
However, the WebSocket handler crashes when parsing an XML Product that has a title with an improper UTF-8 character in it:

- (See [this line in ExampleFetcher.hs](https://github.com/Qqwy/snap-websockets-broken/blob/master/src/SnapWebsocketsBroken/ExampleFetcher.hs#L63) that contains the malformed XML
-  [this line in ExampleFetcher.hs](https://github.com/Qqwy/snap-websockets-broken/blob/master/src/SnapWebsocketsBroken/ExampleFetcher.hs#L99) is where the string conversion (LByteString -> Text) happens that throws an exception).

But rather than failing and logging an error, the websocket connection 'just closes' without anyone being any wiser.
