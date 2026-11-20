%% Symbolic kinematics + top-view simulation
%  Mechanism : parallelogram four-bar door
%  Analysis  : position / velocity / acceleration only (no forces)
%  View      : top view    Input     : motor angle = Sine Wave (Amp 0.7 rad, Freq 0.5 rad/s, Phase 3*pi/2)

clear; clc; close all;
% motor input: Sine Wave (time based)  theta_m(t) = Amp*sin(Freq*t + Phase)   [rad]
Amp   = 0.7;                 % amplitude (rad)-> motor swings +/-0.7 rad
Freq  = 0.5;                 % frequency (rad/s)-> period 2*pi/0.5 = 12.566 s
Phase = 3*pi/2;              % phase (rad)         
N30 = 30; N15 = 15;          
T_cycle = 2*pi/Freq;         

%% 1) DIMENSIONS (mm)
O2 = [125.788  -9.433];    % driving-rod shaft (gear Z15)        
O4 = [ 41.577  -5.223];    % Body26 pin on floor   
A0 = [ 36.793  -9.433];    % door pin on driving rod   (closed)                 
B0 = [-47.417  -5.223];    % door pin on Body26        (closed)
M  = [124.257 -28.318];    % motor shaft (gear Z30)

r1 = norm(O4-O2);  r2 = norm(A0-O2);  r3 = norm(B0-A0);  r4 = norm(B0-O4); %create link
th1 = atan2(O4(2)-O2(2), O4(1)-O2(1));
pC  = [30.4775 0.4880];      % door-panel centre
p   = pC - A0;               % fixed vector  A -> P  on the door เพราะประตูไม่หมุนตอนขยับ
fprintf('r1=%.3f  r2=%.3f  r3=%.3f  r4=%.3f mm   theta1=%.3f deg\n', r1, r2, r3, r4, rad2deg(th1));

%% 2) SYMBOLIC ANALYSIS : general four-bar: loop R2 + R3 - R4 - R1 = 0, differentiate symbolically
syms t real
syms R1 R2 R3 R4 TH1 real
syms q2(t) q3(t) q4(t) %Zeta ใช้ diff
loop = [R2*cos(q2) + R3*cos(q3) - R4*cos(q4) - R1*cos(TH1);      
        R2*sin(q2) + R3*sin(q3) - R4*sin(q4) - R1*sin(TH1)];     %แยกแถว cos;x sin;y เพื่อกำหนดว่า 4 linkนี้ติดกัน ถ้าวนloopแล้วระยะรวมกันจะ =0
syms Q2 Q3 Q4 W2 W3 W4 AL2 AL3 AL4 real  %Q=Zetaแบบไม่ติด t W=omega AL=Alpha ผลจากการdif q(t)
plain = @(e) formula(subs(subs(subs(e, ...
        [diff(q2,t,2) diff(q3,t,2) diff(q4,t,2)], [AL2 AL3 AL4]), ...
        [diff(q2,t)   diff(q3,t)   diff(q4,t)  ], [W2 W3 W4]), ...
        [q2 q3 q4], [Q2 Q3 Q4]));
Sv = solve(plain(diff(loop,t))   == 0, [W3 W4]);   %หาความเร็วและความเร่งแบบไม่ติด t
Sa = solve(plain(diff(loop,t,2)) == 0, [AL3 AL4]);
w3_gen = simplify(Sv.W3);, w4_gen = simplify(Sv.W4);    %จัดรูป
a3_gen = simplify(Sa.AL3);, a4_gen = simplify(Sa.AL4);

% parallelogram (R3 = R1, R4 = R2): theta3 = theta1, theta4 = theta2 สี่เหลี่ยมด้านขนาน link  ตรงข้ามเท่ากันเป็นคู่
par_o = [R3 R4 Q3 Q4];  par_n = [R1 R2 TH1 Q2];
loop_check = simplify(subs(plain(loop), par_o, par_n));     % -> [0;0]
w3_par = simplify(subs(w3_gen, par_o, par_n));              % -> 0
w4_par = simplify(subs(w4_gen, par_o, par_n));              % -> W2
a3_par = simplify(subs(subs(a3_gen, par_o, par_n), [W3 W4], [w3_par w4_par]));   % -> 0
a4_par = simplify(subs(subs(a4_gen, par_o, par_n), [W3 W4], [w3_par w4_par]));   % -> AL2

