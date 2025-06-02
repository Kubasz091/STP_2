function [param_dmc_opt] = zadanie5_optymalizacja_dmc(Gz, param_pid, ...
    param_sym, wart_zad)
% a
fig = figure;
step(Gz);
h = findobj(gca, 'Type', 'Line');
set(h, 'LineWidth', 2);

grid on;
title('Odpowiedź skokowa obiektu G(z)');
xlabel('Czas [s]');
ylabel('Amplituda wyjścia');
saveas(fig, 'wykresy/step.jpg');
close;

% b
wartosci_N = [70, 40, 20, 10];
figure;
subplot(2,1,1);
hold on;
grid on;
title('Wpływ horyzontu predykcji N na jakość regulacji (przy Nu=N)');
xlabel('Czas [s]');
ylabel('Wyjście procesu');

subplot(2,1,2);
hold on;
grid on;
title('Sygnały sterujące dla różnych horyzontów predykcji N');
xlabel('Czas [s]');
ylabel('Sterowanie');
legendy = {};

colors = {'b', 'r', 'g', 'm'};
linestyles = {'-', '--', ':', '-.'};
for i = 1:length(wartosci_N)
    N_test = wartosci_N(i);
    param_dmc = struct('N', N_test, 'Nu', N_test, 'lambda', 1, 'D', 70);
    [~, y_dmc, ~, u_dmc, czas_sym, D] = symulacja_dmc_pid(param_dmc, ...
        param_sym, param_pid, Gz);

    subplot(2,1,1);
    plot(czas_sym(D:end), y_dmc(D:end), [colors{i}, linestyles{i}], 'LineWidth', 2);

    subplot(2,1,2);
    plot(czas_sym(D:end), u_dmc(D:end), [colors{i}, linestyles{i}], 'LineWidth', 2);

    legendy{end+1} = sprintf('N = Nu = %d', N_test);
end

subplot(2,1,1);
plot(czas_sym(D:end), wart_zad, 'k--', 'LineWidth', 1.5);
legendy{end+1} = 'Wartość zadana';

subplot(2,1,1);
legend(legendy, 'Location', 'best');

subplot(2,1,2);
legend(legendy{1:end-1}, 'Location', 'best');

saveas(gcf, 'wykresy/horyzont_predykcji_porownanie.jpg');
close;

N_opt = 20;

% c
wartosci_Nu = [70, 50, 30, 15, 5, 1];

figure;
subplot(2,1,1);
hold on;
grid on;
title(['Wpływ horyzontu sterowania Nu na jakość regulacji (N = ', num2str(N_opt), ')']);
xlabel('Czas [s]');
ylabel('Wyjście procesu');

subplot(2,1,2);
hold on;
grid on;
title('Sygnały sterujące dla różnych horyzontów sterowania Nu');
xlabel('Czas [s]');
ylabel('Sterowanie');

legendy = {};
colors = {'b', 'r', 'g', 'm', 'c', 'k'};
linestyles = {'-', '--', ':', '-.', '-', '--'};

for i = 1:length(wartosci_Nu)
    Nu_test = wartosci_Nu(i);
    param_dmc = struct('N', N_opt, 'Nu', Nu_test, 'lambda', 1, 'D', 70);

    [~, y_dmc, ~, u_dmc, czas_sym, D] = symulacja_dmc_pid(param_dmc, ...
        param_sym, param_pid, Gz);

    subplot(2,1,1);
    plot(czas_sym(D:end), y_dmc(D:end), [colors{i}, linestyles{i}], 'LineWidth', 2);

    subplot(2,1,2);
    plot(czas_sym(D:end), u_dmc(D:end), [colors{i}, linestyles{i}], 'LineWidth', 2);

    legendy{end+1} = sprintf('Nu = %d', Nu_test);
end

subplot(2,1,1);
plot(czas_sym(D:end), wart_zad, 'k--', 'LineWidth', 1.5);
legendy{end+1} = 'Wartość zadana';

subplot(2,1,1);
legend(legendy, 'Location', 'best');

subplot(2,1,2);
legend(legendy{1:end-1}, 'Location', 'best');

saveas(gcf, 'wykresy/horyzont_sterowania_porownanie.jpg');
close;

Nu_opt = 5;

% d
wartosci_lambda = [0.1, 0.5, 1, 2, 5, 10, 20];

figure;
subplot(2,1,1);
hold on;
grid on;
title(['Wpływ parametru lambda na odpowiedź (N = ', num2str(N_opt), ...
    ', Nu = ', num2str(Nu_opt), ')']);
xlabel('Czas [s]');
ylabel('Wyjście procesu');

subplot(2,1,2);
hold on;
grid on;
title('Sygnały sterujące dla różnych wartości lambda');
xlabel('Czas [s]');
ylabel('Sterowanie');

legendy = {};
colors = {'b', 'r', 'g', 'm', 'c', 'y', 'k'};
linestyles = {'-', '--', ':', '-.', '-', '--', ':'};

for i = 1:length(wartosci_lambda)
    lambda_test = wartosci_lambda(i);
    param_dmc = struct('N', N_opt, 'Nu', Nu_opt, 'lambda', lambda_test, ...
        'D', 70);

    [~, y_dmc, ~, u_dmc, czas_sym, D] = symulacja_dmc_pid(param_dmc, ...
        param_sym, param_pid, Gz);

    subplot(2,1,1);
    plot(czas_sym(D:end), y_dmc(D:end), [colors{i}, linestyles{i}], 'LineWidth', 2);

    subplot(2,1,2);
    plot(czas_sym(D:end), u_dmc(D:end), [colors{i}, linestyles{i}], 'LineWidth', 2);

    legendy{end+1} = sprintf('\\lambda = %.2f', lambda_test);
end

subplot(2,1,1);
plot(czas_sym(D:end), wart_zad, 'k--', 'LineWidth', 1.5);
legendy{end+1} = 'Wartość zadana';

subplot(2,1,1);
legend(legendy, 'Location', 'best');

subplot(2,1,2);
legend(legendy{1:end-1}, 'Location', 'best');

saveas(gcf, 'wykresy/lambda_porownanie.jpg');
close;

lambda_opt = 0.5;

param_dmc_opt = struct('N', N_opt, 'Nu', Nu_opt, 'lambda', lambda_opt, ...
    'D', 70);

disp('--- Optymalne parametry regulatora DMC ---');
disp(['N = ', num2str(N_opt)]);
disp(['Nu = ', num2str(Nu_opt)]);
disp(['lambda = ', num2str(lambda_opt)]);
end
