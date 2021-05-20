function [ xdot ] = xdot_otbot1_CTC_DF_IMU(t, xs, m, sm, u, u_cte, u_Flag, cp, goal_Flag, FrictFlag, DistFlag, u_IntFlag, Int_Vec)
% XDOT_HEXAPOLE Summary of this function goes here
%   differential equation (non-linearized), that modelises our hexapole
%   system

% x = xs(1);
% y = xs(2);
alpha = xs(3);
% varphi_r = xs(4);
% varphi_l = xs(5);
varphi_p = xs(6);

% x_dot = xs(7);
% y_dot = xs(8);
alpha_dot = xs(9);
varphi_dot_r = xs(10);
varphi_dot_l = xs(11);
varphi_dot_p = xs(12);

% Setting fricctions
switch FrictFlag
    case 'YES'
        tau_friction(1:3,1) = zeros(3,1);
        tau_friction(4,1) = -m.b_frict(1,1)*varphi_dot_r; % tau_friction_right
        tau_friction(5,1) = -m.b_frict(2,1)*varphi_dot_l; % tau_friction_left
        tau_friction(6,1) = -m.b_frict(3,1)*varphi_dot_p; % tau_friction_pivot
    case 'NO'
        tau_friction = zeros(6,1);
    otherwise
        disp('Warning: This FrictFlag does not exist. Sistem will be simulated without friction')
        tau_friction = zeros(6,1);
end

% Setting Distrurbances
switch DistFlag
    case 'YES'
        D_vec = dist_funct(t);
    case 'NO'
        D_vec = zeros(6,1);
    otherwise
        D_vec = zeros(6,1);
end
     
Ms = sm.Mmatrix(alpha,varphi_p);
Cs = sm.Cmatrix(alpha,alpha_dot,varphi_p,varphi_dot_p);
MFIKs = sm.MFIKmatrix(alpha,varphi_p);
Js = sm.Jmatrix(alpha,varphi_p);
Es = sm.Ematrix;
Jdots = sm.Jdotmatrix(alpha,alpha_dot,varphi_p,varphi_dot_p);
M_bars = sm.M_barmatrix(alpha,varphi_p);
C_bars = sm.C_barmatrix(alpha,alpha_dot,varphi_p,varphi_dot_p);

qdot = xs(7:12);

