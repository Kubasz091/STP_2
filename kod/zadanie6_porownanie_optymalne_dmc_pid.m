function zadanie6_porownanie_optymalne_dmc_pid(Gz, param_pid, param_dmc_opt, ...
    param_sym, wart_zad)
    figure('Position', [100, 100, 800, 600]);

    subplot(2,1,1);
    hold on;
    grid on;
    title('Porównanie odpowiedzi układu dla regulatorów DMC i PID');
    xlabel('Czas [s]');
    ylabel('Amplituda wyjścia');

    subplot(2,1,2);
    hold on;
    grid on;
    title('Przebiegi sterowania');
    xlabel('Czas [s]');
    ylabel('Sygnał sterujący');

    [y_pid, y_dmc, u_pid, u_dmc, czas_sym, D] = symulacja_dmc_pid(...
        param_dmc_opt, param_sym, param_pid, Gz);

    subplot(2,1,1);
    plot(czas_sym(D:end), y_dmc(D:end), 'b-', 'LineWidth', 2);
    plot(czas_sym(D:end), y_pid(D:end), 'r-', 'LineWidth', 2);
    plot(czas_sym(D:end), wart_zad, 'k--', 'LineWidth', 1.5);

    subplot(2,1,2);
    plot(czas_sym(D:end), u_dmc(D:end), 'b-', 'LineWidth', 2);
    plot(czas_sym(D:end), u_pid(D:end), 'r-', 'LineWidth', 2);

    subplot(2,1,1);
    legend('DMC', 'PID', 'Wartość zadana', 'Location', 'best');

    subplot(2,1,2);
    legend('DMC', 'PID', 'Location', 'best');

    saveas(gcf, 'wykresy/optimal_solution.jpg');
    close;
end
