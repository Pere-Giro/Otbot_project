%% Seccio 1
CN=' Infinity_NFDPFD_Test3_01'; % Name the image (Warning: avoid dots in the name if EPS save)

Flag_EPS = 'YES'; % Flag to choose if the images will be saves in eps or png)
                % (Flag_EPS == 'YES' > Images saved in EPS)
                % (Flag_EPS == 'NO'  > Images saved in png)

if strcmp(KinEnFlag,'NO') && strcmp(UvecFlag,'NO') && strcmp(ErrorFlag,'NO')
    for i=1:12
        if i==1
            names='1 - x';
        elseif i==2
            names='2 - y';
        elseif i==3
            names='3 - alpha';
        elseif i==4
            names='4 - varphi_r';
        elseif i==5
            names='5 - varphi_l';
        elseif i==6
            names='6 - varphi_p';
        elseif i==7
            names='7 - xdot';
        elseif i==8
            names='8 - ydot';
        elseif i==9
            names='9 - alphadot';
        elseif i==10
            names='10 - varphidot_r';
        elseif i==11
            names='11 - varphidot_l';
        elseif i==12
            names='12 - varphidot_p';
        end
        switch Flag_EPS
            case 'YES'
                saveas(figure(i),strcat(names,CN,'.eps'),'epsc');
            case 'NO'
                saveas(figure(i),strcat(names,CN,'.png'));
            otherwise
                disp('Error this Flag_EPS does not exist')
        end  
    end
        
elseif strcmp(KinEnFlag,'YES') && strcmp(UvecFlag,'NO') && strcmp(ErrorFlag,'NO')
    for i=1:13
        if i==1
            names='1 - x';
        elseif i==2
            names='2 - y';
        elseif i==3
            names='3 - alpha';
        elseif i==4
            names='4 - varphi_r';
        elseif i==5
            names='5 - varphi_l';
        elseif i==6
            names='6 - varphi_p';
        elseif i==7
            names='7 - xdot';
        elseif i==8
            names='8 - ydot';
        elseif i==9
            names='9 - alphadot';
        elseif i==10
            names='10 - varphidot_r';
        elseif i==11
            names='11 - varphidot_l';
        elseif i==12
            names='12 - varphidot_p';
        elseif i==13
            names='13 - Kinetic_Energy';
        end
        switch Flag_EPS
            case 'YES'
                saveas(figure(i),strcat(names,CN),'epsc');
            case 'NO'
                saveas(figure(i),strcat(names,CN,'.png'));
            otherwise
                disp('Error this Flag_EPS does not exist')
        end
    end
elseif strcmp(KinEnFlag,'NO') && strcmp(UvecFlag,'YES') && strcmp(ErrorFlag,'NO')
    for i=1:14
        if i==1
            names='1 - x';
        elseif i==2
            names='2 - y';
        elseif i==3
            names='3 - alpha';
        elseif i==4
            names='4 - varphi_r';
        elseif i==5
            names='5 - varphi_l';
        elseif i==6
            names='6 - varphi_p';
        elseif i==7
            names='7 - xdot';
        elseif i==8
            names='8 - ydot';
        elseif i==9
            names='9 - alphadot';
        elseif i==10
            names='10 - varphidot_r';
        elseif i==11
            names='11 - varphidot_l';
        elseif i==12
            names='12 - varphidot_p';
        elseif i==13
            names='13 - taus wheels';
        elseif i==14
            names='14 - tau pivot';
        end
        switch Flag_EPS
            case 'YES'
                saveas(figure(i),strcat(names,CN),'epsc');
            case 'NO'
                saveas(figure(i),strcat(names,CN,'.png'));
            otherwise
                disp('Error this Flag_EPS does not exist')
        end
    end
elseif strcmp(KinEnFlag,'YES') && strcmp(UvecFlag,'YES') && strcmp(ErrorFlag,'NO')
    for i=1:15
        if i==1
            names='1 - x';
        elseif i==2
            names='2 - y';
        elseif i==3
            names='3 - alpha';
        elseif i==4
            names='4 - varphi_r';
        elseif i==5
            names='5 - varphi_l';
        elseif i==6
            names='6 - varphi_p';
        elseif i==7
            names='7 - xdot';
        elseif i==8
            names='8 - ydot';
        elseif i==9
            names='9 - alphadot';
        elseif i==10
            names='10 - varphidot_r';
        elseif i==11
            names='11 - varphidot_l';
        elseif i==12
            names='12 - varphidot_p';
        elseif i==13
            names='13 - taus wheels';
        elseif i==14
            names='14 - tau pivot';
        elseif i==15
            names='15 - Kinetic_Energy';
        end
        switch Flag_EPS
            case 'YES'
                saveas(figure(i),strcat(names,CN),'epsc');
            case 'NO'
                saveas(figure(i),strcat(names,CN,'.png'));
            otherwise
                disp('Error this Flag_EPS does not exist')
        end
    end
