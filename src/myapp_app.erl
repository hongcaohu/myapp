-module(myapp_app).

-behaviour(application).
-include_lib("amqp_client/include/amqp_client.hrl").

%% Application callbacks
-export([start/2, stop/1]).
-export([test/0]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    myapp_sup:start_link().

stop(_State) ->
    ok.


test() ->
    %% Start a network connection
    {ok, Connection} =
    amqp_connection:start(
        #amqp_params_network{
            host = "47.99.55.196",
            username = <<"admin">>,
            password = <<"123456">>
        }),
    io:format("connection"),
    %% Open a channel on the connection
    {ok, Channel} = amqp_connection:open_channel(Connection),
    %% Declare a queue
    %% #'queue.declare_ok'{queue = Q} = amqp_channel:call(Channel, #'queue.declare'{}),
    %% Publish a message
    Payload = <<"foobar">>,
    Publish = #'basic.publish'{exchange = <<"amq.topic">>, routing_key = <<"bridge.aws.topic2.test">>},
    amqp_channel:cast(Channel, Publish, #amqp_msg{payload = Payload}),
    %% Get the message back from the queue
    %% Get = #'basic.get'{queue = Q},
    %% {#'basic.get_ok'{delivery_tag = Tag}, Content}
    %% = amqp_channel:call(Channel, Get),
    %% #amqp_msg{payload = Body} = Content,
    %% io:format("Body:~p~n",[Body]),
    %% Do something with the message payload
    %% (some work here)

    %% Ack the message
    %% amqp_channel:cast(Channel, #'basic.ack'{delivery_tag = Tag}),

    %% Close the channel
    amqp_channel:close(Channel),
    %% Close the connection
    amqp_connection:close(Connection),

    ok.