% input motion (harmonic, fitted to the video) and door point P  มอเตอร์เป็น sine wave ผ่านเฟือง 30:15 แล้วหาตำแหน่งจุด P บนประตู
syms AMP FRQ PHS TH20 real %TH20 = มุม rod ตอนเริ่ม 180 deg
thm_s = AMP*sin(FRQ*t + PHS);                               % motor angle (sine input) | มุมมอเตอร์เป็นคลื่น sine
thm0  = subs(thm_s, t, 0);                                  % motor angle at t = 0 (door closed) | มุมมอเตอร์ตอนเริ่ม (ประตูปิด) = -0.7 rad
th2_s = TH20 - sym(N30)/N15*(thm_s - thm0);                 % gear: d(theta2) = -(N30/N15) d(theta_m) | ผ่านเฟือง: rod หมุน 2 เท่าของมอเตอร์ และหมุนสวนทาง
w2_s  = diff(th2_s, t);                                     % omega & alpha ของ rod
a2_s  = diff(th2_s, t, 2);   % diff 2 ครั้ง = ความเร่งเชิงมุม
syms px py real   % px, py = เวกเตอร์ p จาก A ไป P (ค่าคงที่)
rP_s = [R2*cos(th2_s) + px;  R2*sin(th2_s) + py];          % relative to O2 | ตำแหน่ง P = ตำแหน่ง A + p
vP_s = diff(rP_s, t);   % ความเร็วประตู (diff 1 ครั้ง)
aP_s = diff(rP_s, t, 2);   % ความเร่งประตู (diff 2 ครั้ง)
%disp('theta_m(t) ='); pretty(thm_s)
%disp('theta2(t) ='); pretty(simplify(th2_s))
%disp('v_P(t) =');    pretty(simplify(vP_s))
%disp('a_P(t) =');    pretty(simplify(aP_s))

num_s = [R2 px py AMP FRQ PHS TH20];
num_v = [r2 p(1) p(2) Amp Freq Phase pi];
f_th2 = matlabFunction(subs(th2_s, num_s, num_v), 'Vars', t);
f_w2  = matlabFunction(subs(w2_s,  num_s, num_v), 'Vars', t);
f_a2  = matlabFunction(subs(a2_s,  num_s, num_v), 'Vars', t);
f_rP  = matlabFunction(subs(rP_s,  num_s, num_v), 'Vars', t);
f_vP  = matlabFunction(subs(vP_s,  num_s, num_v), 'Vars', t);
f_aP  = matlabFunction(subs(aP_s,  num_s, num_v), 'Vars', t);

%คำนวณค่าที่จะเอา plot
t_end = 13;                                         % s, stop time เท่ากับใน Simscape
tt  = linspace(0, t_end, 1301);
TH2 = f_th2(tt);  W2v = f_w2(tt);  A2v = f_a2(tt);
RP  = f_rP(tt) + O2.';  VP = f_vP(tt);  AP = f_aP(tt);
fprintf('rod swing = %.2f deg (theta2: 180 -> %.2f deg), period = %.3f s\n', rad2deg(max(TH2)-min(TH2)), rad2deg(min(TH2)), T_cycle);
fprintf('peak omega2 = %.4f rad/s | max|vP| = %.2f mm/s | max|aP| = %.2f mm/s^2\n', ...
        max(abs(W2v)), max(vecnorm(VP)), max(vecnorm(AP)));

% ตำแหน่งขอบประตู (เหมือนกราฟ Simscape): ประตูไม่หมุน ทุกจุดเลื่อนเท่ากับจุด A
yEdge  = 0.488;                                     % y ของจุดขอบ (กึ่งกลางความหนาแผ่นประตู)
pRight = [114.688; yEdge];                          % ขอบขวาประตู ตอนปิด
pLeft  = [-53.733; yEdge];                          % ขอบซ้ายประตู ตอนปิด
Avec = O2.' + r2*[cos(TH2); sin(TH2)];              % จุด A ทุกเวลา (2xN)
dA   = Avec - A0.';                                 % ระยะที่ประตูเลื่อนจากตอนปิด
RE   = pRight + dA;                                 % ขอบขวา [x; y]
LE   = pLeft  + dA;                                 % ขอบซ้าย [x; y]
rodA = rad2deg(pi - TH2);                           % มุม rod นับจากตอนปิด (0 -> 160.4 deg)

%% 2b) RESULT PLOTS
figR = figure('Name','Door kinematics - results','Color','w','Position',[80 60 1200 760]);
tl   = tiledlayout(figR,3,2,'TileSpacing','compact','Padding','compact');

pa(1) = nexttile(tl,1);                             % ขอบขวาประตู
plot(pa(1), tt, RE(1,:), tt, RE(2,:), 'LineWidth',1.4);
legend(pa(1),{'x (mm)','y (mm)'},'Location','northwest','AutoUpdate','off');
ylabel(pa(1),'Position (mm)'); title(pa(1),'Position at the Right Edge of the Door'); ylim(pa(1),[-100 350]);

