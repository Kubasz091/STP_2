% --- Parametry ---
clc;
Ko = 6.3;
To = 5;
T1 = 2.07;
T2 = 4.65;
Tp = 0.5;
%% zad 1
Gs = tf(Ko, conv([T1, 1], [T2, 1]), 'InputDelay', To);

disp('--- Polecenie 1 ---');
disp('Transmitancja ciągła G(s):');
Gs

Gz = c2d(Gs, Tp, 'zoh');

disp('Transmitancja dyskretna G(z):');
Gz

K_static_s = dcgain(Gs);
K_static_z = dcgain(Gz);

disp(['Współczynnik wzmocnienia statycznego G(s), K_s = G(0): ', num2str(K_static_s)]);
disp(['Współczynnik wzmocnienia statycznego G(z), K_z = G(1): ', num2str(K_static_z)]);


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
%% zad 2

num_Gz = Gz.Numerator{1};
den_Gz = Gz.Denominator{1};
io_delay = Gz.InputDelay; 

equation_str = 'y(k) = ';
first_term_in_eq = true;

order_den_y = length(den_Gz) - 1;

disp('Równanie różnicowe:');
for i = 1:order_den_y
    coeff_val = -den_Gz(i+1);
    sign_str = '';
    if coeff_val > 0
        if ~first_term_in_eq
            sign_str = ' + ';
        end
    else
        sign_str = ' - ';
        coeff_val = -coeff_val;
    end

    term_str = [num2str(coeff_val, 5), '*y(k-', num2str(i), ')'];
    equation_str = [equation_str, sign_str, term_str];
    first_term_in_eq = false;
end

order_num_u = length(num_Gz) - 1;
max_delay_index_u = io_delay + order_num_u;

for l = 0:order_num_u
    coeff_val = num_Gz(l+1);
    current_delay_index_u = io_delay + l;
    if current_delay_index_u >= 1
        sign_str = '';
        if coeff_val > 0
            if ~first_term_in_eq
                sign_str = ' + ';
            end
        else
            sign_str = ' - ';
            coeff_val = -coeff_val;
        end

        term_str = [num2str(coeff_val, 5), '*u(k-', num2str(current_delay_index_u), ')'];
        equation_str = [equation_str, sign_str, term_str];
        first_term_in_eq = false;
    end
end


disp(equation_str);

%% zad 3

[Gm_abs, ~, ~, Wcp_rad_s] = margin(Gs);

Kk = Gm_abs;
Tk = 2*pi / Wcp_rad_s;

disp('Parametry krytyczne (Ziegler-Nichols):');
disp(['Wzmocnienie krytyczne Kk = ', num2str(Kk)]);
disp(['Okres oscylacji krytycznych Tk = ', num2str(Tk), ' s']);
disp(['Pulsacja krytyczna omega_k = ', num2str(Wcp_rad_s), ' rad/s']);

detuning_factor = 0.54;
Kr = 0.6 * Kk * detuning_factor;
Ti = 0.5 * Tk / detuning_factor;
Td = 0.12 * Tk * detuning_factor;

disp('Parametry ciągłego regulatora PID (wg zmodyfikowanego Zieglera-Nicholsa):');
disp(['Współczynnik dostrojenia: ', num2str(detuning_factor)]);
disp(['Kr = ', num2str(Kr)]);
disp(['Ti = ', num2str(Ti), ' s']);
disp(['Td = ', num2str(Td), ' s']);

Kp = Kr;
Ki = Kr / Ti;
Kd = Kr * Td;

disp('Współczynniki Kp, Ki, Kd dla ciągłego regulatora PID:');
disp(['Kp = ', num2str(Kp)]);
disp(['Ki = ', num2str(Ki)]);
disp(['Kd = ', num2str(Kd)]);

r0 = Kp + Ki*Tp + Kd/Tp;
r1 = -(Kp + 2*(Kd/Tp));
r2 = Kd/Tp;

disp('Parametry r0, r1, r2 dyskretnego regulatora PID:');
disp(['Przyjęty okres próbkowania Tp = ', num2str(Tp), ' s']);
disp(['r0 = ', num2str(r0)]);
disp(['r1 = ', num2str(r1)]);
disp(['r2 = ', num2str(r2)]);

%% zad 5
pid_params = struct("r0", r0, "r1", r1, "r2", r2);
sim_params = struct('len', 250, ...
    'tp', 0.5, ...
    'setpoint', 1);
setpoint = ones(1, sim_params.len - 59);

% a)
fig = figure;
step(Gz);
saveas(fig, 'wykresy/step.jpg');
close;

% b)
N_values = [60, 50, 40, 30, 20]; 
h = [];
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
legend_entries = {};