elseif strcmp(KinEnFlag,'NO') && strcmp(UvecFlag,'NO') && strcmp(ErrorFlag,'YES')
    for i=1:20
        if i==1
            names='1 - x';
        elseif i==2
            names='2 - y';
        elseif i==3
            names='3 - alpha';
        elseif i==4
            names='4 - varphi_r';
        elseif i==5
            names='5 - varphi_l';
        elseif i==6
            names='6 - varphi_p';
        elseif i==7
            names='7 - xdot';
        elseif i==8
            names='8 - ydot';
        elseif i==9
            names='9 - alphadot';
        elseif i==10
            names='10 - varphidot_r';
        elseif i==11
            names='11 - varphidot_l';
        elseif i==12
            names='12 - varphidot_p';
        elseif i==13
            names='13 - Error_X';
        elseif i==14
            names='14 - Error_Y';
        elseif i==15
            names='15 - Error_Alpha';
        elseif i==16
            names='16 - Error_Xdot';
        elseif i==17
            names='17 - Error_Ydot';    
        elseif i==18
            names='18 - Error_Alphadot';
        elseif i==19
            names='19 - Error_xy';
        elseif i==20
            names='20 - Error_dxdy';
        end
        switch Flag_EPS
            case 'YES'
                saveas(figure(i),strcat(names,CN),'epsc');
            case 'NO'
                saveas(figure(i),strcat(names,CN,'.png'));
            otherwise
                disp('Error this Flag_EPS does not exist')
        end
    end
elseif strcmp(KinEnFlag,'YES') && strcmp(UvecFlag,'NO') && strcmp(ErrorFlag,'YES')
    for i=1:21
        if i==1
            names='1 - x';
        elseif i==2
            names='2 - y';
        elseif i==3
            names='3 - alpha';
        elseif i==4
            names='4 - varphi_r';
        elseif i==5
            names='5 - varphi_l';
        elseif i==6
            names='6 - varphi_p';
        elseif i==7
            names='7 - xdot';
        elseif i==8
            names='8 - ydot';
        elseif i==9
            names='9 - alphadot';
        elseif i==10
            names='10 - varphidot_r';
        elseif i==11
            names='11 - varphidot_l';
        elseif i==12
            names='12 - varphidot_p';
        elseif i==13
            names='13 - Kinetic_Energy';
        elseif i==14
            names='14 - Error_X';
        elseif i==15
            names='15 - Error_Y';
        elseif i==16
            names='16 - Error_Alpha';
        elseif i==17
            names='17 - Error_Xdot';
        elseif i==18
            names='18 - Error_Ydot';    
        elseif i==19
            names='19 - Error_Alphadot';
        elseif i==20
            names='20 - Error_xy';
        elseif i==21
            names='21 - Error_dxdy';
        end
        switch Flag_EPS
            case 'YES'
                saveas(figure(i),strcat(names,CN),'epsc');
            case 'NO'
                saveas(figure(i),strcat(names,CN,'.png'));
            otherwise
                disp('Error this Flag_EPS does not exist')
        end
    end
elseif strcmp(KinEnFlag,'NO') && strcmp(UvecFlag,'YES') && strcmp(ErrorFlag,'YES')
    for i=1:22
        if i==1
            names='1 - x';
        elseif i==2
            names='2 - y';
        elseif i==3
            names='3 - alpha';
        elseif i==4
            names='4 - varphi_r';
        elseif i==5
            names='5 - varphi_l';
        elseif i==6
            names='6 - varphi_p';
        elseif i==7
            names='7 - xdot';
        elseif i==8
            names='8 - ydot';
        elseif i==9
            names='9 - alphadot';
        elseif i==10
            names='10 - varphidot_r';
        elseif i==11
            names='11 - varphidot_l';
        elseif i==12
            names='12 - varphidot_p';
        elseif i==13
            names='13 - taus wheels';
        elseif i==14
            names='14 - tau pivot';
        elseif i==15
            names='15 - Error_X';
        elseif i==16
            names='16 - Error_Y';
        elseif i==17
            names='17 - Error_Alpha';
        elseif i==18
            names='18 - Error_Xdot';
        elseif i==19
            names='19 - Error_Ydot';    
        elseif i==20
            names='20 - Error_Alphadot';
        elseif i==21
            names='21 - Error_xy';
        elseif i==22
            names='22 - Error_dxdy';
        end
        switch Flag_EPS
            case 'YES'
                saveas(figure(i),strcat(names,CN),'epsc');
            case 'NO'
                saveas(figure(i),strcat(names,CN,'.png'));
            otherwise
                disp('Error this Flag_EPS does not exist')
        end
    end
elseif strcmp(KinEnFlag,'YES') && strcmp(UvecFlag,'YES') && strcmp(ErrorFlag,'YES')
    for i=1:23
        if i==1
            names='1 - x';
        elseif i==2
            names='2 - y';
        elseif i==3
            names='3 - alpha';
        elseif i==4
            names='4 - varphi_r';
        elseif i==5
            names='5 - varphi_l';
        elseif i==6
            names='6 - varphi_p';
        elseif i==7
            names='7 - xdot';
        elseif i==8
            names='8 - ydot';
        elseif i==9
            names='9 - alphadot';
        elseif i==10
            names='10 - varphidot_r';
        elseif i==11
            names='11 - varphidot_l';
        elseif i==12
            names='12 - varphidot_p';
        elseif i==13
            names='13 - taus wheels';
        elseif i==14
            names='14 - tau pivot';
        elseif i==15
            names='15 - Kinetic_Energy';
        elseif i==16
            names='16 - Error_X';
        elseif i==17
            names='17 - Error_Y';
        elseif i==18
            names='18 - Error_Alpha';
        elseif i==19
            names='19 - Error_Xdot';
        elseif i==20
            names='20 - Error_Ydot';    
        elseif i==21
            names='21 - Error_Alphadot';
        elseif i==22
            names='22 - Error_xy';
        elseif i==23
            names='23 - Error_dxdy';
        end
        switch Flag_EPS
            case 'YES'
                saveas(figure(i),strcat(names,CN),'epsc');
            case 'NO'
                saveas(figure(i),strcat(names,CN,'.png'));
            otherwise
                disp('Error this Flag_EPS does not exist')
        end
    end
    
end


