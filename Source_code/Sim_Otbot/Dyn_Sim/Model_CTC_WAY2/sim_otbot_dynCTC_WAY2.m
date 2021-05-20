clearvars
close all
clc
%% Flags
FlagVideo = 'YES'; % Flag to define if you want video output or not
               % (FlagVideo == YES)> simulation with VIDEO output
               % (FlagVideo == NO )> simulation without VIDEO output
               
u_Flag = 'CTC_PP'; % Flag to define if you want a constnat torque for all simulation or not
               % (u_Flag == CTE)> simulation with constant torques
               % (u_Flag == VAR)> simulation with a torque function of time
               % (u_Flag == CTC_LQR)> simulation with a CTC controler using
               % LQR
               % (u_Flag == CTC_PP)> simulation with a CTC controler using
               % pole placement method
               
               % Set a fixed point in case u_Flag = CTE
                Fix_point = [2,2,0,0,0,0]'; % [x,y,alpha,varphi_r,varphi_l,varphi_p] velocities are 0
                
                % Now we create torques comand vector (Only used if u_Flag is set to CTE or VAR)
                u = [0.1;0.1;-0.1]; % All in Nm
               
goal_Flag = 'CIRCLE'; % Flag to define the desired trajectory for the robot, only works if u is set to LQR or PP
               % (goal_Flag == FIX)> goal trajectory is a fixed point
               % (goal_Flag == CIRCLE)> goal trajectory is a circle
               % (goal_Flag == POLILINE)> goal trajectory is a poliline
               
TrackFlag = 'PF'; % Flag to define if you want to track the path of each center of mass
               % (TrackFlag == NO)> plots without any paths of center of
               % mass plotted
               
               % (TrackFlag == CB)> plots the path of the center of mass of
               % the chassis body
               
               % (TrackFlag == PF)> plots the path of the center of mass of
               % the platform body
               
               % (TrackFlag == BOTH)> plots the path of both centers of
               % mass
TargetFlag = 'YES'; % Flag to choos if you want to see the desired goal in the video simulation
               % (TargetFlag == YES)> A red target will be displayed in the
               % simulation
               % (TargetFlag == NO)> There won't be a target in the video
               % simulation
               
KinEnFlag = 'NO'; % Flag to choose if Kinetic energic plot must be displayed or not
               % (KinEnFlag == YES)> Outputs a plot of kinetic energy
               % (KinEnFlag == NO )> No output plot of kinetic energy
               
Jdot_qdotFlag = 'NO'; % Flag to choose if plot of equation Jdot*qdot is equal to 0 during all simulation
               % (Jdot_qdotFlag == YES)> Outputs a plot of this equation
               % (Jdot_qdotFlag == NO)> No output of this plot
               
ErrorFlag = 'YES'; % Flag to choose if error plots are displayed or not
               % (ErrorFlag == YES)> Error plots will be displayed
               % (ErrorFlag == NO)> Error plots will not be displayed
               
%% Setting up simulation parameters
tf = 10;      % Final simulation time
h = 0.001;    % Number of samples within final vectors (times and states)
opts = odeset('MaxStep',1e-3); % Max integration time step

%% Setting up model parameters & matrices
load("m_struc")
load("sm_struc")

%% Initial conditions
p0 = [0,0,0]';
varphi0 = [0,0,0]';

% pdot0 will be set in order to fullfill the speeds of the desired
% trajectory in order to have 0 errors in configuration and speeds at time
% 0.
pdot0 = [0.3*cos(0.3*0),-0.3*sin(0.3*0),0]';

% pdot0 = zeros(3,1);

% Need MIIK
MIIKmat = sm.MIIKmatrix(p0(3),varphi0(3));

% Computing p0
varphidot0 = MIIKmat*pdot0;

% Initial conditions for the system
xs0=[p0; varphi0; pdot0; varphidot0];

%% Desired trajectory
if strcmp(u_Flag,'CTC_LQR') || strcmp(u_Flag,'CTC_PP')
    if strcmp(goal_Flag,'FIX')
        cp.pss = Fix_point; 
    else
        cp.pss = zeros(6,1);
    end
end

%% Creting the gains matrix fot the CTC 

% Our linear system matrices are
Actc = [zeros(3,3),eye(3,3); zeros(3,3), zeros(3,3)];
Bctc = [zeros(3,3);eye(3,3)];


