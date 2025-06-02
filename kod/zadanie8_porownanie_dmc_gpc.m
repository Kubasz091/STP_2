function zadanie8_porownanie_dmc_gpc(Gz, param_dmc, param_gpc, param_pid, ...
    param_sym, wart_zad)
% a
figure('Position', [100, 100, 800, 600]);
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

[~, y_dmc, ~, u_dmc, ~, ~] = symulacja_dmc_pid(param_dmc, param_sym, ...
    param_pid, Gz);
[y_gpc, u_gpc, czas_sym, D] = symulacja_gpc(param_gpc, param_sym, Gz);

subplot(2,1,1);
plot(czas_sym(D:end), y_dmc(D:end), 'b-', 'LineWidth', 2);
plot(czas_sym(D:end), y_gpc(D:end), 'r-', 'LineWidth', 2);
plot(czas_sym(D:end), wart_zad, 'k--', 'LineWidth', 1.5);
legend('DMC', 'GPC', 'wartość zadana', 'Location', 'best');

subplot(2,1,2);
plot(czas_sym(D:end), u_dmc(D:end), 'b-', 'LineWidth', 2);
plot(czas_sym(D:end), u_gpc(D:end), 'r-', 'LineWidth', 2);
legend('DMC', 'GPC', 'Location', 'best');

saveas(gcf, 'wykresy/DMC_vs_GPC_setpoint.jpg');
close;

% b
zaklocenie = 0.3;

figure('Position', [100, 100, 800, 600]);
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

[~, y_dmc, ~, u_dmc, ~, ~] = symulacja_dmc_pid(param_dmc, param_sym, ...
    param_pid, Gz, zaklocenie, true);
[y_gpc, u_gpc, czas_sym, D] = symulacja_gpc(param_gpc, param_sym, ...
    Gz, zaklocenie, true);

subplot(2,1,1);
plot(czas_sym(D:end), y_dmc(D:end), 'b-', 'LineWidth', 2);
plot(czas_sym(D:end), y_gpc(D:end), 'r-', 'LineWidth', 2);
plot(czas_sym(D:end), ones(1, length(czas_sym(D:end)))*zaklocenie, 'k--', 'LineWidth', 1.5);
plot(czas_sym(D:end), wart_zad, 'm--', 'LineWidth', 1.5);
legend('DMC', 'GPC', 'zakłócenie', 'wartość zadana', 'Location', 'best');

subplot(2,1,2);
plot(czas_sym(D:end), u_dmc(D:end), 'b-', 'LineWidth', 2);
plot(czas_sym(D:end), u_gpc(D:end), 'r-', 'LineWidth', 2);
legend('DMC', 'GPC', 'Location', 'best');

saveas(gcf, 'wykresy/DMC_vs_GPC_disturbance.jpg');
close;
end
