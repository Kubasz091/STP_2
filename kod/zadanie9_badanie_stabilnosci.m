function zadanie9_badanie_stabilnosci(param_pid, param_dmc, param_gpc, Ko, To, T1, T2, ...
    Tp, param_sym)
    mnozniki_To = [1, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2];
    Ko_kryt_gpc = zeros(size(mnozniki_To));
    Ko_kryt_dmc = zeros(size(mnozniki_To));
    Ko_kryt_pid = zeros(size(mnozniki_To));

    for i = 1:length(mnozniki_To)
        To_test = mnozniki_To(i) * To;
        Ko_test = 0.1;
        Ko_max = 100;
        znaleziono_gpc = false;
        znaleziono_dmc = false;
        znaleziono_pid = false;
        while Ko_test < Ko_max && (~znaleziono_gpc || ~znaleziono_dmc || ...
                ~znaleziono_pid)
            Gs_test = tf(Ko_test, conv([T1, 1], [T2, 1]), 'InputDelay', To_test);
            Gz_test = c2d(Gs_test, Tp, 'zoh');
            [y_pid, y_dmc, ~, ~, ~, ~] = symulacja_dmc_pid(param_dmc, ...
                param_sym, param_pid, Gz_test);
            [y_gpc, ~, ~, ~] = symulacja_gpc(param_gpc, param_sym, Gz_test);

            if czy_oscyluje(y_gpc, 8, 0.01, 2) && ~znaleziono_gpc
                Ko_kryt_gpc(i) = Ko_test;
                znaleziono_gpc = true;
            end
            if any(y_pid > 7) && ~znaleziono_pid
                Ko_kryt_pid(i) = Ko_test;
                znaleziono_pid = true;
            end
            if czy_oscyluje(y_dmc, 8, 0.01, 1) && ~znaleziono_dmc
                Ko_kryt_dmc(i) = Ko_test;
                znaleziono_dmc = true;
            end
            Ko_test = Ko_test + 0.1;
        end
        if ~znaleziono_gpc, Ko_kryt_gpc(i) = 0; end
        if ~znaleziono_dmc, Ko_kryt_dmc(i) = 0; end
        if ~znaleziono_pid, Ko_kryt_pid(i) = 0; end
        fprintf('To=%.2f, Ko_kryt: GPC=%.2f, DMC=%.2f, PID=%.2f\n', ...
            To_test, Ko_kryt_gpc(i), Ko_kryt_dmc(i), Ko_kryt_pid(i));
    end

figure;
plot(mnozniki_To, Ko_kryt_gpc/Ko, 'r-', 'LineWidth', 2); hold on;
plot(mnozniki_To, Ko_kryt_dmc/Ko, 'b-', 'LineWidth', 2);
plot(mnozniki_To, Ko_kryt_pid/Ko, 'g-', 'LineWidth', 2);
grid on;
title('Krzywe graniczne stabilności GPC, DMC, PID');
xlabel('Opóźnienie To / To_{nom}');
ylabel('Krytyczne wzmocnienie Ko / Ko_{nom}');
legend('GPC', 'DMC', 'PID', 'Location', 'best');
saveas(gcf, 'wykresy/GPC_DMC_PID_stabilnosc_Ko_vs_To.jpg');
close;
disp(' ');
disp('Obszar stabilności: Dla danego To/To_nom, system jest stabilny dla Ko/Ko_nom < Ko_kryt/Ko_nom (poniżej krzywej).');
disp('System jest niestabilny dla Ko > Ko_kryt (powyżej krzywej).');
end
