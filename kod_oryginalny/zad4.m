function [y_pid, y_dmc, u_pid, u_dmc, sim_time, D] = zad4(dmc_params,sim_params, pid_params,  Gz, disturbance, stationary)
%% zad 4

if nargin < 5
    disturbance = 0;
end

if nargin < 6
    stationary = false;
end

sim_length = sim_params.len;
sim_time = (0:sim_params.len-1)*sim_params.tp;
setpoint = sim_params.setpoint;
num_Gz = Gz.Numerator{1};
den_Gz = Gz.Denominator{1};
io_delay = Gz.InputDelay;

r0 = pid_params.r0;
r1 = pid_params.r1;
r2 = pid_params.r2;

y_pid = zeros(1, sim_length);
u_pid = zeros(1, sim_length);
e_pid = zeros(1, sim_length);

N = dmc_params.N;
Nu = dmc_params.Nu;
lambda = dmc_params.lambda;
D = dmc_params.D;

yzad = setpoint * ones(N, 1);

y_dmc = zeros(1, sim_length);
u_dmc = zeros(1, sim_length);
du_dmc = zeros(1, sim_length);

if stationary
    y_dmc(1:D) = setpoint;
end

s = step(Gz, (0:D-1)*sim_params.tp);
s = s(1:D);

M = zeros(dmc_params.N, Nu);
for i = 1:N
    for j = 1:min(i, Nu)
        M(i, j) = s(i-j+1);
    end
end

s = s(2:D);

K = inv(M'*eye(N)*M + lambda*eye(Nu)) * M'*eye(N);

for k = max(3, D+1):sim_length
    for i = 1:length(den_Gz)-1
        y_pid(k) = y_pid(k) - den_Gz(i+1) * y_pid(k-i);
        y_dmc(k) = y_dmc(k) - den_Gz(i+1) * y_dmc(k-i);
    end
    
    for i = 1:length(num_Gz)
        idx = k - io_delay - i + 1;
        y_pid(k) = y_pid(k) + num_Gz(i) * u_pid(idx);
        y_dmc(k) = y_dmc(k) + num_Gz(i) * u_dmc(idx);
    end

    y_dmc(k) = y_dmc(k) + disturbance;

    e_pid(k) = setpoint - y_pid(k);
    u_pid(k) = u_pid(k-1) + r0*e_pid(k) + r1*e_pid(k-1) + r2*e_pid(k-2);

    dUp = zeros(D-1, 1);
    for i = 1:min(D-1, k-1)
        dUp(i) = u_dmc(k-i) - u_dmc(k-i-1);
    end

    y0 = zeros(N, 1);
    for p = 1:N
        y0(p) = y_dmc(k);
        for i = 1:min(D-1, k-1)
            if p+i <= D-1
                y0(p) = y0(p) + (s(p+i) - s(i)) * dUp(i);
            end
        end
    end
    dU = K * (yzad - y0);
    du_dmc(k) = dU(1);

    u_dmc(k) = u_dmc(k-1) + du_dmc(k);
end
end

