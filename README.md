# snap-websockets-broken
A simple example project that shows that Snap does not log errors from within the Snap Websocket handler


Run using `stack build && stack exec snap-websockets-broken`

The example HTML will send a request to the server, and hope for many responses. 
However, the WebSocket handler crashes when parsing an XML Product that has a title with an improper UTF-8 character in it.

But rather than failing and logging an error, the websocket connection 'just closes' without anyone being any wiser.
