function [param_dmc_opt] = zadanie5_optymalizacja_dmc(Gz, param_pid, param_sym, wart_zad)
%% zadanie 5

% a) Odpowiedź skokowa
fig = figure;
step(Gz);
title('Odpowiedź skokowa obiektu G(z)');
saveas(fig, 'wykresy/step.jpg');
close;

% b) Wpływ horyzontu predykcji N
wartosci_N = [70, 50, 40, 30, 20];
uchwyty_wykr = [];
figure;
subplot(2,1,1);
hold on;
grid on;
title('Wpływ horyzontu predykcji N na jakość regulacji (przy Nu=N)');
xlabel('Czas [s]');
ylabel('Wyjście');

subplot(2,1,2);
hold on;
grid on;
title('Sygnały sterujące dla różnych horyzontów predykcji N');
xlabel('Czas [s]');
ylabel('Sterowanie');
legendy = {};

for i = 1:length(wartosci_N)
    N_test = wartosci_N(i);
    param_dmc = struct('N', N_test, 'Nu', N_test, 'lambda', 1, 'D', 70);
    [~, y_dmc, ~, u_dmc, czas_sym, D] = symulacja_dmc_pid(param_dmc, param_sym, param_pid, Gz);

    subplot(2,1,1);
    uchwyty_wykr(end+1) = plot(czas_sym(D:end), y_dmc(D:end), '-');

    subplot(2,1,2);
    plot(czas_sym(D:end), u_dmc(D:end), '-');

    legendy{end+1} = sprintf('N = Nu = %d', N_test);
end

subplot(2,1,1);
uchwyty_wykr(end+1) = plot(czas_sym(D:end), wart_zad, '-');
legendy{end+1} = 'wartość zadana';

subplot(2,1,1);
legend(uchwyty_wykr, legendy, 'Location', 'best');

subplot(2,1,2);
legend(legendy{1:end-1}, 'Location', 'best');

saveas(gcf, 'wykresy/horyzont_predykcji_porownanie.jpg');
close;

N_opt = 20;

% c) Wpływ horyzontu sterowania Nu
wartosci_Nu = [70, 40, 20, 10, 5, 1];

figure;
subplot(2,1,1);
hold on;
grid on;
title(['Wpływ horyzontu sterowania Nu na jakość regulacji (N = ', num2str(N_opt), ')']);
xlabel('Czas [s]');
ylabel('Wyjście');

subplot(2,1,2);
hold on;
grid on;
title('Sygnały sterujące dla różnych horyzontów sterowania Nu');
xlabel('Czas [s]');
ylabel('Sterowanie');

legendy = {};

for i = 1:length(wartosci_Nu)
    Nu_test = wartosci_Nu(i);
    param_dmc = struct('N', N_opt, 'Nu', Nu_test, 'lambda', 1, 'D', 70);

    [~, y_dmc, ~, u_dmc, czas_sym, D] = symulacja_dmc_pid(param_dmc, param_sym, param_pid, Gz);

    subplot(2,1,1);
    plot(czas_sym(D:end), y_dmc(D:end), '-');

    subplot(2,1,2);
    plot(czas_sym(D:end), u_dmc(D:end), '-');

    legendy{end+1} = sprintf('Nu = %d', Nu_test);
end

subplot(2,1,1);
plot(czas_sym(D:end), wart_zad, '-');
legendy{end+1} = 'wartość zadana';

subplot(2,1,1);
legend(legendy, 'Location', 'best');

subplot(2,1,2);
legend(legendy{1:end-1}, 'Location', 'best');

saveas(gcf, 'wykresy/horyzont_sterowania_porownanie.jpg');
close;

Nu_opt = 5;

% d) Wpływ współczynnika lambda
wartosci_lambda = [0.1, 0.5, 1, 2, 5, 10];

figure;
subplot(2,1,1);
hold on;
grid on;
title(['Wpływ współczynnika lambda na odpowiedź układu (N = ', num2str(N_opt), ', Nu = ', num2str(Nu_opt), ')']);
xlabel('Czas [s]');
ylabel('Wyjście');

subplot(2,1,2);
hold on;
grid on;
title('Wpływ współczynnika lambda na sygnał sterujący');
xlabel('Czas [s]');
ylabel('Sterowanie');

legendy = {};

for i = 1:length(wartosci_lambda)
    lambda_test = wartosci_lambda(i);
    param_dmc = struct('N', N_opt, 'Nu', Nu_opt, 'lambda', lambda_test, 'D', 70);

    [~, y_dmc, ~, u_dmc, czas_sym, D] = symulacja_dmc_pid(param_dmc, param_sym, param_pid, Gz);

    subplot(2,1,1);
    plot(czas_sym(D:end), y_dmc(D:end), '-');

    subplot(2,1,2);
    plot(czas_sym(D:end), u_dmc(D:end), '-');

    legendy{end+1} = sprintf('\\lambda = %.2f', lambda_test);
end

subplot(2,1,1);
plot(czas_sym(D:end), wart_zad, '-');
legendy{end+1} = 'wartość zadana';

subplot(2,1,1);
legend(legendy, 'Location', 'best');

subplot(2,1,2);
legend(legendy{1:end-1}, 'Location', 'best');

saveas(gcf, 'wykresy/lambda_porownanie.jpg');
close;

lambda_opt = 0.1;

% Optymalne parametry DMC
param_dmc_opt = struct('N', N_opt, 'Nu', Nu_opt, 'lambda', lambda_opt, 'D', 70);

disp('--- Optymalne parametry regulatora DMC ---');
disp(['N = ', num2str(N_opt)]);
disp(['Nu = ', num2str(Nu_opt)]);
disp(['lambda = ', num2str(lambda_opt)]);
end
