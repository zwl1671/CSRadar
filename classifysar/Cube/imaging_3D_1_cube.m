clc
clear all
close all

% distance between transmitting antenna and 1st receiving antenna in cm
sx = 57.5;
sy = -23;
sz = -5.5;
% use one tx antenna and N receiving antennas
NN = 15;
MM = 15;
% distance between adjacent receiving antennas in cm
d1 = 5.5;
d2 = 4.5;
% center frequency in GHz
fc = 2.5;
% transmitting antenna position in cm
tx_X = 0; 
tx_Y = 104;
tx_z = 0;


axis_X = 0 : 2 : 180; % unit: cm
axis_Y = 0 : 2 : 180; % unit: cm
axis_z = 80:5:200;
 %% radar parameter
    %frequency starts from 2GHz
%     f0 = 2e9;
    %center frequency 3GHz, total bandwidth 2GHz
%     fc = 3e9;
    %speed of light
    c = 3e8;
    %wavelength at center frequency
%     lamda = c/fc;
    %step frequency 20MHz
    delt_f = 20e6;
    %for each channel of 1GHz bandwidth, there are 50 steps
    N = 50;
    %data sampled at 5KHz
    fs1 = 5e3;
    %sampled period 0.2ms
    ts1 = 1/fs1;
    %each frequency step duration 1ms, so there are 5 sampled points each pulse
    s_num = 5;  
    %50 steps, 5 points for each step, so there are 250 points in each frame
    s_fram = 250.015; %instrument (signal genaretor) as reference
    %total time for one frame 50ms
    ts2 = ts1*s_fram;
    %frame repeated frequency 20Hz
    fs2 = 1/ts2;
    %In experiment, data were collected for 20s, including 400 frames in total. We use 398 frames.
    fram_num = 1;
    %start read from this point(excel file), for each step the first two points generated by PLL are not good enough
    first_sp = 3; 
    %% extract range profiles
profile = zeros(1024*2,NN*MM);
filename={...
    '15','14','13','12','11','10','9','8','7','6','5','4','3','2','1'...
    ,'16','18','19','20','21','22','23','24','25','26','27','28','29','30','31'...
    ,'47','46','45','44','43','42','41','40','39','38','37','36','35','34','32'...
    ,'48','50','51','52','53','54','55','56','57','58','59','60','61','62','63'...
    ,'79','78','77','76','75','74','73','72','71','70','69','68','67','66','64'...
    ,'80','82','83','84','85','86','87','88','89','90','91','92','93','94','95'...
    ,'111','110','109','108','107','106','105','104','103','102','101','100','99','98','96'...
    ,'112','114','115','116','117','118','119','120','121','122','123','124','125','126','127'...
    ,'143','142','141','140','139','138','137','136','135','134','133','132','131','130','128'...
    ,'144','146','147','148','149','150','151','152','153','154','155','156','157','158','159'...
    ,'175','174','173','172','171','170','169','168','167','166','165','164','163','162','160'...
    ,'176','178','179','180','181','182','183','184','185','186','187','188','189','190','191'...
    ,'207','206','205','204','203','202','201','200','199','198','197','196','195','194','192'...
    ,'208','210','211','212','213','214','215','216','217','218','219','220','221','222','223'...
    ,'239','238','237','236','235','234','233','232','231','230','229','228','227','226','224'};
ii = 1;
% for ii=1:length(filename)
    data_test = csvread(sprintf('%s.csv', filename{ii}),0,3,[0 3 999 4]);
%     data_test1 = csvread(sprintf('%s.csv', filename{ii}),0,5,[0 5 999 6]);
    data = zeros(2,N*fram_num);
%     data1 = zeros(2,N*fram_num);
    
   for cnt = 1:2
        for cnt1 = 1:fram_num
            data_tem = data_test(round(first_sp+s_fram*(cnt1-1)):round(first_sp-1+s_fram*cnt1),cnt);
            for cnt2 = 1:N
                data(cnt,cnt2+N*(cnt1-1)) = data_tem(2+round(s_num*(cnt2-1)));
            end

        end
   end
%     
%    for cnt = 1:2
%         for cnt1 = 1:fram_num
%             data_tem1 = data_test1(round(first_sp+s_fram*(cnt1-1)):round(first_sp-1+s_fram*cnt1),cnt);
%             for cnt2 = 1:N
%                 data1(cnt,cnt2+N*(cnt1-1)) = data_tem1(2+round(s_num*(cnt2-1)));
%             end
% 
%         end
%    end
    
   data_c_tem = data(1,:)-1i*data(2,:);
%    data_c_tem1 = data1(1,:)-1i*data1(2,:);
   data_c = reshape(data_c_tem,N,[]);
