%%%-------------------------------------------------------------------
%%% @author yashgolwala
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. Jun 2020 4:37 p.m.
%%%-------------------------------------------------------------------
-module(exchange).
-author("yashgolwala").

%% API

-import('calling',[call/2,callprocess/0]).
-export([start/0,master/2,masterAck/0]).

start() ->
  Result = file:consult("calls.txt"), % returns the tuple
  P = element(2,Result), % transfers list into 2 parts {john,[jill,joe,bob]},{jill,[bob,joe,bob]},
  M1 = maps:from_list(P),

  %io:fwrite("~p~n",[M1]),
  %io:fwrite("~p~n",[Ckey]). %[bob,jill,joe,john,sue]

  master(P,M1).

master(P,M1)->
  io:format("~n** Call to be made **~n",[]),
  maps:fold( fun(K,V, ok)->
    io:format("~p: ~p~n", [K,V])
             end, ok, M1),
  io:fwrite("~n"),
  lists:map( fun(Receiver)->
    {Caller,Receivers} = Receiver,
    MasterPID = spawn(calling,call, [Caller,self()]),
    MasterPID ! {[Caller], [Receivers], self(), 0}
             end, P),
  masterAck().

masterAck()->
  receive
    {Logs}->
      io:fwrite("~nProcess ~w has received no calls for 5 seconds, ending...~n",[Logs]),
      masterAck();

    {[Receiver],[Caller_name], TimeStamp, Flag} ->
      if Flag ==0->
      io:fwrite("~w received intro message from ~w [~w]~n",[Receiver,Caller_name,TimeStamp]),
      masterAck();

      true->
      io:fwrite("~w received reply message from ~w [~w]~n",[Caller_name,Receiver,TimeStamp]),
      masterAck()
      end

  after 10000 -> io:fwrite("~nMaster received no replies for 10 seconds, ending...~n")
  end.