switch u_Flag
    case 'CTE'
        qdotdot = [eye(6),zeros(6,3)]*pinv([Ms,Js.'; Js, zeros(3,3)])*[Es*u_cte + tau_friction + D_vec - Cs*qdot; -Jdots*qdot];
        
    case 'VAR'
        u_f = u_function(t, u, m, sm);
        u_zoh = zoh_function(t, u_f);
        qdotdot = [eye(6),zeros(6,3)]*pinv([Ms,Js.'; Js, zeros(3,3)])*[Es*u_zoh + tau_friction + D_vec - Cs*qdot; -Jdots*qdot];
                
    case 'CTC_LQR'
        switch goal_Flag
            case 'FIX'
                pdiff(1:2,1) = cp.pss(1:2,1)-xs(1:2,1);
                %pdiff(3,1) = angdiff(xs(3,1), cp.pss(3,1));
                pdiff(3,1) = cp.pss(3,1)-xs(3,1);
                pdiff(4:6,1) = cp.pss(4:6,1)-xs(7:9,1);
                
                u_2 = cp.K*pdiff;
                u = (MFIKs.')*(M_bars*u_2 + C_bars*qdot(1:3,1));
                u_zoh = zoh_function(t,u);
                qdotdot = [eye(6),zeros(6,3)]*pinv([Ms,Js.'; Js, zeros(3,3)])*[Es*u_zoh + tau_friction + D_vec - Cs*qdot; -Jdots*qdot];                
                
            case 'CIRCLE'
                [xss,yss,alphass,xdotss,ydotss,alphadotss,xdotdotss,ydotdotss,alphadotdotss] = TD_circle_of_time_XYA(t);
                cp.pss = [xss;yss;alphass;xdotss;ydotss;alphadotss];
                pd_dotdot = [xdotdotss; ydotdotss; alphadotdotss];
                
                pdiff(1:2,1) = cp.pss(1:2,1)-xs(1:2,1);
                %pdiff(3,1) = angdiff(xs(3,1), cp.pss(3,1));
                pdiff(3,1) = cp.pss(3,1)-xs(3,1);
                pdiff(4:6,1) = cp.pss(4:6,1)-xs(7:9,1);

                u_2 = pd_dotdot + cp.K*pdiff;
                u = (MFIKs.')*(M_bars*u_2 + C_bars*qdot(1:3,1));
                u_zoh = zoh_function(t,u);
                qdotdot = [eye(6),zeros(6,3)]*pinv([Ms,Js.'; Js, zeros(3,3)])*[Es*u_zoh + tau_friction + D_vec - Cs*qdot; -Jdots*qdot];
                                
            case 'POLILINE'
                [xss,yss,alphass,xdotss,ydotss,alphadotss,xdotdotss,ydotdotss,alphadotdotss] = TD_polyline_of_time(t);
                cp.pss = [xss;yss;alphass;xdotss;ydotss;alphadotss];
                pd_dotdot = [xdotdotss; ydotdotss; alphadotdotss];
                
                pdiff(1:2,1) = cp.pss(1:2,1)-xs(1:2,1);
                %pdiff(3,1) = angdiff(xs(3,1), cp.pss(3,1));
                pdiff(3,1) = cp.pss(3,1)-xs(3,1);
                pdiff(4:6,1) = cp.pss(4:6,1)-xs(7:9,1);

                u_2 = pd_dotdot + cp.K*pdiff;
                u = (MFIKs.')*(M_bars*u_2 + C_bars*qdot(1:3,1));
                u_zoh = zoh_function(t,u);
                qdotdot = [eye(6),zeros(6,3)]*pinv([Ms,Js.'; Js, zeros(3,3)])*[Es*u_zoh + tau_friction + D_vec - Cs*qdot; -Jdots*qdot];
                                
            otherwise
                disp('This goal_Flag does not exist (xdot_dyn_otbotCTC)')
                disp('Simulating with a FIX point X=2 Y=2 Alpha = 0')
                cp.pss = [2,2,0,0,0,0]';
                
                pdiff(1:2,1) = cp.pss(1:2,1)-xs(1:2,1);
                %pdiff(3,1) = angdiff(xs(3,1), cp.pss(3,1));
                pdiff(3,1) = cp.pss(3,1)-xs(3,1);
                pdiff(4:6,1) = cp.pss(4:6,1)-xs(7:9,1);

                u_2 = cp.K*pdiff;
                u = (MFIKs.')*(M_bars*u_2 + C_bars*qdot(1:3,1));
                u_zoh = zoh_function(t,u);
                qdotdot = [eye(6),zeros(6,3)]*pinv([Ms,Js.'; Js, zeros(3,3)])*[Es*u_zoh + tau_friction + D_vec - Cs*qdot; -Jdots*qdot];
                
        end
        
    case 'CTC_PP' % This secction used to be a copy of LQR but now it is included the integrative term
        switch goal_Flag
            case 'FIX'
                pdiff(1:2,1) = cp.pss(1:2,1)-xs(1:2,1);
                %pdiff(3,1) = angdiff(xs(3,1), cp.pss(3,1));
                pdiff(3,1) = cp.pss(3,1)-xs(3,1);
                pdiff(4:6,1) = cp.pss(4:6,1)-xs(7:9,1);
                
                if strcmp(u_IntFlag,'YES')
                    I_k = Int_Vec(1,1:3)' + (t-Int_Vec(1,7))/2*(Int_Vec(1,4:6)' + pdiff(1:3,1));
                    u_2 = cp.K*[I_k;pdiff];
                    u = (MFIKs.')*(M_bars*u_2 + C_bars*qdot(1:3,1));
                    u_zoh = zoh_function(t,u);
                    qdotdot = [eye(6),zeros(6,3)]*pinv([Ms,Js.'; Js, zeros(3,3)])*[Es*u_zoh + tau_friction + D_vec - Cs*qdot; -Jdots*qdot];
                    
                    Int_Vec(1,1:3) = I_k';          % Updating Integral value
                    Int_Vec(1,4:6) = pdiff(1:3,1)'; % Updating error value
                    Int_Vec(1,7) = t;               % Updating time value
                elseif strcmp(u_IntFlag,'NO')
                    u_2 = cp.K*pdiff;
                    u = (MFIKs.')*(M_bars*u_2 + C_bars*qdot(1:3,1));
                    u_zoh = zoh_function(t,u);
                    qdotdot = [eye(6),zeros(6,3)]*pinv([Ms,Js.'; Js, zeros(3,3)])*[Es*u_zoh + tau_friction + D_vec - Cs*qdot; -Jdots*qdot];
                else
                    disp('This u_IntFlag does not exist runing the simulation with standart PD controller')
                    u_2 = cp.K*pdiff;
                    u = (MFIKs.')*(M_bars*u_2 + C_bars*qdot(1:3,1));
                    u_zoh = zoh_function(t,u);
                    qdotdot = [eye(6),zeros(6,3)]*pinv([Ms,Js.'; Js, zeros(3,3)])*[Es*u_zoh + tau_friction + D_vec - Cs*qdot; -Jdots*qdot];
                end
                
%                 u_2 = cp.K*pdiff;
%                 u = (MFIKs.')*(M_bars*u_2 + C_bars*qdot(1:3,1));        
%                 qdotdot = [eye(6),zeros(6,3)]*pinv([Ms,Js.'; Js, zeros(3,3)])*[Es*u + tau_friction + D_vec - Cs*qdot; -Jdots*qdot];
                                
            case 'CIRCLE'
                [xss,yss,alphass,xdotss,ydotss,alphadotss,xdotdotss,ydotdotss,alphadotdotss] = TD_circle_of_time_XYA(t);
                cp.pss = [xss;yss;alphass;xdotss;ydotss;alphadotss];
                pd_dotdot = [xdotdotss; ydotdotss; alphadotdotss];
                
                pdiff(1:2,1) = cp.pss(1:2,1)-xs(1:2,1);
                %pdiff(3,1) = angdiff(xs(3,1), cp.pss(3,1));
                pdiff(3,1) = cp.pss(3,1)-xs(3,1);
                pdiff(4:6,1) = cp.pss(4:6,1)-xs(7:9,1);
                
                if strcmp(u_IntFlag,'YES')
                    I_k = Int_Vec(1,1:3)' + (t-Int_Vec(1,7))/2*(Int_Vec(1,4:6)' + pdiff(1:3,1));
                    u_2 = pd_dotdot + cp.K*[I_k;pdiff];
                    u = (MFIKs.')*(M_bars*u_2 + C_bars*qdot(1:3,1));
                    u_zoh = zoh_function(t,u);
                    qdotdot = [eye(6),zeros(6,3)]*pinv([Ms,Js.'; Js, zeros(3,3)])*[Es*u_zoh + tau_friction + D_vec - Cs*qdot; -Jdots*qdot];
                    
                    Int_Vec(1,1:3) = I_k';          % Updating Integral value
                    Int_Vec(1,4:6) = pdiff(1:3,1)'; % Updating error value
                    Int_Vec(1,7) = t;               % Updating time value
                elseif strcmp(u_IntFlag,'NO')
                    u_2 = pd_dotdot + cp.K*pdiff;
                    u = (MFIKs.')*(M_bars*u_2 + C_bars*qdot(1:3,1));
                    u_zoh = zoh_function(t,u);
                    qdotdot = [eye(6),zeros(6,3)]*pinv([Ms,Js.'; Js, zeros(3,3)])*[Es*u_zoh + tau_friction + D_vec - Cs*qdot; -Jdots*qdot];
                else
                    disp('This u_IntFlag does not exist runing the simulation with standart PD controller')
                    u_2 = pd_dotdot + cp.K*pdiff;
                    u = (MFIKs.')*(M_bars*u_2 + C_bars*qdot(1:3,1));
                    u_zoh = zoh_function(t,u);
                    qdotdot = [eye(6),zeros(6,3)]*pinv([Ms,Js.'; Js, zeros(3,3)])*[Es*u_zoh + tau_friction + D_vec - Cs*qdot; -Jdots*qdot];
                end
                
%                 u_2 = pd_dotdot + cp.K*pdiff;
%                 u = (MFIKs.')*(M_bars*u_2 + C_bars*qdot(1:3,1));        
%                 qdotdot = [eye(6),zeros(6,3)]*pinv([Ms,Js.'; Js, zeros(3,3)])*[Es*u + tau_friction + D_vec - Cs*qdot; -Jdots*qdot];
                                
            case 'POLILINE'
                [xss,yss,alphass,xdotss,ydotss,alphadotss,xdotdotss,ydotdotss,alphadotdotss] = TD_polyline_of_time(t);
                cp.pss = [xss;yss;alphass;xdotss;ydotss;alphadotss];
                pd_dotdot = [xdotdotss; ydotdotss; alphadotdotss];
                
                pdiff(1:2,1) = cp.pss(1:2,1)-xs(1:2,1);
                %pdiff(3,1) = angdiff(xs(3,1), cp.pss(3,1));
                pdiff(3,1) = cp.pss(3,1)-xs(3,1);
                pdiff(4:6,1) = cp.pss(4:6,1)-xs(7:9,1);
                
                if strcmp(u_IntFlag,'YES')
                    I_k = Int_Vec(1,1:3)' + (t-Int_Vec(1,7))/2*(Int_Vec(1,4:6)' + pdiff(1:3,1));
                    u_2 = pd_dotdot + cp.K*[I_k;pdiff];
                    u = (MFIKs.')*(M_bars*u_2 + C_bars*qdot(1:3,1));
                    u_zoh = zoh_function(t,u);
                    qdotdot = [eye(6),zeros(6,3)]*pinv([Ms,Js.'; Js, zeros(3,3)])*[Es*u_zoh + tau_friction + D_vec - Cs*qdot; -Jdots*qdot];
                    
                    Int_Vec(1,1:3) = I_k';          % Updating Integral value
                    Int_Vec(1,4:6) = pdiff(1:3,1)'; % Updating error value
                    Int_Vec(1,7) = t;               % Updating time value
                elseif strcmp(u_IntFlag,'NO')
                    u_2 = pd_dotdot + cp.K*pdiff;
                    u = (MFIKs.')*(M_bars*u_2 + C_bars*qdot(1:3,1));
                    u_zoh = zoh_function(t,u);
                    qdotdot = [eye(6),zeros(6,3)]*pinv([Ms,Js.'; Js, zeros(3,3)])*[Es*u_zoh + tau_friction + D_vec - Cs*qdot; -Jdots*qdot];
                else
                    disp('This u_IntFlag does not exist runing the simulation with standart PD controller')
                    u_2 = pd_dotdot + cp.K*pdiff;
                    u = (MFIKs.')*(M_bars*u_2 + C_bars*qdot(1:3,1));
                    u_zoh = zoh_function(t,u);
                    qdotdot = [eye(6),zeros(6,3)]*pinv([Ms,Js.'; Js, zeros(3,3)])*[Es*u_zoh + tau_friction + D_vec - Cs*qdot; -Jdots*qdot];
                end

%                 u_2 = pd_dotdot + cp.K*pdiff;
%                 u = (MFIKs.')*(M_bars*u_2 + C_bars*qdot(1:3,1));        
%                 qdotdot = [eye(6),zeros(6,3)]*pinv([Ms,Js.'; Js, zeros(3,3)])*[Es*u + tau_friction + D_vec - Cs*qdot; -Jdots*qdot];
                                
            otherwise
                disp('This goal_Flag does not exist (xdot_dyn_otbotCTC)')
                disp('Simulating with a FIX point X=2 Y=2 Alpha = 0 with standart PD CTC')
                cp.pss = [2,2,0,0,0,0]';
                
                pdiff(1:2,1) = cp.pss(1:2,1)-xs(1:2,1);
                %pdiff(3,1) = angdiff(xs(3,1), cp.pss(3,1));
                pdiff(3,1) = cp.pss(3,1)-xs(3,1);
                pdiff(4:6,1) = cp.pss(4:6,1)-xs(7:9,1);

                u_2 = cp.K*pdiff;
                u = (MFIKs.')*(M_bars*u_2 + C_bars*qdot(1:3,1));
                u_zoh = zoh_function(t,u);
                qdotdot = [eye(6),zeros(6,3)]*pinv([Ms,Js.'; Js, zeros(3,3)])*[Es*u_zoh + tau_friction + D_vec - Cs*qdot; -Jdots*qdot];
                                
        end
        
    otherwise
        disp('WARNING THIS FLAG DOES NOT EXIST (xdot_dyn_otbotCTC)')
        disp('Simulation with CTE torques will be launched')
        qdotdot = [eye(6),zeros(6,3)]*pinv([Ms,Js.'; Js, zeros(3,3)])*[Es*u_cte + tau_friction + D_vec - Cs*qdot; -Jdots*qdot];
        
end
xdot=[qdot; qdotdot];

% global qdotdot_gvector
% qdotdot_gvector = [qdotdot_gvector; qdotdot'];
end





