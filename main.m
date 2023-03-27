% digits(5); % 注意！'digits' 需要 Symbolic Math Toolbox。
% 导入数据，dataS1 dataS2 dataS3来源于data.xlsx，存储于matlab.mat
Is = dataS1.Is;
Im = dataS2.Im;
X = dataS3.X;

% 计算V_H
VH_1 = table2array(dataS1(:,2:end)) * ([1 -1 1 -1]') ./ 4;
VH_2 = table2array(dataS2(:,2:end)) * ([1 -1 1 -1]') ./ 4;
VH_3 = table2array(dataS3(:,2:end)) * ([1 -1]') ./ 2; % 简单对称测量的数值
VH_31 = table2array(dataS3(:,2)); % 无对称测量的数值

% 计算R_H，进行拟合
% 已知函数肯定经过原点（调零了），所以去掉常数项   
f=fittype('RH*x','independent','x','coefficients',{'RH'}); 
[cfun1,rsquare1]=fit(VH_1, Is,f);
[cfun2,rsquare2]=fit(Im, VH_2,f);
tRH_1 = cfun1.RH;
tRH_2 = cfun2.RH;

% 0.181*0.0002/(4*10e-7*1800*)=0.4525/9 所以手动解决复杂计算

RH_1 = tRH_1 * 0.4525/(9*0.5*pi);
RH_2 = tRH_2 * 0.4525/(9*0.003*pi);
RH = (RH_1 + RH_2) / 2;

% 载流子密度n
d = 0.0002; % 霍尔元件厚度
ec = 1.602176634e-19; % 电子电荷量
n = 3*pi/(8*ec*RH);

% 计算霍尔灵敏度KH
KH = RH/d;

% 计算磁感应强度
Is_3=3;
B = VH_3.*(KH/Is_3);
B_1 = VH_31.*(KH/Is_3);
B_2 = VH_31.*(1.0278*KH/Is_3);

% 计算理论磁感应强度
c_KH=174; % 厂家的霍尔灵敏度
c_B = VH_3.*(c_KH/Is_3); % 理论磁感应分布

% 绘图
plot(X, B, "+", X, c_B, X ,B_1, "ok", X ,B_2, "*");
title('磁感应强度在螺线管轴线上的分布情况');
xlabel('位置(cm)');
ylabel('磁感应强度');
set(gca, 'fontsize', 14);
set(gca, 'XMinorTick', 'on');
set(gca, 'XGrid', 'on');
set(gca, 'YGrid', 'on');
set(gca, 'LineWidth', 1.5);
d=legend('部分消除副效应的值','根据厂家K_H计算的理论值',"无对称测量的数值","未消除副效应并乘以补偿系数的值");