function [Gs, Gz] = zadanie1_analiza_transmitancji(Ko, To, T1, T2, Tp)
%% zadanie 1
Gs = tf(Ko, conv([T1, 1], [T2, 1]), 'InputDelay', To);

disp('--- Zadanie 1 ---');
disp('Transmitancja ciągła G(s):');
Gs

Gz = c2d(Gs, Tp, 'zoh');

disp('Transmitancja dyskretna G(z):');
Gz

K_statyczne_s = dcgain(Gs);
K_statyczne_z = dcgain(Gz);

disp(['Współczynnik wzmocnienia statycznego G(s), K_s = G(0): ', num2str(K_statyczne_s)]);
disp(['Współczynnik wzmocnienia statycznego G(z), K_z = G(1): ', num2str(K_statyczne_z)]);

fig = figure;
step(Gs, '-b');
hold on;
step(Gz, '-r');
title('Porównanie odpowiedzi skokowych G(s) i G(z)');
legend('G(s) - ciągła', 'G(z) - dyskretna', 'Location','best');
grid on;
hold off;
saveas(fig, "wykresy/zad1.jpg");
close;
end
