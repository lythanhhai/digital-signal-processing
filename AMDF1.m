 %close all;clear;clc
 function [Fo] =  AMDF1(filename, tenFile, frame_voice, frame_unvoice);
 % input audio
 [x,fs]=audioread(filename);
 figure('name', tenFile);
 
 % vẽ signal by time
 time = (1/fs)*length(x);
 t = linspace(0, time, length(x));
 subplot(4,1,1);
 plot(t,x);
 title('signal by second');
 xlabel('time(sec)');
 ylabel('amplitude');
 grid on
 
 % phân khung cho tín hiệu
 frame_len = 0.03 * fs;% chiều dài khung, 1 khung 30ms
 R = length(x);
 numberFrames = floor(R / frame_len);% số khung được chia
 P=zeros(numberFrames, frame_len);
 for i = 1:numberFrames
     startIndex = (i - 1) * frame_len + 1;
     for j = 1:frame_len
         P(i, j) = x(startIndex + j - 1);
     end
 end

% tính AMDF cho từng khung
sum1 = 0;
d = zeros(numberFrames, frame_len);
for l=1:numberFrames
    sum1=0;
    for k=1:frame_len
        for m = 1:(frame_len - 1 - k)
            sum1 = sum1 + abs(P(l, m) - P(l, m + k));
        end
        d(l, k) = sum1;
        sum1=0;
    end
end

% chuẩn hóa
normalizedAMDF = d - min(d(:));
normalizedAMDF = normalizedAMDF ./ max(normalizedAMDF(:));

subplot(4,1,2);
time1 = (1/fs)*length(normalizedAMDF);
t1 = linspace(0, time1, length(normalizedAMDF));
plot(t1, normalizedAMDF(frame_voice, :));
title('voice');
subplot(4,1,3);
plot(t1, normalizedAMDF(frame_unvoice, :));
title('unvoice');

% tìm cực tiểu của khung tín hiệu
T0_min=fs/450;
T0_max=fs/70;
minimum = zeros(numberFrames, frame_len);
maxSignal = zeros(numberFrames, 1);
for nf=1:numberFrames
    for r=2:frame_len
           if (normalizedAMDF(nf, r) < normalizedAMDF(nf, r-1)) && (normalizedAMDF(nf, r) < normalizedAMDF(nf, r+1)) && r > T0_min && r < T0_max
               minimum(nf, r) = normalizedAMDF(nf, r);
           end   
    end
    maxSignal(nf) = max(normalizedAMDF(nf, :));
end
%&& r > T0_min && r < T0_max
%maxSignal
% tìm min nhỏ nhất của từng khung và vị trí của nó
minimum1=zeros(numberFrames, 1);
vitri=zeros(numberFrames, 1);
min1 = 10000;
vitriMin=10000;
for e=1:numberFrames
    min1 = 10000;
    vitriMin=10000;
    for r=1:frame_len
        if minimum(e, r) ~= 0 && min1 > minimum(e, r)
            min1 = minimum(e, r);
            vitriMin = r;
        end
    end
    minimum1(e) = min1;
    vitri(e) = vitriMin;
end
%vitri
%minimum1
% so sánh với ngưỡng để phân biệt vô thanh, hưu thanh, khoảng lặng
Fo=zeros(numberFrames, 1);
for i=1:numberFrames
    max1 = max(normalizedAMDF(i, :));
    minimum1(i)/max1;
   % 0.3
    if minimum1(i) < (max1 * 0.3)
       Fo(i) = 1/(vitri(i) / fs);
    end
end

% tính trung bình cộng Fo (Fo_mean)
fomean = 0;
j =0;
for i=1:numberFrames
    if Fo(i) ~= 0
       fomean = fomean + Fo(i);
       j = j + 1;
    end
end

% tính độ lệch chuẩn (Fo_std)
phuongsai = 0;
for i=1:numberFrames
    if Fo(i) ~= 0
        phuongsai = phuongsai + power(Fo(i) - fomean/j, 2);
    end
end

fo_mean = fomean/j; % trung bình cộng
fo_std = sqrt(phuongsai / (j-1)); % độ lệch chuẩn

% vẽ Fo 
k=1;
subplot(4,1,4);
for i=1:numberFrames
    k=k+1;
    if Fo(i) > 0
        hold on
        plot(k-1, Fo(i), '.' ,'color', 'b');
    end
end
xlim([0 length(Fo)]);
title(['Fomean = ', num2str(fo_mean), 'Hz ', ' Fostd = ', num2str(fo_std), 'Hz']);
xlabel('khung');
ylabel('Fo(hz)');


end