if strcmp(u_Flag,'CTC_LQR')
    Qctc = [3e5*eye(3,3),zeros(3,3);
            zeros(3,3), 5*eye(3,3)];
    Rctc = 5*eye(3,3);
    cp.K = lqr(Actc,Bctc,Qctc,Rctc);
    
elseif strcmp(u_Flag,'CTC_PP')
%      EIG_set = [-0.61,-0.6130,-0.7555, -20, -19.8545, -19.5770];
%      cp.K = place(Actc,Bctc,EIG_set);

%     K1mat = diag([20,12.2,200]);
%     K2mat = diag([40,20.61,220]);

%     K1mat = diag([10 10 10]);
%     K2mat = diag([10 10 10]);

    K1mat = diag([0 0 0]);
    K2mat = diag([0 0 0]);
    cp.K = [K1mat,K2mat];
end


%% Building the diferential equation
dxdt= @(t,xs) xdot_dyn_otbotCTC(t, xs, sm, u, u_Flag, cp, goal_Flag);

%% Simulationg with ode45
t = 0:h:tf;
[times,states]=ode45(dxdt,t,xs0,opts);

%% Vectorize the path of centers of mass
if strcmp(TrackFlag,'NO')==0 
    
    % Setting this to adjust it to the video, here and down below they must
    % heve the same values, n & fs
    fs=30;
    n=round(1/(fs*h));
    
    % Set, ploting factor:
    Gpf = 16; % This plot factor is to scale if we want compute the com of each body every frame (Gpf = 1) or less frequently i.e every 2 frames (Gpf = 2...)
    n2 = Gpf*n;
    
    aux1=length(times);  
    GBpmat = zeros(3,round(aux1/n2));
    GPpmat = zeros(3,round(aux1/n2));
    jaux=1;

    for i = 1:n2:aux1
        q.x = states(i,1);
        q.y = states(i,2);
        q.alpha = states(i,3);
        q.varphi_r = states(i,4);
        q.varphi_l = states(i,5);
        q.varphi_p = states(i,6);

        [GBpi,GPpi] = c_o_m_bodies(m,q);
        GBpmat(:,jaux) = GBpi;
        GPpmat(:,jaux) = GPpi;
        jaux=jaux+1;
    end
end

%% Compute KinEnergy in Every instant
if strcmp(KinEnFlag,'YES')
    lst = length(states);
    kinenvalues = zeros(lst,1);
   for i=1:lst
       kinenvalues(i,1) = sm.Texpr(states(i,3),states(i,9),states(i,6),states(i,11),states(i,12),states(i,10),states(i,7),states(i,8));
   end
end

%% Compute the error for every instant
uswitch = strcmp(u_Flag,'CTC_LQR') || strcmp(u_Flag,'CTC_PP');

if strcmp(ErrorFlag,'YES') && uswitch
    lst = length(states);
    errorstates = zeros(lst,6);
    switch goal_Flag
        case 'FIX'
            for i = 1:lst
                errorstates(i,1:3) = cp.pss(1:3)' - states(i,1:3);
                errorstates(i,4:6) = cp.pss(4:6)' - states(i,7:9);
            end
        case 'CIRCLE'
            for i=1:lst
                [Xc,Yc,Alphac,Xdotc,Ydotc,Alphadotc,Xddotc,Yddotc,Alphaddotc] = TD_circle_of_time_XYA(times(i));
                errorstates(i,1:3) = [Xc,Yc,Alphac] - states(i,1:3);
                errorstates(i,4:6) = [Xdotc,Ydotc,Alphadotc] - states(i,7:9);
            end
        case 'POLILINE'
            for i=1:lst
                [Xc,Yc,Alphac,Xdotc,Ydotc,Alphadotc,Xddotc,Yddotc,Alphaddotc] = TD_polyline_of_time(times(i));
                errorstates(i,1:3) = [Xc,Yc,Alphac] - states(i,1:3);
                errorstates(i,4:6) = [Xdotc,Ydotc,Alphadotc] - states(i,7:9);
            end
            
    end
end

%% Compute desired GOAL (Target) in Every instant

uswitch = strcmp(u_Flag,'CTC_LQR') || strcmp(u_Flag,'CTC_PP');

