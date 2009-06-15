-module(whocares).

-behaviour(gen_server).

%% API
-export([start_link/1]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
     terminate/2, code_change/3]).

%% our erlang API: (we expose erlang and thrift methods)
-export([whocares/2]).

-record(state, {thrift}).

-define(SERVER, {global, ?MODULE}).

start_link(Port) ->
    gen_server:start_link(?SERVER, ?MODULE, [Port], []).

whocares(Type, Id) when is_integer(Type), is_integer(Id) ->
    gen_server:call(?SERVER, {whocares, Type, Id}).

%%====================================================================
%% gen_server callbacks
%%====================================================================
init([Port]) ->
    {ok, T} = thrift_socket_server:start([
                    {handler, ?MODULE},
                    {service, wcdb_thrift},
                    {port, Port},
                    {name, wcdb_thrift_server}
                    ]),
    link(T),
    {ok, #state{thrift=T}}.

handle_call({whocares, Type, Id}, From, State) ->
    F = fun() ->
            List = whocares_handler:whocares(Type, Id),
            gen_server:reply(From, List)
        end,
    spawn(F),
    {noreply, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, State) ->
    thrift_socket_server:stop(State#state.thrift),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%--------------------------------------------------------------------
%%% Internal functions
%%--------------------------------------------------------------------

