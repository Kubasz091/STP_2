% --- Główny skrypt projektu ---
clearvars;
clc;
close all;

% Parametry obiektu
Ko = 4.7;
To = 5;
T1 = 1.92;
T2 = 4.96;
Tp = 0.5;

% Zadanie 1
disp('--- Zadanie 1 ---');
[Gs, Gz] = zadanie1_analiza_transmitancji(Ko, To, T1, T2, Tp);

% Zadanie 2
disp('--- Zadanie 2 ---');
zadanie2_rownanie_roznicowe(Gz);

% Zadanie 3
disp('--- Zadanie 3 ---');
[param_pid, param_pid_ciagly] = zadanie3_strojenie_pid_ziegler_nichols(Gs, Tp);

% Parametry symulacji
param_sym = struct('len', 250, 'tp', 0.5, 'setpoint', 2);
wart_zad = ones(1, param_sym.len - 69) * 2;

% Zadanie 5
disp('--- Zadanie 5 ---');
param_dmc_opt = zadanie5_optymalizacja_dmc(Gz, param_pid, param_sym, wart_zad);

% Zadanie 6
disp('--- Zadanie 6 ---');
zadanie6_porownanie_optymalne_dmc_pid(Gz, param_pid, param_dmc_opt, param_sym, wart_zad);

% Zadanie 8
disp('--- Zadanie 8 ---');
param_gpc = param_dmc_opt; % Parametry GPC takie same jak DMC
zadanie8_porownanie_dmc_gpc(Gz, param_dmc_opt, param_gpc, param_pid, param_sym, wart_zad);

% Zadanie 9
disp('--- Zadanie 9 ---');
zadanie9_badanie_stabilnosci(param_pid, param_dmc_opt, param_gpc, Ko, To, T1, T2, Tp, param_sym);

disp('--- Koniec projektu ---');