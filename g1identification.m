
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ACQUISITION : MOTOR COMMAND / MOTOR VELOCITY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clearvars -except Ts Data DataCommands time

openinout;

Ts = 0.01;
lengthExp = 3;
N0 = round(lengthExp/Ts);

Data = zeros(N0,1);
DataCommands = zeros(N0,1);

i = 1;
cond = 1;

tic;

time = (0:N0-1)'*Ts;

while cond == 1

    % Motor command
    if i*Ts < 1
        input = 6;
    else
        input = 8;
    end

    anaout(input,0);

    % Measurements
    [in1,in2,in3,in4,in5,in6,in7,in8] = anain;

    % IMPORTANT:
    % Here in1 must be the motor velocity measurement.
    Data(i,1) = in1; %in1=motor velocity 

    % Save the motor command
    DataCommands(i,1) = input;

    % Sampling time
    while toc < i*Ts
    end

    if i == N0
        cond = 0;
    end

    i = i+1;
end

closeinout;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOT ACQUISITION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure;

subplot(2,1,1);
plot(time,DataCommands,'LineWidth',1.5);
ylabel('Motor command (V)');
grid on;

subplot(2,1,2);
plot(time,Data(:,1),'LineWidth',1.5);
xlabel('Time (s)');
ylabel('Motor velocity');
grid on;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VALIDATION OF MOTOR TRANSFER FUNCTION G1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 1. Experimental data

u = DataCommands(:);
omega = Data(:,1);
omega = omega(:);

t = time(:);

%% 2. Remove initial offsets

N = min(50,length(u));

u0 = mean(u(1:N));
omega0 = mean(omega(1:N));

u_id = u-u0;
omega_id = omega-omega0;

%% 3. Theoretical transfer function

s = tf('s');

G1 = 1.2/(0.15*s+1);

disp('THEORETICAL MOTOR TRANSFER FUNCTION:');
G1

%% 4. Simulation

idx_baseline=(t>=0.7) & (t < 1.0);
y0=mean(omega_id(idx_baseline));
omega_sim = lsim(G1,u_id,t)+y0;

%% 5. FIT calculation

FIT = 100*(1-norm(omega_id-omega_sim) / ...
    norm(omega_id-mean(omega_id)));

fprintf('\n===== VALIDATION RESULTS =====\n');
fprintf('FIT = %.2f %%\n',FIT);

%% 6. Comparison plot

figure;

plot(t,omega_id,'k','LineWidth',1.8);
hold on;

plot(t,omega_sim,'r--','LineWidth',1.8);

grid on;

xlabel('Time (s)');
ylabel('Motor velocity');

legend('Experimental velocity',...
       'Theoretical model');

title('Validation of motor transfer function G1');

%% 7. Residuals

figure;

plot(t,omega_id-omega_sim,'b','LineWidth',1.4);

grid on;

xlabel('Time (s)');
ylabel('Residual');

title('Model validation residuals');

% tranfer function matlab

data_exp = iddata(omega_id, u_id, Ts);
G1_is = tfest(data_exp, 1, 0);

disp("Tranfer function identified by matlab:");
G1_is

figure(3)
clf;
plot(t,omega_id);hold on;
plot(t,omega_sim);
grid on;
xlabel('Time(s)');
ylabel('Motor velocity');
legend('experimental velocity');
title('Validation of motor transfer function');
%Calculate FIT