pa(2) = nexttile(tl,3);                             % ขอบซ้ายประตู
plot(pa(2), tt, LE(1,:), tt, LE(2,:), 'LineWidth',1.4);
legend(pa(2),{'x (mm)','y (mm)'},'Location','northwest','AutoUpdate','off');
ylabel(pa(2),'Position (mm)'); title(pa(2),'Position at the Left Edge of the Door'); ylim(pa(2),[-100 190]);

pa(3) = nexttile(tl,5);                             % มุม rod
plot(pa(3), tt, rodA, 'LineWidth',1.4);
ylabel(pa(3),'Angle (deg)'); title(pa(3),'Rod Angle'); ylim(pa(3),[-50 200]);

pa(4) = nexttile(tl,2);                             % กราฟ มุม
plot(pa(4), tt, rad2deg(TH2), 'LineWidth',1.5); hold(pa(4),'on');
plot(pa(4), tt, rad2deg(th1)*ones(size(tt)), '--');
legend(pa(4),{'\theta_2 = \theta_4','\theta_3 = \theta_1'},'Location','southeast','AutoUpdate','off');
ylabel(pa(4),'deg'); title(pa(4),'\theta_2 = \theta_4 ,  \theta_3 = \theta_1');

pa(5) = nexttile(tl,4);                             % กราฟomega, alpha
plot(pa(5), tt, W2v, tt, A2v, tt, -W2v/2, ':', 'LineWidth',1.4);
legend(pa(5),{'\omega_2 (rad/s)','\alpha_2 (rad/s^2)','\omega_m (rad/s)'},'Location','best','FontSize',7,'AutoUpdate','off');
title(pa(5),'\omega_4=\omega_2, \alpha_4=\alpha_2, \omega_3=\alpha_3=0');

pa(6) = nexttile(tl,6);                             % กราฟ|v|, |a| ของประตู
plot(pa(6), tt, vecnorm(VP), tt, vecnorm(AP), 'LineWidth',1.4);
legend(pa(6),{'|v_P| (mm/s)','|a_P| (mm/s^2)'},'Location','north','FontSize',7,'AutoUpdate','off');
title(pa(6),'Door (all points identical)');

for k = 1:6
    grid(pa(k),'on'); xlim(pa(k),[0 t_end]); hold(pa(k),'on');
    yl = ylim(pa(k)); hCur(k) = plot(pa(k),[0 0],yl,'k-','LineWidth',1); ylim(pa(k),yl); %#ok<SAGROW>  เส้นบอกเวลา
end
xlabel(pa(3),'Time (s)'); xlabel(pa(6),'Time (s)');
linkaxes(pa,'x');
% exportgraphics(figR,'door_results.png');          % เอา % ออกถ้าจะเซฟเป็นรูป

%% 3) FIGURE LAYOUT 
fig = figure('Name','Door mechanism - top view','Color','w','Position',[60 60 1250 640]);   % หน้าต่าง animation
ax  = axes('Parent',fig,'Position',[0.05 0.12 0.92 0.82]);   % แกนวาดภาพกลไก กินพื้นที่เกือบทั้งหน้าต่าง
hold(ax,'on'); axis(ax,'equal'); grid(ax,'on'); box(ax,'on');   % วาดซ้อนได้ / สเกล x=y (วงกลมไม่เพี้ยน) / เส้นตาราง / กรอบ
xlim(ax,[-75 295]); ylim(ax,[-60 105]); view(ax,2);   % ขอบเขตที่แสดง (mm) และมองแบบ 2D จากด้านบน
xlabel(ax,'X (mm)'); ylabel(ax,'Y (mm)');
set(ax,'GridAlpha',0.12,'Layer','top');   % เส้นตารางจางๆ และวาดทับชิ้นส่วน

%Colorrrr  
C.floor = [0.77 0.78 0.79];  C.wall  = [0.69 0.50 0.16];  C.door  = [0.23 0.23 0.25];
C.rod   = [1 0.6667 1];  C.motor = [0.59 0.59 0.61];  C.z30   = [0.19 0.23 0.59];
C.z15   = [0.77 0.21 0.15];  C.brk   = [0.92 0.92 0.90];  C.pin   = [0.10 0.10 0.10];

