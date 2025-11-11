function feats = features_extract(segment, fs)

f_mean = mean(segment);
f_std = std(segment);
f_max = max(segment);
f_min = min(segment);
f_rms = rms(segment);
f_skew = skewness(segment);
f_kurt = kurtosis(segment);
f_zc = sum(diff(segment > 0) ~= 0);

d1 = diff(segment);
d2 = diff(d1);
activity = var(segment);
mobility = sqrt(var(d1) / activity);
complexity = sqrt(var(d2) / var(d1)) / mobility;

N = length(segment);
xdft = fft(segment);
xdft = xdft(1: floor(N / 2));
psd = (1 / (fs * N)) * abs(xdft).^2;
psd(2: end - 1) = 2 * psd(2 : end - 1);
freq = linspace(0, fs / 2, length(psd));
delta_pwr = bandpower(psd, freq, [0.5 4], 'psd');
theta_pwr = bandpower(psd, freq, [4 8], 'psd');
alpha_pwr = bandpower(psd, freq, [8 13], 'psd');
beta_pwr = bandpower(psd, freq, [13 30], 'psd');
gamma_pwr = bandpower(psd, freq, [30, 80], 'psd');
total_pwr = bandpower(psd, freq, [0.5 80], 'psd');

psd_norm = psd / sum(psd);
spectral_entropy = -sum(psd_norm .* log2(psd_norm + eps));

feats = [f_mean, f_std, f_max, f_min, f_rms, f_skew, f_kurt, f_zc, ...
    activity, mobility, complexity, ...
    delta_pwr, theta_pwr, alpha_pwr, beta_pwr, gamma_pwr, total_pwr, ...
    spectral_entropy];

end