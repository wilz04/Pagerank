% @alias main.erl
%
% @author Soma <jose.somarribas.escalante@outlook.com>, WilC <wcastro@gsicr.com>
% @since 2017

-module(main).
-compile(export_all).


db_getMVal(Tuple, X, Y) ->
    Col = element(X, Tuple),
    case lists:member(Y, tuple_to_list(Col)) of
        false -> 0;
        true  -> 1/tuple_size(Col)
    end.

db_getAVal(Tuple, X, Y, B) ->
    B*db_getMVal(Tuple, X, Y) + (1 - B)/tuple_size(Tuple).

db_getPage(J, W, NN) ->
    N = trunc(math:sqrt(NN)),
    lists:foldl(
        fun (K, S) ->
            % io:format("~w,\n", [K]),
            L = K rem N,
            if
                L == 0 -> X = N;
                L >  0 -> X = L
            end,
            Y = trunc(((K-X)/N))+1,
            % io:format("(~w, ~w)\n", [X, Y])
            
            case K<N*N+1 of
                true  -> S ++ [[X, Y]];
                false -> S
            end
        end,
        [],
        lists:seq(J, J+W)
    ).

mr_threadize(1) ->
    [ spawn(?MODULE, mr_run, [self()]) ];
mr_threadize(M) ->
    [ spawn(?MODULE, mr_run, [self()]) ] ++ mr_threadize(M-1).

mr_run(APPID) ->
    put(appid, APPID),
    
    receive
        [map, F, G, I, T, NN] ->
            W = round(NN/T),
            J = (I-1)*(W+1)+1,
            % io:format("(~w, ~w)\n", [J, J+W]),
            % io:format("(~w, ~w, ~w, ~w)\n", [I, J, T, NN]),
            F(I, G(J, W, NN)),
            
            mr_run(APPID);
        [red, F, Y, W] ->
            F(Y, W),
            
            mr_run(APPID);
        [] ->
            io:format("") % exit(done_early)
    end.

mr_start(NN, T, M, PIX, F, G, H) ->
	mr_mstart(NN, T, M, PIX, F, H),
    mr_rstart(NN, M, PIX, G).

mr_end(N) ->
	mr_rend(N, sets:new()).

mr_die(PIX) ->
    lists:foreach(fun (PID) -> PID ! [] end, PIX),
    erase().

mr_mstart(NN, T, M, PIX, F, G) ->
    lists:foreach(
        fun (I) ->
            J = I rem M,
            if
                J == 0 -> K = M;
                J >  0 -> K = J
            end,
            
            PID = lists:nth(K, PIX),
            link(PID),
            % io:format("(~w, ~w, ~w)", [I, T, NN])
            PID ! [map, F, G, I, T, NN]
        end,
        lists:seq(1, T)
    ).

mr_rstart(NN, M, PIX, F) ->
	G = mr_mend(NN, sets:new()),
    sets:fold(
        fun (Y, I) ->
            J = I rem M,
            if
                J == 0 -> K = M;
                J >  0 -> K = J
            end,
            
            PID = lists:nth(K, PIX),
            PID ! [red, F, Y, get(Y)],
            
            I + 1
        end,
        1,
        G
    ).

mr_mend(0, M) -> M;
mr_mend(N, M) ->
    receive
        [mr_memit, Y, V] ->
            % io:format("(~w, ~w)\n", [Y, V]),
            W = get(Y),
            case W of
                undefined -> put(Y, [V]);
                _         -> put(Y, W ++ [V])
            end,
            mr_mend(N-1, sets:add_element(Y, M));
        [] ->
            io:format("x_x")
    end.

mr_rend(0, M) -> sets:fold(fun (Y, R) -> R ++ [{Y, get(Y)}] end, [], M);
mr_rend(N, M) ->
    receive
        [mr_remit, Y, Z] ->
            % io:format("(~w, ~w)", [Y, Z]),
            put(Y, Z),
            mr_rend(N-1, sets:add_element(Y, M));
        [] ->
            io:format("x_x")
    end.

mr_memit(Y, V) ->
    % io:format("(~p~n ! ~w, ~w)\n", [get(appid), Y, V]).
    get(appid) ! [mr_memit, Y, V].

mr_remit(Y, Z) ->
    get(appid) ! [mr_remit, Y, Z].

pagerank(M, T, Matrix, R, 0) -> R;
pagerank(M, T, Matrix, R, K) ->
    % io:format("(~w)", [K]),
    B = 0.8,
    
    N = tuple_size(Matrix),
    
    PIX = mr_threadize(M),
    
    % lists:foreach(fun (PID) -> io:format("~p~n", [PID]) end, PIX),
%-ifdef(comment).
    Map = fun (I, S) ->
        lists:foreach(
            fun ([X, Y]) ->
                V = db_getAVal(Matrix, X, Y, B)*lists:nth(X, R),
                % io:format("(~w, ~w: ~w)\n", [X, Y, V]),
                mr_memit(Y, V)
            end,
            S
        )
    end,
    
    Red = fun (Y, W) ->
        Z = lists:sum(W),
        % io:format("(~w, ~w)\n", [Y, Z]),
        mr_remit(Y, Z)
    end,
	
	mr_start(N*N, T, M, PIX, Map, Red, fun (J, W, NN) -> db_getPage(J, W, NN) end),
    
    S = lists:map(fun ({Y, W}) -> W end, lists:keysort(1, mr_end(N))),
    
    mr_die(PIX),
    
    lists:foreach(fun (V) -> io:format("~w, ", [V]) end, S),
    io:format("\n"),
    
    pagerank(M, T, Matrix, S, K-1).
%-endif.
multMatriz(Nodos, Trabajadores, Reductores, Matrix, Vector) ->
    pagerank(
        Nodos,
        Trabajadores,
        Matrix,
        Vector,
        4
    ).

main([_]) ->
    M = {{3, 6}, {2, 5}, {1}, {}, {5, 6}, {2, 3, 4}},
    R = [1/6, 1/6, 1/6, 1/6, 1/6, 1/6],
    N = 6,
    T = 6,
    K = 4,
    S = pagerank(N, T, M, R, K),
    
    % io:format("XXXXXXXX"),
init:stop().
