function [y_gpc, u_gpc, czas_sym, D] = symulacja_gpc(param_gpc, param_sym, ...
    Gz, zaklocenie, stan_ustalony)
    if nargin < 4
        zaklocenie = 0;
    end

    if nargin < 5
        stan_ustalony = false;
    end

    dlugosc = param_sym.len;
    czas_sym = (0:param_sym.len-1)*param_sym.tp;
    wart_zad = param_sym.setpoint;
    licz_Gz = Gz.Numerator{1};
    mian_Gz = Gz.Denominator{1};
    opoz = Gz.InputDelay;

    N = param_gpc.N;
    Nu = param_gpc.Nu;
    lambda = param_gpc.lambda;
    D = param_gpc.D;

    yzad = wart_zad * ones(N, 1);

    y_gpc = zeros(1, dlugosc);
    u_gpc = zeros(1, dlugosc);

    if stan_ustalony
        y_gpc(1:D) = wart_zad;
    end

    s = zeros(D, 1);
    for j = 1:D
        if j <= opoz
            s(j) = 0;
        else
            for i = 1:min(length(licz_Gz), j-opoz)
                s(j) = s(j) + licz_Gz(i);
            end
            for i = 1:min(length(mian_Gz) - 1, j-1)
                s(j) = s(j) - mian_Gz(i+1) * s(j-i);
            end
        end
    end

    M = zeros(param_gpc.N, Nu);
    for i = 1:N
        for j = 1:min(i, Nu)
            M(i, j) = s(i-j+1);
        end
    end

    K = inv(M'*eye(N)*M + lambda*eye(Nu)) * M'*eye(N);

    for k = max(3, D+1):dlugosc
        for i = 1:length(mian_Gz)-1
            y_gpc(k) = y_gpc(k) - mian_Gz(i+1) * y_gpc(k-i);
        end

        for i = 1:length(licz_Gz)
            idx = k - opoz - i + 1;
            y_gpc(k) = y_gpc(k) + licz_Gz(i) * u_gpc(idx);
        end

        y_gpc(k) = y_gpc(k) + zaklocenie;

        y_hat = 0;
        for j = 1:length(licz_Gz)
            idx = k - opoz - j + 1;
            if idx >= 1
                y_hat = y_hat + licz_Gz(j) * u_gpc(idx);
            end
        end
        for j = 1:length(mian_Gz)-1
            y_hat = y_hat - mian_Gz(j+1) * y_gpc(k-j);
        end

        d_k = y_gpc(k) - y_hat;

        y0 = zeros(N, 1);
        for p = 1:N
            y0(p) = 0;
            for i = 1:length(licz_Gz)
                if p+i <= D - 1
                    idx = k - opoz - i + p;
                    if idx >= k
                        idx = k-1;
                    end
                    y0(p) = y0(p) + licz_Gz(i) * u_gpc(idx);
                end
            end
            for i = 1:length(mian_Gz)-1
                if p+i <= D - 1
                    idx = k - i + p;
                    if p > i
                        y0(p) = y0(p) - mian_Gz(i+1) * y0(p-i);
                    else
                        y0(p) = y0(p) - mian_Gz(i+1) * y_gpc(idx);
                    end
                end
            end
            y0(p) = y0(p) + d_k;
        end

        dU = K * (yzad - y0);
        du_gpc = dU(1);

        u_gpc(k) = u_gpc(k-1) + du_gpc;
    end
end
