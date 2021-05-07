%% sac2mat.m
% Quadstar 32 bits is very limited. 
% Export data from .sac files to .csv files of each cycle is posible.
% But, you have to save it for every single measurements cycle.
% This short program allows to:
% * import data from SAC files;
% * plot of 2D and 3D mass spectra: 
%   * 2D plot : I = f(u) for all cycles;
%   * 3D plot : I = f(u) vs time cycle;
%   * 3D plot : I = f(u) vs cycle.
% * export spectra to XSL, DAT or MAT files.

% This code is developped from the C code source found here: http://www.bubek.org/physics/sac2dat.php?lang=en
% Thanks to Dr. Moritz Bubek, no more time to export manually more than 100 cycles...

% Matlab code for developped for QuadStar 32 bits V.7.03 
% _Version Code: 05/27/2013_REV_05/22/2017
% _Zaccaria SILVESTRI_
%

%% Informations about data formats in the file. 

% *uint16
% Line 100 and 121 : Number of cycles --> NbCycle  
% Line 107 or 345 : Scan Width (Last u - First u) --> Scan_Width (128)
% Line 347 : Number of measured data per mass --> Steps (64)
% Line 386 : Number of data for ine cycle --> NbPoints (8159)

% *float
% Line 341 : First mass --> First_u (0.5)
% Line 348 : Zoom Start --> u_start (0.5)
% Line 352 : Zomm End --> u_end (0.5)

% *char
% Line (221:234) : Ion Current A --> Unity (A)
% Line (248:252) : Mass 
% Line (261:263) : amu

% *ulong
% Line 194 : UTC time sec --> UTCs

% A = fread(fid1, [10, 10], 'single');
% fseek(fid1, 100, 'bof');
% data190 = fread(fid, 100000, x) ;

% *ulong
% Line 96 : Time 0 of spectra acquisition
% Line 96 + Nbcycles * Nbpoints : All times acquisition

% Line 99 : First data of cycle 1
% Line 99 + Nbcycles * Nbpoints : All first data

%% Workspace Initialisation
close all
clear all %#ok<*CLALL>
clc

%% Interactive choice of the SAC file to import.
% [fname, pname] = uigetfile('D:\*.sac', 'Select *.sac file to import in Matlab');

% Open the *.sac file
% fid = fopen(fname) ;

% Or directely in the code
fid = fopen('data_sample.sac');
 
% Get information about *sac file
[filename, permission, machineformat, encoding] = fopen(fid) ;

%% Parameters to search in the sac file
% using fseek and fread

% Number of cycles 
fseek(fid, 100, 'bof') ;
NbCycle = double(fread(fid, 1, '*uint16')) ;
Cycle_list = 1 : NbCycle ;

% Scan Width
fseek(fid, 345, 'bof') ;
Scan_Width = double(fread(fid, 1, '*uint16')) ;

% Number of measurements for each mass 
fseek(fid, 347, 'bof') ;
Steps = double(fread(fid, 1, '*uint16')) ;

% Number of data points for each cycle 
fseek(fid, 386, 'bof') ;
NbPts = double(fread(fid, 1, '*uint16')) ;

% First mass u
fseek(fid, 341, 'bof') ;
First_u = double(fread(fid, 1, '*float')) ;

% First mass exported
fseek(fid, 348, 'bof') ;
u_start = double(fread(fid, 1, '*float')) ;

% Last mass exported
fseek(fid, 352, 'bof') ;
u_end = double(fread(fid, 1, '*float')) ;

% Unit of the intensity I
fseek(fid, 234, 'bof') ;
Units_I = fread(fid, 1, '*char') ;

% Unit of the mass u
fseek(fid, 263, 'bof') ;
Units_u = fread(fid, 1, '*char') ;

% UTC time when storage starts
fseek(fid, 194, 'bof') ;
UTC = fread(fid, 1, 'ulong') ;

% UTC time conversion (Elapsed time in seconds from January 1st 1970) to
% date format (ex. 26-Feb-2013 09:49:25)).
Start_time = datestr(datenum([1970, 1, 1, 0, 0, UTC])) ;

%% "Real" number of data point for each cycle
Cal_NbPts = Scan_Width * Steps ;

%% Construction of the uma 
u = zeros(NbPts + 33, 1) ;

u(1) = First_u ;
for i =  2 : (NbPts + 33) 
   u(i,1) = u(i-1,1) + (1 / Steps) ;
end

%% Creation of the matrix of cycles 
% Time of each cycle
fseek(fid, 0, 'bof') ;

time_cycle_all = fread(fid, 'ulong') ;
taille = size(time_cycle_all, 1) ;

j = 0 ;
time_cycle = zeros(1, NbCycle) ;

for i = 96 : (Cal_NbPts + 3) : taille 
   j = j + 1 ;
   time_cycle(j) = time_cycle_all(i) ;
end

