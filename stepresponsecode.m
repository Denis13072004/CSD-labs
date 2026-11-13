%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Control System Design Lab: Sample Code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Setup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

openinout; %Open the ports of the analog computer.
Ts=0.01;%Set the sampling time in seconds. 
lengthExp=20; %Set the length of the experiment (in seconds).
N0=lengthExp/Ts; %Compute the number of points to save the datas.
Data=zeros(N0,2); %Vector saving the datas. If there are several datas to save, change "1" to the number of outputs.
DataCommands=ones(N0,1); %Vector storing the input sent to the plant.
cond=1; %Set the condition variable to 1.
i=1; %Set the counter to 1.
tic %Begins the first strike of the clock.
time=0:Ts:(N0-1)*Ts; %Vector saving the time steps.
V_measures = [7.5, 7.0, 6.7, 6.4, 6.0, 4.9, 3.9, 3.3, 2.9, 2.4];
D_centimeters = [18, 22, 25, 40, 46, 55, 61, 67, 74, 100];


%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

while cond==1
    if Ts*i<10
        input=6; %Input of the system.
    else 
        input =8;
    end
    anaout(input,0); %Command to send the input to the analog computer.
    [in1,in2,in3,in4,in5,in6,in7,in8]=anain; %Acquisition of the measurements.
    ball_position = interp1(V_measures, D_centimeters, in1, 'Linear', 'extrap');
    reference = 6.5;
    error = reference - ball_position;

% Control law PID
    Kp = 0.5;
    out1 = Kp * error;
    Data(i,1)=in1; %Save one of the measurements (in1).
    Data(i,2)=in2;
    DataCommands(i,1) =input ;
    t=toc; %Second strike of the clock.
    if t>i*Ts
        disp('Sampling time too small');%Test if the sampling time is too small.
    else
        while toc<=i*Ts %Does nothing until the second strike of the clock reaches the sampling time set.
        end
    end
    if i==N0 %Stop condition.
        cond=0;
    end
    i=i+1;
end


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Plots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

closeinout %Close the ports.

figure %Open a new window for plot.
xlabel = ('Time [s]');
ylabel = ('Input voltage [V]');
plot(time,Data(:,1),time,Data(:,2),time,DataCommands(:));
%Plot the experiment (input and output).