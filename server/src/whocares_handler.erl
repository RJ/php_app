-module(whocares_handler).

% thrift exports:
-export([handle_function/2, whocares/2]).

% thrift handler funs:
whocares(Type, Id) when is_integer(Type), is_integer(Id) ->
    Code = io_lib:format("return whocares(~w,~w);", [Type, Id]),
    case php:eval(Code) of
        {ok, _, Ret, _, _} ->
            Uids = [    begin 
                            {Int, _Rest} = string:to_integer(binary_to_list(S)), 
                            Int 
                        end
                        || {_Idx, S} <- Ret ],
            Uids;
        {exit, timeout} -> [];
        X -> X
    end.

handle_function(Function, Args) when is_atom(Function), is_tuple(Args) ->
    case apply(?MODULE, Function, tuple_to_list(Args)) of
        ok -> ok;
        Reply -> {reply, Reply}
    end.