% STATIC PARTS วาดเป็นชิ้นขึ้นมา ชิ้นที่อยู่กับที่rectPts(x0, x1, y0, y1)/ circPts(จุดศูนย์กลาง, รัศมี, จำนวนจุด)/ lugPts(จุดศูนย์กลาง, รัศมี, y ของแผ่น)
part(ax, rectPts(-68.733,145.098,-53.644,0.488), C.floor, 0, 1);              % floor plate | แผ่นพื้น
part(ax, circPts(M,20.147,80), C.floor*0.92, 0.05, 1);                        % motor recess in floor | หลุมฐานมอเตอร์บนพื้น
part(ax, circPts(M,15.0,80), C.motor, 2, 0.45);                               % motor (semi-transparent -> see Z30) | ตัวมอเตอร์ (โปร่งแสง ให้เห็นเฟืองน้ำเงินข้างใต้)
part(ax, circPts(M,4.0,40),  C.motor*0.8, 2.1, 0.8);                          % motor shaft | แกนมอเตอร์
part(ax, rectPts(116.577,134.998,-4.0,-1.012), C.brk, 5, 1);                  % bearing bracket flange | ฐาน bracket ยึดแกน rod
part(ax, lugPts(O2,5.2105,-4.0), C.brk, 5, 1);                                %   ... and lug around O2 | หู bracket รอบจุด O2
part(ax, rectPts(-68.733,145.098,-1.012,1.988), C.wall, 7, 0.92);             % wall (top beam) | ผนัง (คานบน) อยู่ชั้นบนสุด

% MOVING PARTS (each one inside its own hgtransform; จัดเป็น groupๆ รับคำสั่งทีเดัยว หมุนไปด้วยกัน) 
% Link green (rocker O4-B, below the floor -> drawn semi-transparent)  link เขียว (Body26) อยู่ใต้พื้น เลยวาดโปร่งแสง
LG = hgtransform('Parent',ax);   % กลุ่มของ link O4-B
part(LG, stadiumPts(O4,B0,3.1579), C.rod, 1, 0.55);   % แท่งปลายมนจาก O4 ไป B
part(LG, circPts(O4,1.0,20), C.pin, 1.1, 0.8);  part(LG, circPts(B0,1.0,20), C.pin, 1.1, 0.8);   % รูหมุดที่ O4 และ B

% Blue gear on motor  เฟืองน้ำเงิน Z30 บนมอเตอร์
gdir = atan2(O2(2)-M(2), O2(1)-M(1));   % มุมจากมอเตอร์ไปหา O2 ใช้จัดฟันให้ขบกันพอดี
BG = hgtransform('Parent',ax);   % กลุ่มของเฟือง Z30
part(BG, gearPts(M,30,13.4737,11.6573,gdir), C.z30, 1.5, 1);   % เฟือง 30 ฟัน รัศมีปลายฟัน/โคนฟัน จาก STEP
part(BG, circPts(M,6.3158,40), C.z30*1.2, 1.6, 1);   % ดุมกลางเฟือง
part(BG, circPts(M+[7.3125 0.9059],1.0526,16), C.pin, 1.7, 1);   % marker holes (show rotation) | รูเล็กไว้ดูว่าเฟืองหมุน
part(BG, circPts(M+[-6.5792 3.3179],1.0526,16), C.pin, 1.7, 1);

% Red gear on driving-rod shaft  เฟืองแดง Z15 บนแกน rod
RG = hgtransform('Parent',ax);   % กลุ่มของเฟือง Z15
part(RG, gearPts(O2,15,7.1579,5.3415,gdir+pi+pi/15), C.z15, 3, 1);   % เฟือง 15 ฟัน เลื่อนครึ่งฟัน (pi/15) ให้ร่องฟันรับฟันของ Z30
part(RG, circPts(O2,3.1579,30), C.z15*0.7, 3.1, 1);   % รูเพลา

% driving rod: U-shaped tube (R 2.105) + vertical hubs (R 4)  driving rod: ท่อรูปตัว U
Tc = [126.008 -25.709];  RT = 15.3022;   % จุดศูนย์กลางและรัศมีส่วนโค้งของท่อ
a0 = atan2(-39.464-Tc(2), 119.304-Tc(1));   % มุมเริ่มของส่วนโค้ง
a1 = atan2(-11.991-Tc(2), 132.815-Tc(1));  if a1 < a0, a1 = a1 + 2*pi; end   % มุมจบของส่วนโค้ง (กันมุมข้าม +-180)
rodPath = [linspacePts([39.990 -10.596],[119.304 -39.464],25);   % เส้นกลางท่อ: ท่อตรงยาว จาก A ไปหาส่วนโค้ง
           circPts(Tc,RT,60,a0,a1);   % ส่วนโค้งอ้อมมอเตอร์
           linspacePts([132.815 -11.991],[128.984 -10.596],6)];   % ท่อตรงสั้นเข้า O2
