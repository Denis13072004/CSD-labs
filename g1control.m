
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CLOSED LOOP PI CONTROL - MOTOR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clearvars -except Ts

%% 1. Initialization

openinout;

Ts = 0.01;
lengthExp = 3;
N0 = round(lengthExp/Ts);

Data = zeros(N0,1);
DataCommands = zeros(N0,1);

time = (0:N0-1)'*Ts;

% PI parameters
Kp = 1;
Ki = 6.667;

integral = 0;

% Speed reference
speedreference = 2000;

% Sensor conversion (TO BE CALIBRATED)
speedScale = 400;

% Motor command limits
uMax = 10;
uMin = 0;

% Initial motor command
uBias = 6;
u = uBias;

tic;

%% 2. Closed-loop control

for i = 1:N0

    % Apply motor command
    anaout(u,0);

    % Read measurements
    [in1,in2,in3,in4,in5,in6,in7,in8] = anain;

    % Convert sensor voltage into motor speed
    speed = speedScale*in1;

    % Calculate error
    error = speedreference-speed;

    % Calculate proportional and integral terms
    integral_candidate = integral + error*Ts;

    % Unsaturated PI output
    u_unsat = uBias + Kp*error + Ki*integral_candidate;

    % Saturation
    u_new = max(uMin,min(uMax,u_unsat));

    % Anti-windup: conditional integration
    if (u_unsat == u_new) || ...
       (u_unsat > uMax && error < 0) || ...
       (u_unsat < uMin && error > 0)

        integral = integral_candidate;
    end

    % Update command
    u = u_new;

    % Save measurements
    Data(i,1) = speed;
    DataCommands(i,1) = u;

    % Sampling time
    while toc < i*Ts
    end

end

%% 3. Stop acquisition

anaout(0,0);
closeinout;

%% 4. Plot results

figure;

subplot(3,1,1);
plot(time,Data,'b','LineWidth',1.5);
hold on;
yline(speedreference,'r--');
ylabel('Speed');
legend('Measured speed','Reference');
grid on;

subplot(3,1,2);
plot(time,DataCommands,'k','LineWidth',1.5);
ylabel('Motor command (V)');
grid on;

subplot(3,1,3);
plot(time,speedreference-Data,'m','LineWidth',1.5);
xlabel('Time (s)');
ylabel('Error');
grid on;

sgtitle('PI Motor Speed Control');