% Data for each cycle
fseek(fid, 0, 'bof') ;
data_cycle_all = fread(fid, '*float') ;

% Offset to reach the heading of first cycle
dec = 96 ;
l = 0 ;

data_cycle = zeros(NbPts + 33, NbCycle) ; 

for k = 1 : 1 : NbCycle
    for i = 1 : (Cal_NbPts)
        data_cycle(i,k) = data_cycle_all(dec + i + 2 + l) ;
    end
    l = l + 3 + Cal_NbPts ;
end

fclose(fid);

%% Spectra Plot
% 2D plot : I = f(u) for all cycle
figure(1)
plot(u, data_cycle) ;
xlabel('Mass (u)') ;
ylabel('Intensity (A)') ;
grid on
box on
title('I = f(u)')

% 3D plot : I = f(u) vs time cycle
X = repmat(u, 1, NbCycle) ;
Y1 = repmat(time_cycle, size(u,1) , 1) ;
Y2 = repmat(Cycle_list, size(u,1) , 1) ;

figure(2)
plot3(X, Y1, data_cycle) ;
xlabel('Mass (u)') ;
ylabel('Time cycle (s)');
zlabel('Intensity (A)') ;
grid on
box on
title('I = f(u) vs Time Cycle')

figure(3)
plot3(X, Y2, data_cycle) ;
xlabel('Mass (u)') ;
ylabel('Cycle');
zlabel('Intensity (A)') ;
grid on
box on
title('I = f(u) vs Cycle')

%% Mass Spectra Export
% XLS File
% DAT File
% MAT File
% NO Export

cut_filename = strsplit(filename,'\\') ;
S = size(cut_filename,2) ;
% filename2 = strsplit(cut_filename{1, S}, '.sac') ;
filename3 = strsplit(filename, '.sac') ;

menu_export = menu('Export Data?',' - XLS File','- DAT File', '- MAT File', '- NO Export') ;

switch 1
    case (menu_export == 1)     
    %% Mass Spectra Export to XSL file 
    % Not recommended starting in R2019a - Use writetable, writematrix, or writecell instead.
    Header1 = {'XSL Export', cut_filename{1, S} ; 'Date & Time', Start_time ; 'Nb Cycles', NbCycle};
    sheet = 1 ;
    xlRange1 = 'A1' ;
    xlswrite(filename3{1,1}, Header1, sheet, xlRange1)

    Header2 = {'First mass', First_u ; 'Scan Width', Scan_Width ; 'Value/Mass', Steps ; 'u Start' , u_start ; 'u End' , u_end};
    xlRange2 = 'A5' ;
    xlswrite(filename3{1,1}, Header2, sheet, xlRange2)

    Header3 = [Cycle_list ; time_cycle] ;
    xlRange3 = 'B11' ;
    xlswrite(filename3{1,1}, Header3, sheet, xlRange3)

    Header4 = [u , data_cycle] ;
    xlRange4 = 'A13' ;
    xlswrite(filename3{1,1}, Header4, sheet, xlRange4)

    Header5 =  {'Ion current', Units_I ; 'Mass Unit' , Units_u};
    xlRange5 = 'E5' ;
    xlswrite(filename3{1,1}, Header5, sheet, xlRange5)

    case (menu_export == 2)
        
    %% Mass Spectra Export to DAT / TXT file 
    filename_dat = [filename3{1,1} '.dat'] ;
    fid2 = fopen(filename_dat, 'w');
    
    fprintf(fid2, 'DAT Export \t %s \r', cut_filename{1, S}) ;
    fprintf(fid2, '\n Date & Time \t %s \r', Start_time) ;
    fprintf(fid2, '\n Nb Cycles \t %d \r', NbCycle) ;
    
    fprintf(fid2, '\n First mass \t %d \r', First_u) ;
    fprintf(fid2, '\n Scan Width \t %d \r', Scan_Width) ;
    fprintf(fid2, '\n Value/Mass \t %d \r', Steps) ;
    fprintf(fid2, '\n u Start \t %d \r', u_start) ;
    fprintf(fid2, '\n u End \t %d \r', u_end) ;
    
    fprintf(fid2, '\n \t %d ', Cycle_list) ;
    fprintf(fid2, '\t %d \r', time_cycle) ;
    
    Header4 = [u , data_cycle] ;
    fprintf(fid2, '\n \t %f \r', Header4) ;
        
    fclose(fid2);
   
    case (menu_export == 3)
        
    %% Mass Spectra Export to MAT file 
    % Save all
    filename_mat = [filename3{1,1} '.mat'] ;
    save(filename_mat, 'NbCycle', 'Scan_Width', 'Steps', 'NbPts', 'First_u', 'u_start', 'u_end', 'Units_I', 'Units_u', 'UTC', 'Start_time', 'Cal_NbPts', 'u', 'time_cycle', 'data_cycle')
    
    otherwise
        disp('Data NOT Exported')
        % warndlg('Data NOT Exported')
end