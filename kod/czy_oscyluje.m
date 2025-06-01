function czy_osc = czy_oscyluje(y, liczba_szczytow, tolerancja, typ)
    czy_osc = false;
    % Analizujemy tylko końcowy fragment sygnału, aby uniknąć stanów przejściowych
    if length(y) > 100
        y = y(end-100:end);
    end
    [szczyty, ~] = findpeaks(y);
    switch typ
        case 1 % Dla DMC: sprawdzanie trendu wzrostowego ostatnich szczytów
            if length(szczyty) > liczba_szczytow
                % Analizujemy trend ostatnich 'liczba_ostatnich_szczytow' szczytów
                trend = diff(szczyty(end-liczba_szczytow:end));
                % Jeśli wszystkie przyrosty są większe od tolerancji, uznajemy za oscylacje narastające
                if all(trend > tolerancja)
                    czy_osc = true;
                end
            end
        case 2 % Dla GPC: prostsze sprawdzenie, czy ostatnie szczyty są wyższe
            if length(szczyty) > 5 % Potrzebujemy wystarczającej liczby szczytów do analizy
                % Sprawdzamy, czy ostatni zanotowany szczyt jest znacząco wyższy niż maksimum z kilku wcześniejszych
                % To uproszczone kryterium, może wymagać dostosowania
                czy_osc = (max(szczyty(1:4)) - szczyty(end) < 0);
            end
    end
end