for i = 1:length(N_values)
    N_test = N_values(i);
    dmc_params = struct('N', N_test, ...
        'Nu', N_test, ...  
        'lambda', 1, ...
        'D', 60);
    [~, y_dmc, ~, u_dmc, sim_time, D] = zad4(dmc_params, sim_params, pid_params, Gz);

    subplot(2,1,1);
    h(end+1) = plot(sim_time(D:end), y_dmc(D:end), '-');

    subplot(2,1,2);
    y = plot(sim_time(D:end), u_dmc(D:end), '-');

    legend_entries{end+1} = sprintf('N = Nu = %d', N_test);
end

subplot(2,1,1);
h(end+1) = plot(sim_time(D:end), setpoint, '-');
legend_entries{end+1} = 'setpoint';

subplot(2,1,1);
legend(h, legend_entries, 'Location', 'best');

subplot(2,1,2);
legend(legend_entries{1:end-1}, 'Location', 'best');

saveas(gcf, 'wykresy/horyzont_predykcji_porownanie.jpg');
close;

N_opt = 20;

% c)
Nu_values = [60, 40, 20, 10, 5, 1];

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

legend_entries = {};

for i = 1:length(Nu_values)
    Nu_test = Nu_values(i);
    dmc_params = struct('N', N_opt, ...
        'Nu', Nu_test, ...
        'lambda', 1, ...
        'D', 60);

    [~, y_dmc, ~, u_dmc, sim_time, D] = zad4(dmc_params, sim_params, pid_params, Gz);

    subplot(2,1,1);
    plot(sim_time(D:end), y_dmc(D:end), '-');

    subplot(2,1,2);
    plot(sim_time(D:end), u_dmc(D:end), '-');

    legend_entries{end+1} = sprintf('Nu = %d', Nu_test);
end

subplot(2,1,1);
h(end+1) = plot(sim_time(D:end), setpoint, '-');
legend_entries{end+1} = 'setpoint';

subplot(2,1,1);
legend(legend_entries, 'Location', 'best');

subplot(2,1,2);
legend(legend_entries{1:end-1}, 'Location', 'best');

saveas(gcf, 'wykresy/horyzont_sterowania_porownanie.jpg');
close;

Nu_opt = 5;

lambda_values = [0.1, 0.5, 1, 2, 5, 10];

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

legend_entries = {};

for i = 1:length(lambda_values)
    lambda_test = lambda_values(i);
    dmc_params = struct('N', N_opt, ...
        'Nu', Nu_opt, ...
        'lambda', lambda_test, ...
        'D', 60);

    [~, y_dmc, ~, u_dmc, sim_time, D] = zad4(dmc_params, sim_params, pid_params, Gz);

    subplot(2,1,1);
    plot(sim_time(D:end), y_dmc(D:end), '-');

    subplot(2,1,2);
    plot(sim_time(D:end), u_dmc(D:end), '-');

    legend_entries{end+1} = sprintf('\\lambda = %.2f', lambda_test);
end

subplot(2,1,1);
plot(sim_time(D:end), setpoint, '-');
legend_entries{end+1} = 'setpoint';

subplot(2,1,1);
legend(legend_entries, 'Location', 'best');

subplot(2,1,2);
legend(legend_entries{1:end-1}, 'Location', 'best');

saveas(gcf, 'wykresy/lambda_porownanie.jpg');
close;

lambda_opt = 0.1; 

%% zad 6
dmc_params_optimal = struct('N', N_opt, ...
                           'Nu', Nu_opt, ...
                           'lambda', lambda_opt, ...
                           'D', 60);

disp('--- Optymalne parametry regulatora DMC ---');
disp(['N = ', num2str(N_opt)]);
disp(['Nu = ', num2str(Nu_opt)]);
disp(['lambda = ', num2str(lambda_opt)]);

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

[y_pid, y_dmc, u_pid, u_dmc, sim_time, D] = zad4(dmc_params_optimal, sim_params, pid_params, Gz);

subplot(2,1,1);
plot(sim_time(D:end), y_dmc(D:end), sim_time(D:end), y_pid(D:end), sim_time(D:end), setpoint, '-');

subplot(2,1,2);
plot(sim_time(D:end), u_dmc(D:end), sim_time(D:end), u_pid(D:end), '-');

subplot(2,1,1);
legend('DMC', 'PID', 'setpoint', 'Location', 'best');

subplot(2,1,2);
legend('DMC', 'PID', 'Location', 'best');

saveas(gcf, 'wykresy/optimal_solution.jpg');
close;

%% zad 8
% a)
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

[~, y_dmc, ~, u_dmc, ~, ~] = zad4(dmc_params_optimal, sim_params, pid_params, Gz);
[y_gpc, u_gpc, sim_time, D] = zad7(dmc_params_optimal, sim_params, Gz);

subplot(2,1,1);
plot(sim_time(D:end), y_dmc(D:end), sim_time(D:end), y_gpc(D:end), sim_time(D:end), setpoint, '-');

subplot(2,1,2);
plot(sim_time(D:end), u_dmc(D:end), sim_time(D:end), u_gpc(D:end), '-');

