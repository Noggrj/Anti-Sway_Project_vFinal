%%
clear;
close all;
% motor;
Ts = 15e-3;

% dados = dlmread('dados9',',',1,0);
dados = dlmread('dados2.txt',',',1,0);

y = dados(:,2);
u = dados(:,3);

N = length(y);

% tirando componente DC:
% y = y-mean(y);
% u = u-mean(u);


figure(1);
subplot(2,1,1)
plot(u);
title('Sinal de entrada')
subplot(2,1,2)
title('Sinal de saída')
plot(y);

%%

Ni = floor(2/3*N);
Nt = N-Ni;

yi = y(1:Ni);
ui = u(1:Ni);
yt = y(Ni+1:end);
ut = u(Ni+1:end);


%% Modelando como um sistema de 1a ordem
psi1 = [ui(1:Ni-1) -yi(1:Ni-1)]; % Matriz dos regressores;

% Ident. parâmetros usando MQ:
theta1 = (psi1.'*psi1)\psi1.'*yi(2:end)
% theta1 = pinv(psi1)*yi(3:end)

psiv1 = [ut(1:Nt-1) -yt(1:Nt-1)]; % Matriz dos regressores;
yhat1 = psiv1*theta1;

figure(2);
iter = 2:Nt;
stairs(iter,yt(2:end));
hold on;
stairs(iter,yhat1,'r');
title('Simulação livre (dados de validação): Sist. de 1a ordem')
legend('y(k)','yhat1(k)')

Gdf1 = filt([0 theta1(1)],[1 theta1(2)])
Gd1 = tf([0 theta1(1)],[1 theta1(2)],Ts)
printARX(Gd1,0,'u','y')

%% Modelando como um sistema de 2a ordem
psi2 = [ui(2:Ni-1) ui(1:Ni-2) -yi(2:Ni-1) -yi(1:Ni-2)]; % Matriz dos regressores;

% Ident. parâmetros usando MQ:
theta2 = (psi2.'*psi2)\psi2.'*yi(3:end)
% theta2 = pinv(psi2)*yi(3:end)

psiv2 = [ut(2:Nt-1) ut(1:Nt-2) -yt(2:Nt-1) -yt(1:Nt-2)]; % Matriz dos regressores;
yhat2 = psiv2*theta2;

figure(3);
iter = 3:Nt;
stairs(iter,yt(3:end));
hold on;
stairs(iter,yhat2,'r');
title('Simulação livre (dados de validação): Sist. de 2a ordem')
legend('y(k)','yhat2(k)')

Gdf2 = filt([0 theta2(1) theta2(2)],[1 theta2(3) theta2(4)])
Gd2 = tf([0 theta2(1) theta2(2)],[1 theta2(3) theta2(4)],Ts)
printARX(Gd2,0,'u','y')


figure(4);
iter = 3:Nt;
stairs(iter,yt(3:end),'k');
hold on;
stairs(iter,yhat1(2:end),'b--');
stairs(iter,yhat2,'r:');
title('Simulação livre (dados de validação): Sist. de 1a e 2a ordem')
legend('y(k)','yhat1(k)','yhat2(k)')


%% Resposta ao degrau:
figure(5);
step(Gd1,Gd2);
sisotool(Gd1,Gd2);

%
%
% >> C_Design1
% u(k) = -6.8872*e(k-0)+10.8326*e(k-1)-4.0171*e(k-2)+1.1544*u(k-1)-0.15402*u(k-2)
% >> C_Design2
% u(k) = -3.0672*e(k-0)+2.9876*e(k-1)+1.0005*u(k-1)
