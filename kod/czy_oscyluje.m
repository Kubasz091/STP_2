function czy_osc = czy_oscyluje(y, liczba_szczytow, tolerancja, typ)
    czy_osc = false;
    if length(y) > 100
        y = y(end-100:end);
    end
    [szczyty, ~] = findpeaks(y);
    switch typ
        case 1
            if length(szczyty) > liczba_szczytow
                trend = diff(szczyty(end-liczba_szczytow:end));
                if all(trend > tolerancja)
                    czy_osc = true;
                end
            end
        case 2
            if length(szczyty) > 5
                czy_osc = (max(szczyty(1:4)) - szczyty(end) < 0);
            end
    end
end