hRod = hgtransform('Parent',ax);   % กลุ่มของ rod
part(hRod, tubePts(rodPath,2.1053), C.rod, 4, 1);   % ขยายเส้นกลางเป็นท่อรัศมี 2.105 mm
part(hRod, circPts(O2,4.0,40), C.rod, 4.1, 1);   % ดุมแกนที่ O2
part(hRod, circPts(A0,4.0,40), C.rod, 4.1, 1);   % ดุมแกนที่ A
part(hRod, circPts(O2,1.2,12), C.pin, 4.2, 1);   % จุดหมุน O2

% door: panel + hinge lugs at A and B  (pure translation)  ประตู: เลื่อนอย่างเดียว ไม่หมุน
hDoor = hgtransform('Parent',ax);   % กลุ่มของประตู
part(hDoor, rectPts(-53.733,114.688,-1.012,1.988), C.door, 6, 1);   % แผ่นประตู กว้าง 168.4 หนา 3 mm
part(hDoor, lugPts(A0,6.2632,-1.012), C.door, 6, 1);   % หูยึดที่ A (ต่อกับ rod)
part(hDoor, lugPts(B0,5.1579,-1.012), C.door, 6, 1);   % หูยึดที่ B (ต่อกับ link เขียว)
part(hDoor, circPts(A0,3.0,30), C.rod, 6.1, 1);                               % rod pin through door lug | ปลายเพลา rod ที่สอดผ่านหูประตู
part(hDoor, circPts(B0,1.0,16), C.pin, 6.1, 1);   % รูหมุดที่ B

% OVERLAYS  เส้น link, ลูกศร, ตัวหนังสือ วาดทับทุกชิ้น
Z = 10;   % ชั้น z ของ overlay (สูงสุด อยู่บนสุด)
plot3(ax, RP(1,:), RP(2,:), Z*ones(size(tt)), ':', 'Color',[0.17 0.36 0.61], 'LineWidth',1.2);   % path of P | เส้น path ของจุด P
hL2 = plot3(ax,[0 0],[0 0],[Z Z],'--','Color',[0.91 0.35 0.05],'LineWidth',1.6);   % เส้น O2-A (rod)
hL4 = plot3(ax,[0 0],[0 0],[Z Z],'--','Color',[0.91 0.35 0.05],'LineWidth',1.6);   % เส้น O4-B (link เขียว)
hL3 = plot3(ax,[0 0],[0 0],[Z Z],':', 'Color',[0.91 0.35 0.05],'LineWidth',1.4);   % เส้น A-B (ประตู)
plot3(ax,[O2(1) O4(1)],[O2(2) O4(2)],[Z Z],':','Color',[0.91 0.35 0.05],'LineWidth',1.4);   % เส้น O2-O4 (ground)
plot3(ax,[O2(1) O4(1)],[O2(2) O4(2)],[Z Z],'ko','MarkerFaceColor','k','MarkerSize',5);   % จุดหมุนที่อยู่กับที่ O2, O4
hJ  = plot3(ax,[0 0],[0 0],[Z Z],'o','Color',[0.91 0.35 0.05],'MarkerFaceColor',[0.91 0.35 0.05],'MarkerSize',6);   % จุด A, B (ขยับ)
hPt = plot3(ax,0,0,Z,'o','Color',[0.17 0.36 0.61],'MarkerFaceColor',[0.17 0.36 0.61],'MarkerSize',5);   % จุด P บนประตู
text(ax,O2(1)+3,O2(2)-5,Z,'O_2','FontWeight','bold');  text(ax,O4(1)-9,O4(2)-5,Z,'O_4','FontWeight','bold');   % ป้ายชื่อ O2, O4
hTA = text(ax,0,0,Z,'A','Color',[0.7 0.25 0],'FontWeight','bold');   % ป้ายชื่อ A (ขยับตาม)
hTB = text(ax,0,0,Z,'B','Color',[0.7 0.25 0],'FontWeight','bold');   % ป้ายชื่อ B (ขยับตาม)
sV = 0.6;  sA = 1.0;                                    % arrow scales  (mm per mm/s, mm per mm/s^2) | สเกลความยาวลูกศร
hV = arrow2d(ax, [0 0], [1 0], [0.17 0.54 0.24], Z);   % ลูกศรความเร็ว (เขียว)
hA = arrow2d(ax, [0 0], [1 0], [0.76 0.15 0.36], Z);   % ลูกศรความเร่ง (แดง)
hInfo = text(ax,0.01,0.97,'','Units','normalized','VerticalAlignment','top', ...
             'FontName','Consolas','FontSize',9,'BackgroundColor',[1 1 1 0.85],'Margin',4);   % กล่องข้อความ readout (ตอนนี้ปิดไว้ใน updateScene)
