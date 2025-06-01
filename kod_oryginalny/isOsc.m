function isOsc = isOsc(y, num_last_peaks, tolerance, type)
    isOsc = false;
    y = y(end-100:end);
    [pks, ~] = findpeaks(y);
    switch type
        case 1
            if length(pks) > num_last_peaks
                trend = diff(pks(end-num_last_peaks:end));
                if all(trend > tolerance)
                    isOsc = true;
                end
            end
        case 2
            if length(pks) > 5
                isOsc = (max(pks(1:4)) - pks(end) < 0);
            end
    end
end