if strcmp(TargetFlag,'YES') && strcmp(FlagVideo,'YES') && uswitch
    TEFlag = 0;
    lst = length(states);
    switch goal_Flag
        case 'FIX'
            targetpos = repmat(cp.pss,[lst,1]);
            
        case 'CIRCLE'
            targetpos = zeros(lst,3);
            for i=1:lst
                [Xc,Yc,Alphac,aux1,aux2,aux3,aux4,aux5,aux6] = TD_circle_of_time_XYA(times(i));
                targetpos(i,:) = [Xc,Yc,Alphac];
            end
        case 'POLILINE'
            targetpos = zeros(lst,3);
            for i=1:lst
                [Xc,Yc,Alphac,aux1,aux2,aux3,aux4,aux5,aux6] = TD_polyline_of_time(times(i));
                targetpos(i,:) = [Xc,Yc,Alphac];
            end
        otherwise
            disp('This goal_Flag does not exist cant compute the Target')
            TEFlag = 1;
    end                      
else 
    TEFlag = 1;
    disp('The combination of flags used is not correct to compute Target')
    disp('Please change the flags to a possible combination in order to display the desired results')
    disp('Target loaction will not be computed')
end

%% Plot results
figure;
plot(times,states(:,1))
xlabel('t(s)'),ylabel('x(meters)'),title('Configuration')

figure;
plot(times,states(:,2))
xlabel('t(s)'),ylabel('y(meters)'),title('Configuration')

figure;
plot(times,states(:,3))
xlabel('t(s)'),ylabel('alpha(radians)'),title('Configuration')

figure;
plot(times,states(:,4))
xlabel('t(s)'),ylabel('varphi_r(radians)'),title('Configuration')

figure;
plot(times,states(:,5))
xlabel('t(s)'),ylabel('varphi_l(radians)'),title('Configuration')

figure;
plot(times,states(:,6))
xlabel('t(s)'),ylabel('varphi_p(radians)'),title('Configuration')

figure;
plot(times,states(:,7))
xlabel('t(s)'),ylabel('xdot(meters/second)'),title('Velocity')

figure;
plot(times,states(:,8))
xlabel('t(s)'),ylabel('ydot(meters/second)'),title('Velocity')

figure;
plot(times,states(:,9))
xlabel('t(s)'),ylabel('alphadot(radians/second)'),title('Velocity')

figure;
plot(times,states(:,10))
xlabel('t(s)'),ylabel('varphidot_r(radians/second)'),title('Velocity')

figure;
plot(times,states(:,11))
xlabel('t(s)'),ylabel('varphidot_l(radians/second)'),title('Velocity')

figure;
plot(times,states(:,12))
xlabel('t(s)'),ylabel('varphidot_p(radians/second)'),title('Velocity')

if strcmp(KinEnFlag,'YES')
    figure;
    plot(times,kinenvalues)
    xlabel('t(s)'),ylabel('Kinetic Energy (Joules)'), title('System Energy')
else
    disp('Energy plot will not be displayed')
end

if strcmp(ErrorFlag,'YES') && uswitch
    figure;
    plot(times,errorstates(:,1))
    xlabel('t(s)'),ylabel('X Error(meters)'),title('Configuration Error')
    
    figure;
    plot(times,errorstates(:,2))
    xlabel('t(s)'),ylabel('Y Error(meters)'),title('Configuration Error')
    
    figure;
    plot(times,errorstates(:,3))
    xlabel('t(s)'),ylabel('Alpha Error(radians)'),title('Configuration Error')
    
    figure;
    plot(times,errorstates(:,4))
    xlabel('t(s)'),ylabel('Xdot Error(meters/s)'),title('Velocity Error')
    
    figure;
    plot(times,errorstates(:,5))
    xlabel('t(s)'),ylabel('Ydot Error(meters/s)'),title('Velocity Error')
    
    figure;
    plot(times,errorstates(:,6))
    xlabel('t(s)'),ylabel('Alphadot Error(radians/s)'),title('Velocity Error')
else
    disp('Error plots will not be displayed')
end

%% Seting Jdot_qdot = 0 Flag

if strcmp(Jdot_qdotFlag,'YES')
    lst = length(states);
    J_qvalues = zeros(lst,3);
    for i=1:lst
        Jplot = sm.Jmatrix(states(i,3),states(i,6));
        qdotplot = states(i,7:12)';
        J_qvalues(i,:) = (Jplot*qdotplot)';
    end
    figure;
    plot(times,J_qvalues)
    xlabel('t(s)'),ylabel('Result vector'), title('Vector result of J*qdot')
end

