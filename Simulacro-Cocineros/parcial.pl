% principal(nombre, calorias).
% entrada(nombre, ingredientes, calorias).
% postre(nombre, sabor principal, calorias).

%cocina(nombre, plato, puntos).
cocina(matias, principal(milanga, 80), 60).
cocina(mariano, principal(nioquis, 50), 80).
cocina(julia, principal(pizza, 100), 60).
cocina(hernan, postre(panqueque, dulceDeLeche, 100), 60).
cocina(hernan, postre(trufas, dulceDeLeche, 60), 80).
cocina(hernan, entrada(ensalada, [tomate, zanahoria, lechuga], 70), 29).
cocina(susana, entrada(empanada, [carne, cebolla, papa], 50), 50).
cocina(susana, postre(pastelito, dulceDeMembrillo, 50), 60).
cocina(melina, postre(torta, zanahoria, 60),50).

% esAmigo(persona, su amigo).
esAmigo(mariano, susana).
esAmigo(mariano, hernan).
esAmigo(hernan, pedro).
esAmigo(melina, carlos).
esAmigo(carlos, susana).
% no se declara un esAmigo(susana, ...) porque susana no tiene amigos

% ingredientePopular(ingrediente).
ingredientePopular(carne).
ingredientePopular(dulceDeLeche).
ingredientePopular(dulceDeMembrillo).

% PUNTO 1 - COMIDA SALUDABLE

caloriasSaludables(principal(_, Calorias)):-
    between(70, 90, Calorias).

caloriasSaludables(entrada(_, _, Calorias)):-
    Calorias =< 60.

caloriasSaludables(postre(_, _, Calorias)):-
    Calorias < 100.

comidaSaludable(Comida):-
    cocina(_, Comida, _),
    caloriasSaludables(Comida).

:-begin_tests(comida_saludable).
    test(principal_saludable, nondet):-
        comidaSaludable(principal(milanga, 80)).
    test(entrada_saludable, nondet):-
        comidaSaludable(entrada(empanada, [carne, cebolla, papa], 50)).
    test(postre_saludable, nondet):-
        comidaSaludable(postre(trufas, dulceDeLeche, 60)).
    test(no_saludable, nondet):-
        not(comidaSaludable(principal(nioquis, 50))).
:-end_tests(comida_saludable).

% PUNTO 2 - SOLO SALADO
soloSalado(Cocinero):-
    cocina(Cocinero, _, _),
    not(cocina(Cocinero, postre(_,_,_), _)).

:-begin_tests(solo_salado).
    test(solo_salado, nondet):-
        soloSalado(mariano).
    test(no_solo_salado, nondet):-
        not(soloSalado(hernan)).
:-end_tests(solo_salado).

% PUNTO 3 - TIENE UNA GRAN FAMA

puntos(Cocinero, Puntos):-
    findall(Punto, cocina(Cocinero, _, Punto), ListaPuntos),
    sum_list(ListaPuntos, Puntos).

condicionTieneUnaGranFama(Cocinero, Puntos):-
    cocina(CocineroAux, _, _),
    Cocinero \= CocineroAux,
    puntos(CocineroAux, Puntos).

tieneUnaGranFama(Cocinero):-
    cocina(Cocinero, _ , _),
    puntos(Cocinero, PuntosCocinero),
    forall(
        condicionTieneUnaGranFama(Cocinero, PuntosOtroCocinero),
        PuntosCocinero>PuntosOtroCocinero
    ).

:-begin_tests(tiene_una_gran_fama).
    test(tiene_una_gran_fama, nondet):-
        tieneUnaGranFama(hernan).
    test(no_tiene_una_gran_fama, nondet):-
        not(tieneUnaGranFama(mariano)).
:-end_tests(tiene_una_gran_fama).

% PUNTO 4 - NO ES SALUDABLE

condicionSaludable(Cocinero, Comida):-
    cocina(Cocinero, Comida, _),
    comidaSaludable(Comida).