title(ax, sprintf(['Top view - parallelogram door linkage   (r_1=r_3=%.3f, r_2=r_4=%.3f mm)' ...
      '   green arrow: v_P x%.1f s,  red arrow: a_P x%.1f s^2'], r1, r2, sV, sA));   % ชื่อภาพ

% TIME PLOTS : ย้ายไปอยู่ในหน้าต่าง 'Door kinematics - results' แล้ว (ส่วน 2b)

% CONTROLS  ปุ่ม Play/Pause
hBtn = uicontrol(fig,'Style','togglebutton','String','Pause','Units','normalized', ...
                 'Position',[0.05 0.03 0.06 0.045],'Callback',@(s,~) set(s,'String',ifelse(s.Value,'Play','Pause')));   % กดสลับ Pause <-> Play


% bundle everything update() needs  รวม handle ทุกตัวที่ updateScene ต้องใช้
H = struct('LG',LG,'BG',BG,'RG',RG,'hRod',hRod,'hDoor',hDoor,'hL2',hL2,'hL3',hL3,'hL4',hL4, ...
           'hJ',hJ,'hPt',hPt,'hTA',hTA,'hTB',hTB,'hV',hV,'hA',hA,'hInfo',hInfo,'hCur',hCur,'Z',Z,'sV',sV,'sA',sA);   % H = handle ของรูป/เส้น
G = struct('O2',O2,'O4',O4,'M',M,'A0',A0,'r2',r2,'r4',r4,'th1',th1,'p',p, ...
           'f_th2',f_th2,'f_w2',f_w2,'f_a2',f_a2,'f_vP',f_vP,'f_aP',f_aP);   % G = ค่าคงที่และฟังก์ชันที่ใช้คำนวณ

%% %% 3b) SAVE ANIMATION : เซฟภาพเคลื่อนไหวเป็นไฟล์
SAVE_GIF = true;     % true = เซฟเป็น GIF (ใส่ใน README แล้วขยับได้เลย)
SAVE_MP4 = false;    % true = เซฟเป็น MP4 (วิดีโอ)
if SAVE_GIF || SAVE_MP4
    fps     = 15;                              % จำนวนเฟรมต่อวินาที
    tFrames = 0:1/fps:T_cycle;                 % เวลาของแต่ละเฟรม ครบ 1 รอบ เปิด-ปิด
    if SAVE_MP4
        vw = VideoWriter('door_animation.mp4','MPEG-4'); vw.FrameRate = fps; open(vw);
    end
    for k = 1:numel(tFrames)
        updateScene(H, G, tFrames(k)); drawnow;          % วาดภาพที่เวลานั้น
        fr = getframe(fig);                              % จับภาพหน้าต่าง animation
        if SAVE_GIF
            [im, cm] = rgb2ind(frame2im(fr), 256);       % แปลงเป็นภาพ 256 สีสำหรับ GIF
            if k == 1
                imwrite(im, cm, 'door_animation.gif', 'gif', 'LoopCount', Inf, 'DelayTime', 1/fps);
            else
                imwrite(im, cm, 'door_animation.gif', 'gif', 'WriteMode', 'append', 'DelayTime', 1/fps);
            end
        end
        if SAVE_MP4, writeVideo(vw, fr); end              % ใส่เฟรมลงวิดีโอ
    end
    if SAVE_MP4, close(vw); end
    disp('saved animation');
    return                                               % เซฟเสร็จแล้วจบ ไม่เข้าลูป animation
end

%% 4) ANIMATE  วนลูปจนกว่าจะปิดหน้าต่าง
tnow = 0; tPrev = tic;   % เวลาเริ่ม 0 และจับเวลาจริง
while ishghandle(fig)   % ทำซ้ำจนกว่าจะปิดหน้าต่าง animation
    dt = toc(tPrev); tPrev = tic;   % เวลาที่ผ่านไปตั้งแต่เฟรมก่อน
    if ~get(hBtn,'Value')                           
        tnow = mod(tnow + dt, T_cycle);                
    end
    updateScene(H, G, tnow);   % อัปเดตตำแหน่งทุกชิ้นตามเวลา tnow
    drawnow limitrate; pause(0.02);   % วาดจอใหม่ แล้วพักนิดนึง
end

