function [y_pid, y_dmc, u_pid, u_dmc, czas_sym, D] = symulacja_dmc_pid(...
    param_dmc, param_sym, param_pid, Gz, zaklocenie, stan_ustalony)
    if nargin < 5
        zaklocenie = 0;
    end

    if nargin < 6
        stan_ustalony = false;
    end

    dlugosc = param_sym.len;
    czas_sym = (0:param_sym.len-1)*param_sym.tp;
    wart_zad = param_sym.setpoint;
    licz_Gz = Gz.Numerator{1};
    mian_Gz = Gz.Denominator{1};
    opoz = Gz.InputDelay;

    r0 = param_pid.r0;
    r1 = param_pid.r1;
    r2 = param_pid.r2;

    y_pid = zeros(1, dlugosc);
    u_pid = zeros(1, dlugosc);
    e_pid = zeros(1, dlugosc);

    N = param_dmc.N;
    Nu = param_dmc.Nu;
    lambda = param_dmc.lambda;
    D = param_dmc.D;

    yzad = wart_zad * ones(N, 1);

    y_dmc = zeros(1, dlugosc);
    u_dmc = zeros(1, dlugosc);
    du_dmc = zeros(1, dlugosc);

    if stan_ustalony
        y_dmc(1:D) = wart_zad;
    end

    s = step(Gz, (0:D-1)*param_sym.tp);
    s = s(1:D);

    M = zeros(param_dmc.N, Nu);
    for i = 1:N
        for j = 1:min(i, Nu)
            M(i, j) = s(i-j+1);
        end
    end

    s = s(2:D);

    K = inv(M'*eye(N)*M + lambda*eye(Nu)) * M'*eye(N);

    for k = max(3, D+1):dlugosc
        for i = 1:length(mian_Gz)-1
            y_pid(k) = y_pid(k) - mian_Gz(i+1) * y_pid(k-i);
            y_dmc(k) = y_dmc(k) - mian_Gz(i+1) * y_dmc(k-i);
        end

        for i = 1:length(licz_Gz)
            idx = k - opoz - i + 1;
            y_pid(k) = y_pid(k) + licz_Gz(i) * u_pid(idx);
            y_dmc(k) = y_dmc(k) + licz_Gz(i) * u_dmc(idx);
        end

        y_dmc(k) = y_dmc(k) + zaklocenie;

        e_pid(k) = wart_zad - y_pid(k);
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
