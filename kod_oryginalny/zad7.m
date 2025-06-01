function [y_gpc, u_gpc, sim_time, D] = zad7(gpc_params,sim_params, Gz, disturbance, stationary)
%% zad 7

if nargin < 4
    disturbance = 0;
end

if nargin < 5
    stationary = false;
end

sim_length = sim_params.len;
sim_time = (0:sim_params.len-1)*sim_params.tp;
setpoint = sim_params.setpoint;
num_Gz = Gz.Numerator{1};
den_Gz = Gz.Denominator{1};
io_delay = Gz.InputDelay;

N = gpc_params.N;
Nu = gpc_params.Nu;
lambda = gpc_params.lambda;
D = gpc_params.D;

yzad = setpoint * ones(N, 1);


y_gpc = zeros(1, sim_length);
u_gpc = zeros(1, sim_length);

if stationary
    y_gpc(1:D) = setpoint;
end

s = zeros(D, 1);
for j = 1:D
    if j <= io_delay
        s(j) = 0;
    else
        for i = 1:min(length(num_Gz), j-io_delay)
            s(j) = s(j) + num_Gz(i);
        end
        for i = 1:min(length(den_Gz) - 1, j-1)
            s(j) = s(j) - den_Gz(i+1) * s(j-i);
        end
    end
end

M = zeros(gpc_params.N, Nu);
for i = 1:N
    for j = 1:min(i, Nu)
        M(i, j) = s(i-j+1);
    end
end


K = inv(M'*eye(N)*M + lambda*eye(Nu)) * M'*eye(N);

for k = max(3, D+1):sim_length
    for i = 1:length(den_Gz)-1
        y_gpc(k) = y_gpc(k) - den_Gz(i+1) * y_gpc(k-i);
    end
    
    for i = 1:length(num_Gz)
        idx = k - io_delay - i + 1;
        y_gpc(k) = y_gpc(k) + num_Gz(i) * u_gpc(idx);
    end
    
    y_gpc(k) = y_gpc(k) + disturbance;

    y_hat = 0;
    for j = 1:length(num_Gz)
        idx = k - io_delay - j + 1;
        if idx >= 1
            y_hat = y_hat + num_Gz(j) * u_gpc(idx);
        end
    end
    for j = 1:length(den_Gz)-1
        y_hat = y_hat - den_Gz(j+1) * y_gpc(k-j);
    end
    
    d_k = y_gpc(k) - y_hat;

    y0 = zeros(N, 1);
    for p = 1:N
        y0(p) = 0;
        for i = 1:length(num_Gz)
            if p+i <= D - 1
                idx = k - io_delay - i + p;
                if idx >= k
                    idx = k-1;
                end
                y0(p) = y0(p) + num_Gz(i) * u_gpc(idx);
            end
        end
        for i = 1:length(den_Gz)-1
            if p+i <= D - 1
                idx = k - i + p;
                if p > i
                    y0(p) = y0(p) - den_Gz(i+1) * y0(p-i);
                else
                    y0(p) = y0(p) - den_Gz(i+1) * y_gpc(idx);
                end
            end
        end
        y0(p) = y0(p) + d_k;
    end

    dU = K * (yzad - y0);
    du_gpc(k) = dU(1);

    u_gpc(k) = u_gpc(k-1) + du_gpc(k);
end
end

