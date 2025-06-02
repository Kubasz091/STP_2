function zadanie2_rownanie_roznicowe(Gz)
    licz_Gz = Gz.Numerator{1};
    mian_Gz = Gz.Denominator{1};
    opoz = Gz.InputDelay;

    rownanie = 'y(k) = ';
    pierwszy_term = true;

    stopien_mian = length(mian_Gz) - 1;

    disp('Równanie różnicowe:');
    for i = 1:stopien_mian
        wsp = -mian_Gz(i+1);
        znak = '';
        if wsp > 0
            if ~pierwszy_term
                znak = ' + ';
            end
        else
            znak = ' - ';
            wsp = -wsp;
        end

        term = [num2str(wsp, 5), '*y(k-', num2str(i), ')'];
        rownanie = [rownanie, znak, term];
        pierwszy_term = false;
    end

    stopien_licz = length(licz_Gz) - 1;
    max_opoz = opoz + stopien_licz;

    for l = 0:stopien_licz
        wsp = licz_Gz(l+1);
        biezace_opoz = opoz + l;
        if biezace_opoz >= 1
            znak = '';
            if wsp > 0
                if ~pierwszy_term
                    znak = ' + ';
                end
            else
                znak = ' - ';
                wsp = -wsp;
            end

            term = [num2str(wsp, 5), '*u(k-', num2str(biezace_opoz), ')'];
            rownanie = [rownanie, znak, term];
            pierwszy_term = false;
        end
    end

    disp(rownanie);
end
