function [param_pid, param_pid_ciagly] = zadanie3_strojenie_pid_ziegler_nichols(Gs, Tp)
%% zadanie 3
[Gm_abs, ~, ~, Wcp_rad_s] = margin(Gs);

Kk = Gm_abs;
Tk = 2*pi / Wcp_rad_s;

disp('Parametry krytyczne (Ziegler-Nichols):');
disp(['Wzmocnienie krytyczne Kk = ', num2str(Kk)]);
disp(['Okres oscylacji krytycznych Tk = ', num2str(Tk), ' s']);
disp(['Pulsacja krytyczna omega_k = ', num2str(Wcp_rad_s), ' rad/s']);

detuning_factor = 0.7;
Kr = 0.6 * Kk * detuning_factor;
Ti = 0.5 * Tk / detuning_factor;
Td = 0.12 * Tk * detuning_factor;

disp('Parametry ciągłego regulatora PID (wg Zieglera-Nicholsa):');
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

param_pid_ciagly = struct('Kp', Kp, 'Ki', Ki, 'Kd', Kd, 'Kr', Kr, 'Ti', Ti, 'Td', Td);
param_pid = struct('r0', r0, 'r1', r1, 'r2', r2);

disp('Parametry r0, r1, r2 dyskretnego regulatora PID:');
disp(['Przyjęty okres próbkowania Tp = ', num2str(Tp), ' s']);
disp(['r0 = ', num2str(r0)]);
disp(['r1 = ', num2str(r1)]);
disp(['r2 = ', num2str(r2)]);
end
