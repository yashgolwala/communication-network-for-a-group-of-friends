%%%-------------------------------------------------------------------
%%% @author yashgolwala
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 19. Jun 2020 10:47 a.m.
%%%-------------------------------------------------------------------
-module(calling).
-author("yashgolwala").

%% API
-export([call/2,callprocess/0]).

call(Caller,MasterPID)->
  receive
    {[Caller_name],[Receivers], MasterPID, Flag}
      when Flag==0 ->
      %io:fwrite("~n ~w ~w ~w ~w ~n",[Caller_name,Receivers,MasterPID,Flag]),
      lists:map( fun(Receiver)->
        CallerPID = spawn(calling,callprocess,[]),
        CallerPID ! {[Caller_name], [Receiver], MasterPID, self(), element(3,now()), 0}
                 end, Receivers),
      call(Caller,MasterPID)

  after 5000-> MasterPID ! {Caller}
  end.

callprocess()->
  receive
    {[Caller_name],[Receiver], MasterPID, CallerPID, TimeStamp, 0}->
        %io:fwrite("~n ~w ~w ~w ~w ~w ~n",[Caller_name,Receiver,MasterPID,CallerPID,TimeStamp]),
        timer:sleep(rand:uniform(100)),
        MasterPID ! {[Receiver],[Caller_name], TimeStamp,0},
        ReceiverPID = spawn(calling,callprocess,[]),
        ReceiverPID ! {[Caller_name],[Receiver],TimeStamp,MasterPID, 1},
        callprocess();

    {[Caller_name],[Receiver], TimeStamp, MasterPID, 1}->
        %io:fwrite("~n ~w ~w ~w ~w",[Caller_name,Receiver,MasterPID,TimeStamp]),
        timer:sleep(rand:uniform(100)),
        MasterPID ! {[Caller_name],[Receiver], TimeStamp,1},
        callprocess()

  after 1000-> true
  end.