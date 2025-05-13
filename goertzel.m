function energy = goertzel(x, target_freq, Fs)
    N = length(x);
    k = round(0.5 + N * target_freq / Fs);
    w = 2 * pi * k / N;
    
    Q1 = 0;
    Q2 = 0;
    
    for n = 1:N
        Q0 = x(n) + 2 * cos(w) * Q1 - Q2;
        Q2 = Q1;
        Q1 = Q0;
    end
    
    energy = Q1^2 + Q2^2 - Q1 * Q2 * cos(w * 2);
end
