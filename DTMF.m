% 讀取.wav檔
filename = 'ADSP_DTMF Test Signal1 (Noisy).wav';
[x, Fs] = audioread(filename);

% 建立低通濾波器
cutoff_frequency = 1000; % 截止頻率
filter_order = 5; % 濾波器階數

lowpass_filter = designfilt('lowpassfir', ...
    'FilterOrder', filter_order, ...
    'CutoffFrequency', cutoff_frequency, ...
    'SampleRate', Fs);

% 使用低通濾波器對輸入訊號進行濾波
x_filtered = filter(lowpass_filter, x);

% DTMF頻率映射
low_group = [697, 770, 852, 941];
high_group = [1209, 1336, 1477, 1633];
dtmf_characters = ['1', '2', '3', 'A'; '4', '5', '6', 'B'; '7', '8', '9', 'C'; '*', '0', '#', 'D'];

% 初始化變量
detected_characters = '';

% 設置DTMF頻率檢測參數
tolerance = 20; % 允許的頻率誤差

% 分析.wav檔中的訊號
window_size = round(Fs * 0.1); % 窗口大小為0.1秒
overlap = round(Fs * 0.2); % 重疊為0.2秒

% 設置Goertzel算法參數
N = length(x);
K = length(low_group);

for i = 1:overlap:N - window_size
    % 從濾波後的訊號中提取當前窗口
    x_window = x_filtered(i:i + window_size - 1);

    % 使用Goertzel算法計算每個低音頻率和高音頻率的能量
    low_energy = zeros(1, K);
    high_energy = zeros(1, K);
    
    for j = 1:K
        low_energy(j) = goertzel(x_window, low_group(j), Fs);
        high_energy(j) = goertzel(x_window, high_group(j), Fs);
    end

    % 確定匹配的低音和高音頻率
    [~, low_idx] = max(low_energy);
    [~, high_idx] = max(high_energy);
    
    % 從字符映射表中獲取字符
    detected_characters = [detected_characters dtmf_characters(low_idx, high_idx)];
end

% 輸出檢測到的字符
disp(['Detected characters: ' detected_characters]);

% 繪製原始音頻波形
t = (0:(length(x) - 1)) / Fs;
figure;
subplot(2,1,1);
plot(t, x);
title('原始音頻波形');
xlabel('時間 (秒)');
ylabel('振幅');

% 繪製濾波後的音頻波形
subplot(2,1,2);
plot(t, x_filtered);
title('濾波後的音頻波形');
xlabel('時間 (秒)');
ylabel('振幅');