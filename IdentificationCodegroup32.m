u=DataCommands.';
y=Data(:,1).';
offset=0; %Operating point
SystemOrder=[0 1]; %Number of zeros and of poles (0 and 1), respectively.
sysIdent=IdentifySystem(u,y-offset,SystemOrder,Ts);
plot(time,y-offset,'.');
hold on;
lsim(sysIdent,u,time);