%    data_c1 = reshape(data_c_tem1,N,[]);
%    data_c2 = [data_c; data_c1];  
   data_c2 = data_c;  
   N_hamming1 = hamming(N)*ones(1,fram_num);
   ifft_num = 1024*2;
   range = ifft(data_c2.*N_hamming1,ifft_num);
   delt_range = c/(2*ifft_num*delt_f);
   range = circshift(range,-1147);
   profile(:,ii) = range;
   
% end
% zz = profile;
% 
% %
% time_delay = 0;
% 
% 
% % assume digital oscilloscope resolution in ns
% p = delt_range;
% 
% % wavelength in cm
% lamda = 30 / fc;
% 
% %% scan angle from -30 to 30 degrees
% 
% %range resolution
% delt_range = c/(2*ifft_num*delt_f);
% %range axis
% r_axis = (0:ifft_num-1)*delt_range;
% 
% plot(r_axis, abs(profile));
% 
% 
% % TODO uncomment
% if 0
% 
% mag = zeros(length(axis_z),length(axis_Y),length(axis_X));
% 
% for i3 = 1 : 1 : length(axis_X);  % i represents steering angle from -30 to 30
%     for i2 = 1 : 1 : length(axis_Y); % r represents distance from 1 to 1000, r=1 means 0.3cm
%        for i5 = 1 : 1 : length(axis_z);
%         % transmitting path in cm, a value dependent of distance and angle
%         Lt = sqrt( (tx_X - axis_X(i3))^2 + (tx_Y - axis_Y(i2))^2 +(tx_z - axis_z(i5))^2);
%         
%         for i6 = 1 : 1: MM
%         % receiving path in cm, an array depedent of distance, angle and #n
%         n = 1 : 1 : NN; % n represents # of receiving antenna from 1 to N
%         Lr = sqrt( (tx_X + sx + (n-1)*d2 - axis_X(i3)).^2 + (tx_Y + sy + (i6-1)*d1 - axis_Y(i2))^2 + (tx_z + sz - axis_z(i5))^2 ); % Lr is a 1*N array
%         % phase delay of N receiving antennas       
%         phi_steer = 2 * pi / lamda * Lr;
%         % phase difference regarding to the central one
% %         dphi_steer = phi_steer - phi_steer(round((NN+1)/2));
%         % distance difference was corrected in this program, it's necessary especially when s>>t  
%         % mth row data in matrix zz
%         m = round((Lt+Lr)/(p*100) + time_delay/p);
%             for i4 = 1 : 1 : NN
%             mag(i5,i2,i3) = mag(i5,i2,i3) + zz(m(i4),i4 + (i6-1)*NN)*exp(j*phi_steer(i4));
%             end
%         end
%        end
%     end
% end
% 
% %% Get rid of the coupling and wall reflection
% 
% z = abs(mag);
% % z(1:100,:) = 0;
% for i3 = 1 : 1 : length(axis_X);  % i represents steering angle from -30 to 30
%     for i2 = 1 : 1 : length(axis_Y); % r represents distance from 1 to 1000, r=1 means 0.3cm
%         
%         zzz(i2,i3) = max(z(:,i2,i3));
%         
%     end
% end
% max_3d=0;
% v=1;
% 
% for i3 = 1 : 1 : length(axis_X);  % i represents steering angle from -30 to 30
%     for i2 = 1 : 1 : length(axis_Y); % r represents distance from 1 to 1000, r=1 means 0.3cm
%         for i5 = 1 : 1 : length(axis_z);
%             if z(i5,i2,i3)>max_3d
%                 max_3d = z(i5,i2,i3);
%                 v = i5;
%             end                       
%         end   
%     end
% end
% 
% 
% 
% figure
% h = pcolor(axis_X/100,axis_Y/100,zzz);
% set(h, 'LineStyle', 'none')
% colormap('default')
% colorbar
% % caxis([-20 0])
% xlabel('Cross Range (m)','linewidth',12)
% ylabel('Height (m)','linewidth',12)
% % title('BP Image')
% %axis ([-150 150 50 250])
% % figure
% % [range_y,range_z,range_x]=meshgrid(axis_Y/100,axis_z/100,axis_X/100);
% % yslice=0;
% % zslice=(v-1)*5/100;
% % xslice=0;%[2.2 3];%[2 2.1 2.2 2.3 2.4 3];
% % slice(range_y,range_z,range_x,20*log10(z),yslice,zslice,xslice)
% % xlabel('Down Range (m)','fontsize',12)
% % ylabel('Cross Range (m)','fontsize',12)
% % zlabel('Height (m)','fontsize',12)
% % % axis([0 2.0 0 2 0 2])
% % colormap('default')
% % colorbar
% % % caxis([-20 0])
% end % TODO uncomment