subplot(2,1,1);
legend('DMC', 'GPC', 'setpoint', 'Location', 'best');

subplot(2,1,2);
legend('DMC', 'GPC', 'Location', 'best');

saveas(gcf, 'wykresy/DMC_vs_GPC_setpoint.jpg');
close;

% b)
disturbance = 0.3;

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

[~, y_dmc, ~, u_dmc, ~, ~] = zad4(dmc_params_optimal, sim_params, pid_params, Gz, disturbance,  true);
[y_gpc, u_gpc, sim_time, D] = zad7(dmc_params_optimal, sim_params, Gz, disturbance, true);

subplot(2,1,1);
plot(sim_time(D:end), y_dmc(D:end), sim_time(D:end), y_gpc(D:end), '-');
plot(sim_time(D:end), ones(1, sim_params.len - 59)*disturbance, '--', sim_time(D:end), setpoint, '--', 'MarkerSize', 3);

subplot(2,1,2);
plot(sim_time(D:end), u_dmc(D:end), sim_time(D:end), u_gpc(D:end), '-');

subplot(2,1,1);
legend('DMC', 'GPC', 'disturbance', 'setpoint', 'Location', 'best');

subplot(2,1,2);
legend('DMC', 'GPC', 'Location', 'best');

saveas(gcf, 'wykresy/DMC_vs_GPC_disturbance.jpg');
close;

%% zad 9 - Krzywa graniczna stabilności GPC, DMC, PID (Ko vs To)
[Gm_abs, ~, ~, Wcp_rad_s] = margin(Gs);

T0_nom = [1, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2];
Ko_crit_gpc = zeros(size(T0_nom));
Ko_crit_dmc = zeros(size(T0_nom));
Ko_crit_pid = zeros(size(T0_nom));

T1 = 2.07;
T2 = 4.65;
Tp = 0.5;
sim_params = struct('len', 250, 'tp', Tp, 'setpoint', 1);
dmc_params = struct('N', 20, 'Nu', 5, 'lambda', 0.1, 'D', 60);


for i = 1:length(T0_nom)
    To_test = T0_nom(i) * To;
    Ko_test = 0.1;
    Ko_max = 50;
    found_gpc = false;
    found_dmc = false;
    found_pid = false;
    while Ko_test < Ko_max && (~found_gpc || ~found_dmc || ~found_pid)
        Gs = tf(Ko_test, conv([T1, 1], [T2, 1]), 'InputDelay', To_test);
        Gz = c2d(Gs, Tp, 'zoh');
        [y_pid, y_dmc, ~, ~, ~, ~] = zad4(dmc_params_optimal, sim_params, pid_params, Gz);
        [y_gpc, ~, ~, ~] = zad7(dmc_params_optimal, sim_params, Gz);

        if isOsc(y_gpc, 8, 0.01, 2) && ~found_gpc
            Ko_crit_gpc(i) = Ko_test;
            found_gpc = true;
        end
        if any(y_pid > 2) && ~found_pid
            Ko_crit_pid(i) = Ko_test;
            found_pid = true;
        end
        if isOsc(y_dmc, 8, 0.01, 1) && ~found_dmc
            Ko_crit_dmc(i) = Ko_test;
            found_dmc = true;
        end
        Ko_test = Ko_test + 0.1;
    end
    if ~found_gpc, Ko_crit_gpc(i) = 0; end
    if ~found_dmc, Ko_crit_dmc(i) = 0; end
    if ~found_pid, Ko_crit_pid(i) = 0; end
    fprintf('To=%.2f, Ko_crit: GPC=%.2f, DMC=%.2f, PID=%.2f\n', To_test, Ko_crit_gpc(i), Ko_crit_dmc(i), Ko_crit_pid(i));
end

figure;
plot(T0_nom, Ko_crit_gpc/Ko, 'r-o', 'LineWidth', 1.5, 'MarkerFaceColor', 'r'); hold on;
plot(T0_nom, Ko_crit_dmc/Ko, 'b-s', 'LineWidth', 1.5, 'MarkerFaceColor', 'b');
plot(T0_nom, Ko_crit_pid/Ko, 'g-d', 'LineWidth', 1.5, 'MarkerFaceColor', 'g');
grid on;
title('Krzywe graniczne stabilności GPC, DMC, PID');
xlabel('Opóźnienie To / To_{nom}');
ylabel('Krytyczne wzmocnienie Ko / Ko_{nom}');
legend('GPC', 'DMC', 'PID', 'Location', 'best');
saveas(gcf, 'wykresy/GPC_DMC_PID_stabilnosc_Ko_vs_To.jpg');
close;
disp(' ');
disp('Obszar stabilności: Dla danego T_delay, system jest stabilny dla K < K_crit (poniżej krzywej).');
disp('System jest niestabilny dla K > K_crit (powyżej krzywej).');