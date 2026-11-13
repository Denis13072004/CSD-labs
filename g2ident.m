%G2 identification

openinout;
Ts = 0.01;

lengthExp = 3;
N0 = round(lengthExp/Ts);

Data = zeros(N0,2);
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
    Data(i,2) = in2; %in2 = ball position
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

u_speed = Data(:,1);
y_position = Data(:,2);

offset_u = u_speed(1);
offset_y = y_position(1);
u_lin = u_speed - offset_u;
y_lin = y_position - offset_y;


SystemOrder = [0 2]; %System of order 2

sysIdent_position = IdentifySystemgroup32(u_lin, y_lin, SystemOrder, Ts);

disp('Fonction de transfert identifiée (vitesse -> position');
sysIdent_position;

figure;
plot(time, y_lin, '.r');
hold on;
lsim(sysIdent_position, u_lin, time);
title("Validation du modèle aérodynamique (boucle externe");
xlabel("Temps [s]");
ylabel("Position linéarisée [cm]");
legend("Mesure physique", "modele mathematique simule");
grid on;