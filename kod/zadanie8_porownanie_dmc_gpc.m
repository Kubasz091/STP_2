function zadanie8_porownanie_dmc_gpc(Gz, param_dmc, param_gpc, param_pid, param_sym, wart_zad)
%% zadanie 8
% a) Porównanie dla zmiany wartości zadanej
figure;
subplot(2,1,1);
hold on;
grid on;
title('Porównanie odpowiedzi układu dla regulatorów DMC i GPC');
xlabel('Czas [s]');
ylabel('Wyjście');

subplot(2,1,2);
hold on;
grid on;
title('Porównanie sygnałów sterujących regulatorów DMC i GPC');
xlabel('Czas [s]');
ylabel('Sterowanie');

[~, y_dmc, ~, u_dmc, ~, ~] = symulacja_dmc_pid(param_dmc, param_sym, param_pid, Gz);
[y_gpc, u_gpc, czas_sym, D] = symulacja_gpc(param_gpc, param_sym, Gz);

subplot(2,1,1);
plot(czas_sym(D:end), y_dmc(D:end), czas_sym(D:end), y_gpc(D:end), czas_sym(D:end), wart_zad, '-');

subplot(2,1,2);
plot(czas_sym(D:end), u_dmc(D:end), czas_sym(D:end), u_gpc(D:end), '-');

subplot(2,1,1);
legend('DMC', 'GPC', 'wartość zadana', 'Location', 'best');

subplot(2,1,2);
legend('DMC', 'GPC', 'Location', 'best');

saveas(gcf, 'wykresy/DMC_vs_GPC_setpoint.jpg');
close;

% b) Porównanie dla zakłócenia
zaklocenie = 0.3;

figure;
subplot(2,1,1);
hold on;
grid on;
title('Porównanie odpowiedzi układu dla regulatorów DMC i GPC (z zakłóceniem)');
xlabel('Czas [s]');
ylabel('Wyjście');

subplot(2,1,2);
hold on;
grid on;
title('Porównanie sygnałów sterujących regulatorów DMC i GPC');
xlabel('Czas [s]');
ylabel('Sterowanie');

[~, y_dmc, ~, u_dmc, ~, ~] = symulacja_dmc_pid(param_dmc, param_sym, param_pid, Gz, zaklocenie, true);
[y_gpc, u_gpc, czas_sym, D] = symulacja_gpc(param_gpc, param_sym, Gz, zaklocenie, true);

subplot(2,1,1);
plot(czas_sym(D:end), y_dmc(D:end), czas_sym(D:end), y_gpc(D:end), '-');
plot(czas_sym(D:end), ones(1, length(czas_sym(D:end)))*zaklocenie, '--', czas_sym(D:end), wart_zad, '--', 'MarkerSize', 3);

subplot(2,1,2);
plot(czas_sym(D:end), u_dmc(D:end), czas_sym(D:end), u_gpc(D:end), '-');

subplot(2,1,1);
legend('DMC', 'GPC', 'zakłócenie', 'wartość zadana', 'Location', 'best');

subplot(2,1,2);
legend('DMC', 'GPC', 'Location', 'best');

saveas(gcf, 'wykresy/DMC_vs_GPC_disturbance.jpg');
close;
end