%% LOCAL FUNCTIONS  ฟังก์ชันย่อย
function updateScene(H, G, t)   % อัปเดตภาพทุกเฟรม
    th2 = G.f_th2(t);  w2 = G.f_w2(t);  a2 = G.f_a2(t);   % มุม, omega, alpha ของ rod ที่เวลา t
    phi = th2 - pi;                                     % crank rotation from closed position | มุมที่ rod หมุนไปจากตอนปิด
    u   = [cos(th2) sin(th2)];   % เวกเตอร์หนึ่งหน่วยตามทิศ rod
    A   = G.O2 + G.r2*u;                                % theta4 = theta2 (parallelogram) | ตำแหน่ง A (theta4 = theta2)
    B   = G.O4 + G.r4*u;   % ตำแหน่ง B (ขนานกับ rod)
    P   = A + G.p;   % ตำแหน่ง P บนประตู
    vP  = G.f_vP(t).';  aP = G.f_aP(t).';   % ความเร็ว และความเร่งของประตู

    set(H.hRod, 'Matrix', rotAbout(G.O2,  phi));   % หมุน rod รอบ O2
    set(H.RG, 'Matrix', rotAbout(G.O2,  phi));   % หมุนเฟืองแดงรอบ O2
    set(H.LG, 'Matrix', rotAbout(G.O4,  phi));   % หมุน link เขียวรอบ O4 (มุมเท่า rod)
    set(H.BG, 'Matrix', rotAbout(G.M,  -phi/2));      % omega_m = -omega_2/2 | หมุนเฟืองน้ำเงินสวนทาง ครึ่งมุม
    d = A - G.A0;   % ระยะที่ประตูเลื่อนไป
    set(H.hDoor,'Matrix', makehgtform('translate',[d 0]));   % เลื่อนประตู (ไม่หมุน)

    Z = H.Z;
    set(H.hL2,'XData',[G.O2(1) A(1)],'YData',[G.O2(2) A(2)],'ZData',[Z Z]);   % ขยับเส้น O2-A
    set(H.hL4,'XData',[G.O4(1) B(1)],'YData',[G.O4(2) B(2)],'ZData',[Z Z]);   % ขยับเส้น O4-B
    set(H.hL3,'XData',[A(1) B(1)],   'YData',[A(2) B(2)],   'ZData',[Z Z]);   % ขยับเส้น A-B
    set(H.hJ, 'XData',[A(1) B(1)],   'YData',[A(2) B(2)],   'ZData',[Z Z]);   % ขยับจุด A, B
    set(H.hPt,'XData',P(1),'YData',P(2),'ZData',Z);   % ขยับจุด P
    set(H.hTA,'Position',[A+[2 3] Z]);  set(H.hTB,'Position',[B+[-7 3] Z]);   % ขยับป้ายชื่อ A, B
    arrow2d(H.hV, P, vP*H.sV);   % ลูกศรความเร็ว
    arrow2d(H.hA, P, aP*H.sA);   % ลูกศรความเร่ง
   
    %set(H.hInfo,'String',sprintf([ ...
       % 't      = %6.2f s\n' ...
        %'th2    = %7.2f deg   th3 = %7.2f deg   th4 = %7.2f deg\n' ...
        %'w2     = %7.4f rad/s  w3 = 0   w4 = w2   wm = %7.4f rad/s\n' ...
        %'a2     = %7.4f rad/s^2  a3 = 0   a4 = a2\n' ...
        %'r_P    = (%7.2f, %7.2f) mm\n' ...
        %'v_P    = (%7.2f, %7.2f)  |v| = %6.2f mm/s\n' ...
        %'a_P    = (%7.2f, %7.2f)  |a| = %6.2f mm/s^2'], ...
        %t, rad2deg(th2), rad2deg(G.th1), rad2deg(th2), w2, -w2/2, a2, ...
        %P(1), P(2), vP(1), vP(2), norm(vP), aP(1), aP(2), norm(aP)));
    for k = 1:numel(H.hCur), if isgraphics(H.hCur(k)), set(H.hCur(k),'XData',[t t]); end, end   % ขยับเส้นเวลาในหน้าต่างกราฟ (ถ้ายังเปิดอยู่)
end

function Mx = rotAbout(c, ang)   % เมทริกซ์หมุนรอบจุด c ด้วยมุม ang
    Mx = makehgtform('translate',[c 0],'zrotate',ang,'translate',[-c 0]);   % ย้ายไปจุดกำเนิด -> หมุน -> ย้ายกลับ
end

function h = part(parent, P, col, z, alpha)   % วาดรูปหลายเหลี่ยม 1 ชิ้น (parent, จุดขอบ, สี, ชั้น z, ความทึบ)
    h = patch('Parent',parent,'XData',P(:,1),'YData',P(:,2),'ZData',z*ones(size(P,1),1), ...
              'FaceColor',col,'FaceAlpha',alpha,'EdgeColor',[0.15 0.15 0.15],'LineWidth',0.5);
end

