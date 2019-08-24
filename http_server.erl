-module(http_server).
-compile([export_all]).


intialize_server(Port)->
	spawn(?MODULE,listen_Server,[Port]).

listen_Server(Port)->
	{ok,Socket}=gen_tcp:listen(Port,[{active,false},{backlog,10}]),
	%active option set as falsr specify that the packets sent from the peer are not delivered as message
	%backlog specify that 10 connection can be in queue, if not specified default value is 5
	accept_server(Socket).

accept_server(Socket)->
	{ok,Sock}=gen_tcp:accept(Socket),
	Handle=spawn(?MODULE,handleFunc,[Sock]),
	gen_tcp:controlling_process(Sock, Handle),
	accept_server(Socket).

handleFunc(Sock)->
	Message=message("Hello, this is a server"),
	gen_tcp:send(Sock,Message),
	gen_tcp:close(Sock).

message(Msg) ->
	B = iolist_to_binary(Msg),
	iolist_to_binary(io_lib:fwrite("HTTP/1.0 200 OK\nContent-Type: text/html\nContent-Length: ~p\n\n~s",
         [size(B), B])).


