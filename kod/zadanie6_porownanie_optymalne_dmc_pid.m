function zadanie6_porownanie_optymalne_dmc_pid(Gz, param_pid, param_dmc_opt, param_sym, wart_zad)
%% zadanie 6
figure;
subplot(2,1,1);
hold on;
grid on;
title('Porównanie odpowiedzi układu dla regulatorów DMC i PID');
xlabel('Czas [s]');
ylabel('Wyjście');

subplot(2,1,2);
hold on;
grid on;
title('Porównanie sygnałów sterujących regulatorów DMC i PID');
xlabel('Czas [s]');
ylabel('Sterowanie');

[y_pid, y_dmc, u_pid, u_dmc, czas_sym, D] = symulacja_dmc_pid(param_dmc_opt, param_sym, param_pid, Gz);

subplot(2,1,1);
plot(czas_sym(D:end), y_dmc(D:end), czas_sym(D:end), y_pid(D:end), czas_sym(D:end), wart_zad, '-');

subplot(2,1,2);
plot(czas_sym(D:end), u_dmc(D:end), czas_sym(D:end), u_pid(D:end), '-');

subplot(2,1,1);
legend('DMC', 'PID', 'wartość zadana', 'Location', 'best');

subplot(2,1,2);
legend('DMC', 'PID', 'Location', 'best');

saveas(gcf, 'wykresy/optimal_solution.jpg');
close;
end