%% Movie and video of the simulation
switch FlagVideo
    case 'YES'
        switch TrackFlag
            case 'NO'
                time=cputime;
                % Animation
                % h is the sampling time 
                % n is the scaling factor in order not to plot with the same step
                % than during the integration with ode45

                fs=30;
                n=round(1/(fs*h));

                % Set up the movie.
                writerObj = VideoWriter('otbot_sim','MPEG-4'); % Name it.
                %writerObj.FileFormat = 'mp4';
                writerObj.FrameRate = fs; % How many frames per second.
                open(writerObj);
                
                TEFlagcheck = strcmp(TargetFlag,'YES') && TEFlag == 1;
                if strcmp(TargetFlag,'NO') || TEFlagcheck
                    for i = 1:n:length(times)
                            q.x = states(i,1);
                            q.y = states(i,2);
                            q.alpha = states(i,3);
                            q.varphi_r = states(i,4);
                            q.varphi_l = states(i,5);
                            q.varphi_p = states(i,6);

                            elapsed = cputime-time;
                            if elapsed > 1200
                                disp(elapsed);
                                disp('took too long to generate the video')
                                break
                            else
                                draw_otbot(m,q)
                                frame = getframe(gcf); % 'gcf' can handle if you zoom in to take a movie.
                                writeVideo(writerObj, frame); 
                            end

                    end
                    close(writerObj); % Saves the movie.
                    
                elseif strcmp(TargetFlag,'YES') && TEFlag == 0
                    for i = 1:n:length(times)
                            q.x = states(i,1);
                            q.y = states(i,2);
                            q.alpha = states(i,3);
                            q.varphi_r = states(i,4);
                            q.varphi_l = states(i,5);
                            q.varphi_p = states(i,6);

                            elapsed = cputime-time;
                            if elapsed > 1200
                                disp(elapsed);
                                disp('took too long to generate the video')
                                break
                            else
                                draw_otbot(m,q)
                                hold on
                                otbot_circle_v2(targetpos(i,1),targetpos(i,2),m.l_2/4,'r');
                                hold off
                                frame = getframe(gcf); % 'gcf' can handle if you zoom in to take a movie.
                                writeVideo(writerObj, frame); 
                            end

                    end
                    close(writerObj); % Saves the movie.
                    
                end
                
            case 'BOTH'
                time=cputime;
                % Animation
                % h is the sampling time 
                % n is the scaling factor in order not to plot with the same step
                % than during the integration with ode45

                fs=30;
                n=round(1/(fs*h));

                % Set up the movie.
                writerObj = VideoWriter('otbot_sim','MPEG-4'); % Name it.
                %writerObj.FileFormat = 'mp4';
                writerObj.FrameRate = fs; % How many frames per second.
                open(writerObj);
                jaux = 1;
                jaux2 = 1;
                
                TEFlagcheck = strcmp(TargetFlag,'YES') && TEFlag == 1;
                if strcmp(TargetFlag,'NO') || TEFlagcheck
                    for i = 1:n:length(times)
                            q.x = states(i,1);
                            q.y = states(i,2);
                            q.alpha = states(i,3);
                            q.varphi_r = states(i,4);
                            q.varphi_l = states(i,5);
                            q.varphi_p = states(i,6);

                            elapsed = cputime-time;
                            if elapsed > 1200
                                disp(elapsed);
                                disp('took too long to generate the video')
                                break
                            else
                                draw_otbot(m,q)
                                if jaux2 == 1
                                    GBpplot = GBpmat(:,1:jaux);
                                    GPpplot = GPpmat(:,1:jaux);
                                    multi_circles(GBpplot,m.l_2/6,'b')
                                    hold on
                                    multi_circles(GPpplot,m.l_2/6,'g')
                                    jaux2 = jaux2 + 1;
                                    jaux = jaux+1;
                                elseif jaux2>= Gpf
                                    multi_circles(GBpplot,m.l_2/6,'b')
                                    hold on
                                    multi_circles(GPpplot,m.l_2/6,'g')
                                    jaux2 = 1;
                                else
                                    multi_circles(GBpplot,m.l_2/6,'b')
                                    hold on
                                    multi_circles(GPpplot,m.l_2/6,'g')
                                    jaux2 = jaux2 + 1;
                                end
                                frame = getframe(gcf); % 'gcf' can handle if you zoom in to take a movie.
                                writeVideo(writerObj, frame); 
                            end
                    end
                    close(writerObj); % Saves the movie.
                    
                elseif strcmp(TargetFlag,'YES') && TEFlag == 0
                    for i = 1:n:length(times)
                            q.x = states(i,1);
                            q.y = states(i,2);
                            q.alpha = states(i,3);
                            q.varphi_r = states(i,4);
                            q.varphi_l = states(i,5);
                            q.varphi_p = states(i,6);

                            elapsed = cputime-time;
                            if elapsed > 1200
                                disp(elapsed);
                                disp('took too long to generate the video')
                                break
                            else
                                draw_otbot(m,q)
                                if jaux2 == 1
                                    GBpplot = GBpmat(:,1:jaux);
                                    GPpplot = GPpmat(:,1:jaux);
                                    multi_circles(GBpplot,m.l_2/6,'b')
                                    hold on
                                    multi_circles(GPpplot,m.l_2/6,'g')
                                    hold on
                                    otbot_circle_v2(targetpos(i,1),targetpos(i,2),m.l_2/4,'r');
                                    hold off
                                    jaux2 = jaux2 + 1;
                                    jaux = jaux+1;
                                elseif jaux2>= Gpf
                                    multi_circles(GBpplot,m.l_2/6,'b')
                                    hold on
                                    multi_circles(GPpplot,m.l_2/6,'g')
                                    hold on
                                    otbot_circle_v2(targetpos(i,1),targetpos(i,2),m.l_2/4,'r');
                                    hold off
                                    jaux2 = 1;
                                else
                                    multi_circles(GBpplot,m.l_2/6,'b')
                                    hold on
                                    multi_circles(GPpplot,m.l_2/6,'g')
                                    hold on
                                    otbot_circle_v2(targetpos(i,1),targetpos(i,2),m.l_2/4,'r');
                                    hold off
                                    jaux2 = jaux2 + 1;
                                end
                                frame = getframe(gcf); % 'gcf' can handle if you zoom in to take a movie.
                                writeVideo(writerObj, frame); 
                            end
                    end
                    close(writerObj); % Saves the movie.
                    
                end
                                        
            case 'CB'
                time=cputime;
                % Animation
                % h is the sampling time 
                % n is the scaling factor in order not to plot with the same step
                % than during the integration with ode45

                fs=30;
                n=round(1/(fs*h));

                % Set up the movie.
                writerObj = VideoWriter('otbot_sim','MPEG-4'); % Name it.
                %writerObj.FileFormat = 'mp4';
                writerObj.FrameRate = fs; % How many frames per second.
                open(writerObj);
                jaux = 1;
                jaux2 = 1;
                
                TEFlagcheck = strcmp(TargetFlag,'YES') && TEFlag == 1;
                if strcmp(TargetFlag,'NO') || TEFlagcheck
                    for i = 1:n:length(times)
                            q.x = states(i,1);
                            q.y = states(i,2);
                            q.alpha = states(i,3);
                            q.varphi_r = states(i,4);
                            q.varphi_l = states(i,5);
                            q.varphi_p = states(i,6);

                            elapsed = cputime-time;
                            if elapsed > 1200
                                disp(elapsed);
                                disp('took too long to generate the video')
                                break
                            else
                                draw_otbot(m,q)
                                if jaux2 == 1
                                    GBpplot = GBpmat(:,1:jaux); 
                                    multi_circles(GBpplot,m.l_2/6,'b')
                                    jaux2 = jaux2 + 1;
                                    jaux = jaux+1;
                                elseif jaux2>= Gpf
                                    multi_circles(GBpplot,m.l_2/6,'b')
                                    jaux2 = 1;
                                else
                                    multi_circles(GBpplot,m.l_2/6,'b')
                                    jaux2 = jaux2 + 1;
                                end
                                frame = getframe(gcf); % 'gcf' can handle if you zoom in to take a movie.
                                writeVideo(writerObj, frame); 
                            end
                    end
                    close(writerObj); % Saves the movie.
                
                elseif strcmp(TargetFlag,'YES') && TEFlag == 0
                    for i = 1:n:length(times)
                            q.x = states(i,1);
                            q.y = states(i,2);
                            q.alpha = states(i,3);
                            q.varphi_r = states(i,4);
                            q.varphi_l = states(i,5);
                            q.varphi_p = states(i,6);

                            elapsed = cputime-time;
                            if elapsed > 1200
                                disp(elapsed);
                                disp('took too long to generate the video')
                                break
                            else
                                draw_otbot(m,q)
                                if jaux2 == 1
                                    GBpplot = GBpmat(:,1:jaux); 
                                    multi_circles(GBpplot,m.l_2/6,'b')
                                    hold on
                                    otbot_circle_v2(targetpos(i,1),targetpos(i,2),m.l_2/4,'r');
                                    hold off
                                    jaux2 = jaux2 + 1;
                                    jaux = jaux+1;
                                elseif jaux2>= Gpf
                                    multi_circles(GBpplot,m.l_2/6,'b')
                                    hold on
                                    otbot_circle_v2(targetpos(i,1),targetpos(i,2),m.l_2/4,'r');
                                    hold off
                                    jaux2 = 1;
                                else
                                    multi_circles(GBpplot,m.l_2/6,'b')
                                    hold on
                                    otbot_circle_v2(targetpos(i,1),targetpos(i,2),m.l_2/4,'r');
                                    hold off
                                    jaux2 = jaux2 + 1;
                                end
                                frame = getframe(gcf); % 'gcf' can handle if you zoom in to take a movie.
                                writeVideo(writerObj, frame); 
                            end
                    end
                    close(writerObj); % Saves the movie.
                end
                
            case 'PF'
                time=cputime;
                % Animation
                % h is the sampling time 
                % n is the scaling factor in order not to plot with the same step
                % than during the integration with ode45

                fs=30;
                n=round(1/(fs*h));

                % Set up the movie.
                writerObj = VideoWriter('otbot_sim','MPEG-4'); % Name it.
                %writerObj.FileFormat = 'mp4';
                writerObj.FrameRate = fs; % How many frames per second.
                open(writerObj);
                jaux = 1;
                jaux2 = 1;
                
                TEFlagcheck = strcmp(TargetFlag,'YES') && TEFlag == 1;
                if strcmp(TargetFlag,'NO') || TEFlagcheck
                    for i = 1:n:length(times)
                            q.x = states(i,1);
                            q.y = states(i,2);
                            q.alpha = states(i,3);
                            q.varphi_r = states(i,4);
                            q.varphi_l = states(i,5);
                            q.varphi_p = states(i,6);

                            elapsed = cputime-time;
                            if elapsed > 1200
                                disp(elapsed);
                                disp('took too long to generate the video')
                                break
                            else
                                draw_otbot(m,q)
                                if jaux2 == 1

                                    GPpplot = GPpmat(:,1:jaux);

                                    multi_circles(GPpplot,m.l_2/6,'g')
                                    jaux2 = jaux2 + 1;
                                    jaux = jaux+1;
                                elseif jaux2>= Gpf

                                    multi_circles(GPpplot,m.l_2/6,'g')
                                    jaux2 = 1;
                                else

                                    multi_circles(GPpplot,m.l_2/6,'g')
                                    jaux2 = jaux2 + 1;
                                end
                                frame = getframe(gcf); % 'gcf' can handle if you zoom in to take a movie.
                                writeVideo(writerObj, frame); 
                            end
                    end
                    close(writerObj); % Saves the movie.
                
                elseif strcmp(TargetFlag,'YES') && TEFlag == 0
                    for i = 1:n:length(times)
                            q.x = states(i,1);
                            q.y = states(i,2);
                            q.alpha = states(i,3);
                            q.varphi_r = states(i,4);
                            q.varphi_l = states(i,5);
                            q.varphi_p = states(i,6);

                            elapsed = cputime-time;
                            if elapsed > 1200
                                disp(elapsed);
                                disp('took too long to generate the video')
                                break
                            else
                                draw_otbot(m,q)
                                if jaux2 == 1
                                    GPpplot = GPpmat(:,1:jaux);
                                    multi_circles(GPpplot,m.l_2/6,'g')
                                    hold on
                                    otbot_circle_v2(targetpos(i,1),targetpos(i,2),m.l_2/4,'r');
                                    hold off
                                    jaux2 = jaux2 + 1;
                                    jaux = jaux+1;
                                elseif jaux2>= Gpf
                                    multi_circles(GPpplot,m.l_2/6,'g')
                                    hold on
                                    otbot_circle_v2(targetpos(i,1),targetpos(i,2),m.l_2/4,'r');
                                    hold off
                                    jaux2 = 1;
                                else
                                    multi_circles(GPpplot,m.l_2/6,'g')
                                    hold on
                                    otbot_circle_v2(targetpos(i,1),targetpos(i,2),m.l_2/4,'r');
                                    hold off
                                    jaux2 = jaux2 + 1;
                                end
                                frame = getframe(gcf); % 'gcf' can handle if you zoom in to take a movie.
                                writeVideo(writerObj, frame); 
                            end
                    end
                    close(writerObj); % Saves the movie.
                end
                      
            otherwise
                disp('This TrackFlag does not exist, omitting the video')
        end            
    case 'NO'
        disp('Simulation without video launched');
    otherwise
        disp('This FlagVideo input does not exist');
end