function P = circPts(c, r, n, a0, a1)   % จุดบนวงกลม/ส่วนโค้ง
    if nargin < 4, a0 = 0; a1 = 2*pi; end   % ไม่ใส่มุม = วงกลมเต็มวง
    a = linspace(a0, a1, n).';
    P = [c(1) + r*cos(a), c(2) + r*sin(a)];
end

function P = rectPts(x0, x1, y0, y1)   % สี่เหลี่ยมจากช่วง x, y
    P = [x0 y0; x1 y0; x1 y1; x0 y1];
end

function P = linspacePts(p, q, n)   % จุดบนเส้นตรงจาก p ไป q
    P = [linspace(p(1),q(1),n).', linspace(p(2),q(2),n).'];
end

function P = stadiumPts(p, q, r)                     % link bar with rounded ends | แท่งปลายมน
    a = atan2(q(2)-p(2), q(1)-p(1));
    P = [circPts(q, r, 30, a-pi/2, a+pi/2); circPts(p, r, 30, a+pi/2, a+3*pi/2)];
end

function P = lugPts(c, r, yPanel)                    % hinge lug: half-circle around c joined to the panel face | หูยึดรูปตัว U
    P = [c(1)+r yPanel; circPts(c, r, 40, 0, -pi); c(1)-r yPanel];
end

function P = tubePts(C, r)                           % planar outline of a tube of radius r along centreline C | ขยายเส้นกลางออกสองข้างเป็นรูปท่อ
    keep = [true; vecnorm(diff(C),2,2) > 1e-9];  C = C(keep,:);   % ตัดจุดซ้ำ
    d = zeros(size(C));   % ทิศทางเส้นที่แต่ละจุด
    d(1,:) = C(2,:) - C(1,:);  d(end,:) = C(end,:) - C(end-1,:);
    d(2:end-1,:) = C(3:end,:) - C(1:end-2,:);
    n = [-d(:,2) d(:,1)];  n = n ./ vecnorm(n,2,2);   % ทิศตั้งฉาก (normal) ยาว 1 หน่วย
    P = [C + r*n; flipud(C - r*n)];   % ขอบท่อด้านหนึ่ง + อีกด้านย้อนกลับ
end

function P = gearPts(c, N, ra, rf, ph)                % simple trapezoidal-tooth spur gear outline | โครงเฟืองฟันคางหมู (ศูนย์กลาง, จำนวนฟัน, รัศมีปลาย, รัศมีโคน, มุมเริ่ม)
    pa = 2*pi/N;  prof = [-0.48 rf; -0.27 ra; 0.27 ra; 0.48 rf];   % ระยะเชิงมุมต่อฟัน และรูปร่างฟัน 4 จุด
    P = zeros(4*N, 2);
    for k = 0:N-1
        a = ph + k*pa + prof(:,1)*pa;   % มุมของ 4 จุดของฟันซี่ที่ k
        P(4*k+(1:4),:) = [c(1) + prof(:,2).*cos(a), c(2) + prof(:,2).*sin(a)];
    end
end

function h = arrow2d(arg1, p, v, col, z)              % create:  h = arrow2d(ax,p,v,col,z) | สร้าง/อัปเดตลูกศร
    if isstruct(arg1)                                  % update:  arrow2d(h,p,v) | ถ้าส่ง struct มา = อัปเดตลูกศรเดิม
        h = arg1;  z = h.z;
    else
        h.z = z;   % สร้างลูกศรใหม่: เส้น + หัวสามเหลี่ยม
        h.line = plot3(arg1, [0 0], [0 0], [z z], '-', 'Color', col, 'LineWidth', 2.2);
        h.head = patch('Parent',arg1,'XData',[0 0 0],'YData',[0 0 0],'ZData',[z z z], ...
                       'FaceColor',col,'EdgeColor','none');
    end
    L = norm(v);  q = p + v;   % ความยาวลูกศร และตำแหน่งปลาย
    set(h.line,'XData',[p(1) q(1)],'YData',[p(2) q(2)],'ZData',[z z]);
    if L < 1e-9   % ยาว 0 = ซ่อนหัวลูกศร
        set(h.head,'XData',q(1)*[1 1 1],'YData',q(2)*[1 1 1]); return
    end
    u = v/L;  nrm = [-u(2) u(1)];  hl = min(4, 0.4*L);  hw = 0.45*hl;   % ขนาดหัวลูกศร
    base = q - hl*u;
    set(h.head,'XData',[q(1) base(1)+hw*nrm(1) base(1)-hw*nrm(1)], ...
               'YData',[q(2) base(2)+hw*nrm(2) base(2)-hw*nrm(2)]);
end

function out = ifelse(c, a, b)   % เลือกค่า a หรือ b ตามเงื่อนไข c
    if c, out = a; else, out = b; end
end
