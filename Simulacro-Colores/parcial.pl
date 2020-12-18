% estampado(patron, lista de colores que tiene)
% liso(color)

% precio(tipo de prenda, tela de la prenda, precio de venta)
% los tipos de tela son: 

precio(remera, estampado(floreado, [rojo, verde, blanco, negro]), 500).
precio(remera, estampado(rayado, [verde, negro, rojo]), 600).
precio(buzo, liso(azul), 1200).
precio(vestido, liso(negro), 3000).
precio(saquito, liso(blanco), 1500).
precio(vestido, estampado(rayado, [negro, blanco]), 1000).
precio(saquito, liso(gris), 2000).

paleta(sobria, negro).	
paleta(sobria, azul).  	
paleta(sobria, blanco).        
paleta(sobria, gris).
paleta(alegre, verde).	
paleta(alegre, blanco).  
paleta(alegre, amarillo).
paleta(furiosa, rojo).  
paleta(furiosa, violeta).  
paleta(furiosa, fucsia).

prenda(prenda(Prenda,Tela)):-
    precio(Prenda,Tela,_).

% PUNTO 1

coloresCombinables(_, negro).

coloresCombinables(negro, _).

coloresCombinables(Color, Combinable):-
    paleta(Paleta, Color),
    paleta(Paleta, Combinable).

% No dice nada respecto al mismo color

:-begin_tests(colores_combinables).
    test(combinables_misma_paleta, nondet):-
        coloresCombinables(azul, blanco).
    test(combinables_con_negro, nondet):-
        coloresCombinables(negro, rojo).
    test(no_combinables, nondet):-
        not(coloresCombinables(verde, rojo)).
:-end_tests(colores_combinables).

% PUNTO 2

% Genera 6 x C/U
% colorinche(prenda(Prenda, estampado(Tipo, Colores))):-
%     precio(Prenda, estampado(Tipo, Colores), _),
%     member(Color, Colores),
%     member(ColorCombinable, Colores),
%     Color \= ColorCombinable,
%     paleta(Paleta, Color),
%     not(paleta(Paleta, ColorCombinable)).

% Genera 2 x C/U
colorinche(prenda(Prenda, estampado(Tipo, [Color | Resto]))):-
    prenda(prenda(Prenda, estampado(Tipo, [Color | Resto]))),
    member(ColorCombinable, Resto),
    paleta(Paleta, Color),
    not(paleta(Paleta, ColorCombinable)).

:-begin_tests(colorinche).
    test(es_colorinche, nondet):-
        colorinche(prenda(remera, estampado(floreado, [rojo, verde, blanco, negro]))).
    test(no_es_colorinche, nondet):-
        not(colorinche(prenda(remera, estampado(floreado, [negro, blanco])))).
:-end_tests(colorinche).

% PUNTO 3

colorDeModa(Color):-
    paleta(_, Color),
    forall(
        precio(_, estampado(_, Colores), _),
        member(Color, Colores)
    ).

:-begin_tests(color_de_moda).
    test(es_color_de_moda, nondet):-
        colorDeModa(negro).
    test(no_es_color_de_moda, nondet):-
        not(colorDeModa(verde)).
:-end_tests(color_de_moda).

% PUNTO 4

condicionCombinan(liso(ColorX), liso(ColorY)):-
    coloresCombinables(ColorX, ColorY).

condicionCombinan(estampado(_, ColoresX), liso(ColorY)):-
    member(ColorX, ColoresX),
    coloresCombinables(ColorX, ColorY).

condicionCombinan(liso(ColorX), estampado(_, ColoresY)):-
    member(ColorY, ColoresY),
    coloresCombinables(ColorX, ColorY).

combinan(prenda(TipoPrendaX, TipoTelaX), prenda(TipoPrendaY, TipoTelaY)):-
    prenda(prenda(TipoPrendaX, TipoTelaX)),
    prenda(prenda(TipoPrendaY, TipoTelaY)),
    condicionCombinan(TipoTelaX, TipoTelaY).

:-begin_tests(combinan).
    test(combinan, nondet):-
        combinan(prenda(saquito, liso(blanco)), prenda(remera, estampado(floreado, [rojo, verde, blanco, negro]))).
    test(no_combinan, nondet):-
        not(combinan(prenda(vestido, liso(negro)), prenda(buzo, liso(rojo)))).
:-end_tests(combinan).

% PUNTO 5

precioMaximo(Prenda, Precio):-
    precio(Prenda, _, Precio),
    forall(precio(Prenda, _, OtroPrecio), Precio >= OtroPrecio).

:-begin_tests(precio_maximo).
    test(es_el_precio_maximo, nondet):-
        precioMaximo(remera, 600).
    test(no_es_el_precio_maximo, nondet):-
        not(precioMaximo(saquito, 1400)).
:-end_tests(precio_maximo).

% PUNTO 6

conjuntoValido(Conjunto):-
    member(Prenda, Conjunto),
    forall(
        member(OtraPrenda, Conjunto),
        combinan(Prenda, OtraPrenda)
    ).

:-begin_tests(conjunto_valido).
    test(conjunto_valido, nondet):-
        conjuntoValido([prenda(vestido, estampado(rayado, [negro,blanco])), prenda(saquito, liso(gris))]).
    test(conjunto_no_valido, nondet):-
        not(conjuntoValido([prenda(saquito, liso(amarillo)), prenda(remera, liso(fucsia)), prenda(pantalon, liso(negro))])).
:-end_tests(conjunto_valido).