noEsSaludable(Cocinero):-
    cocina(Cocinero, _, _),
    findall(Comida, condicionSaludable(Cocinero, Comida), Comidas),
    length(Comidas, 1).

:-begin_tests(no_es_saludable).
    test(no_es_saludable, nondet):-
        noEsSaludable(hernan).
    test(es_saludable, nondet):-
        not(noEsSaludable(mariano)).
:-end_tests(no_es_saludable).

% PUNTO 5 - NO USA INGREDIENTES POPULARES

usaIngredientePopular(postre(_, Sabor, _)):-
    ingredientePopular(Sabor).

usaIngredientePopular(entrada(_, Ingredientes, _)):-
    member(Ingrediente, Ingredientes),
    ingredientePopular(Ingrediente).

% No es necesario consultar el caso de principal dado q ese no posee ingredientes -> es falso

noUsaIngredientesPopulares(Cocinero):-
    cocina(Cocinero, _, _),
    forall(cocina(Cocinero, Comida, _), not(usaIngredientePopular(Comida))).

:-begin_tests(no_usa_ingredientes_populares).
    test(no_usa_ingredientes_populares, nondet):-
        noUsaIngredientesPopulares(mariano).
    test(usa_ingredientes_populares, nondet):-
        not(noUsaIngredientesPopulares(hernan)).
:-end_tests(no_usa_ingredientes_populares).

% PUNTO 6 - INGREDIENTE POPULAR MAS USADO

occurrences(Element,[Head|Tail], Count, OutputCount) :-
    Element = Head,
    NewCount is Count + 1,
    occurrences(Element, Tail, NewCount, OutputCount).

occurrences(Element, [Head|Tail], Count, OutputCount) :-
    Element \= Head,
    occurrences(Element, Tail, Count, OutputCount).

occurrences(_,[],Count,Count).

occurrences(Element, List, Count) :- occurrences(Element, List, 0, Count).

buscarIngredienteMasRepetido(postre(_, Ingrediente, _), Ingrediente):-
    ingredientePopular(Ingrediente).

buscarIngredienteMasRepetido(entrada(_, Ingredientes, _), Ingrediente):-
    member(Ingrediente, Ingredientes),
    occurrences(Ingrediente, Ingredientes, Count)
    forall(
        member(Ing, Ingredientes),
        (
            occurrences(Ing, Ingredientes, CountIng),
            Count >= CountIng
        )
    ).

ingredientePopularMasUsado(NombreCocinero, Ingrediente) :-
    cocina(NombreCocinero, Plato, _),
    buscarIngredienteMasRepetido(Plato, Ingrediente).

:-begin_tests(ingrediente_popular_mas_usado).
    test(ingrediente_popular_mas_usado, nondet):-
        ingredientePopularMasUsado(hernan, dulceDeLeche).
    test(no_tiene_ingrediente_popular_mas_usado, nondet):-
        not(ingredientePopularMasUsado(mariano, _)).
:-end_tests(ingrediente_popular_mas_usado).

% PUNTO 7 - ES RECOMENDADO POR COLEGA

sonAmigos(Cocinero, Colega):-
    esAmigo(Colega, Cocinero).

sonAmigos(Cocinero, Colega):-
    esAmigo(Colega, ColegaColega),
    sonAmigos(Cocinero, ColegaColega).

esRecomendadoPorColega(Cocinero, Colega):-
    cocina(Cocinero, _, _),
    not(noEsSaludable(Cocinero)),
    sonAmigos(Cocinero, Colega).

:-begin_tests(es_recomendado_por_colega).
    test(es_recomendado_por_colega, nondet):-
        esRecomendadoPorColega(susana, mariano).
    test(no_es_recomendado_por_colega, nondet):-
        not(esRecomendadoPorColega(mariano, susana)). % FALLA PQ SUSANA NO TIENE AMIGOS : FFFF
:-end_tests(es_recomendado_por_colega).