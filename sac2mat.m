%% sac2mat.m
% Quadstar 32 bits - version 7.03 is very very limited. 
% Export data from .sac files to .csv files of each cycle is posible.
% But, you have to save it for every single measurements cycle.
% This short program allow 

% This code is developped from the c code found here: http://www.bubek.org/physics/sac2dat.php?lang=en
% Thanks to Dr. Moritz Bubek, no more time to export more than 100
% cycles...

% _Version du 03/05/2013_
% _Zaccaria SILVESTRI_
%

%% Workspace Initialisation
close all
clear all
clc

%% Interactive choice of the .sac file to import.
%[fnameA,pnameA] = uigetfile('D:\*.sac', 'Selectionner le fichier *.sac à importer');

% Open the sac file
% fid = fopen(fnameA) ;

% Or directely in the code
 fid = fopen('250413.sac');
 
[filename, permission, machineformat, encoding] = fopen(fid) ;

%% Parameters to search in the sac file
% using fseek and fread

% Number of cycles 
fseek(fid, 100, 'bof') ;
NbCycle = double(fread(fid, 1, '*uint16')) ;

% Scan Width
fseek(fid, 345, 'bof') ;
Scan_Width = double(fread(fid, 1, '*uint16')) ;

% Number of measurements for each mass 
fseek(fid, 347, 'bof') ;
Nbmass = double(fread(fid, 1, '*uint16')) ;

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

%% Real number of data point for each cycle
Cal_NbPts = (u_end - u_start) * Nbmass ;

%% Construction of the 
u(1) = u_start ;

%u = zeros(NbPts + 33);
% Faire préallocation de mémoire

for i =  2 : (NbPts + 33) ;
    
    u(i,1) = u(i-1,1) + (1 / Nbmass) ;

end

%% Création de la matrice des cycles 
% Le temps de chaque cycle
fseek(fid, 0, 'bof') ;

time_cycle_all = fread(fid, 'ulong') ;
taille = size(time_cycle_all, 1) ;

j = 0 ;

% Faire pré-allocation de mémoire

for i = 96 : (Cal_NbPts + 3) : taille
    
   j = j + 1 ;
   time_cycle(j) = time_cycle_all(i) ; 
   
end

time_cycle = time_cycle ;

% Les points de chaque cycle

fseek(fid, 0, 'bof') ;
data_cycle_all = fread(fid, '*float') ;

% Décalage pour atteindre l'en-tête du 1er cycle
dec = 96 ;
l = 0 ;

% Faire préallocation de mémoire

for k = 1 : 1 : NbCycle
    for i = 1 : 1 : (Cal_NbPts)
    
        data_cycle(i,k) = data_cycle_all(dec + i + 2 + l) ;
    
    end
    % 
    l = l + 3 + Cal_NbPts ;
end

fclose(fid);

%% Infos sur les formats de données présents dans le fichier. 

% *uint16
% Ligne 100 et 121 : Nbres de cycles --> NbCycle  
% Ligne 107 ou 345 : Scan Width (Dernier u - 1ère u) --> Scan_Width (128)
% Ligne 347 : Nbre de points mesurés par mass --> Nbmass (64)
% Ligne 386 : Nbre de points d'un cycle --> NbPoints (8159)

% *float
% Ligne 341 : First mass --> First_u (0.5)
% Ligne 348 : Zoom Start --> u_start (0.5)
% Ligne 352 : Zomm End --> u_end (0.5)

% *char
% Ligne (221:234) : Ion Current A --> Unité (A)
% Ligne (248:252) : Mass 
% Ligne (261:263) : amu

% *ulong
% Ligne 194 : UTC time sec --> UTCs

% A = fread(fid1, [10, 10], 'single');
% fseek(fid1, 100, 'bof');
% data190 = fread(fid, 100000, x) ;

% *ulong
% Ligne 96 : temps 0 de l'acquisition du spectre
% Ligne 96 + Nbcycles * Nbpoints : Tous les temps d'acquisition

% Ligne 99 : premier points du cycle 1
% Ligne 99 + Nbcycles * Nbpoints : Tous les 1ers points 


%% Tracé des spectres
% Tracé 1D
figure(1)
plot(u, data_cycle) ;
xlabel('u') ;
ylabel('SEM Intensity (A)') ;

% Tracé 2D
% figure(2)
% scatter3(u, time_cycle, data_cycle)


%% Spectra Export to XSL file 
% 

cut_filename = strsplit(filename,'\\') ;
S = size(cut_filename,2) ;
% filename2 = strsplit(cut_filename{1, S}, '.sac') ;
filename3 = strsplit(filename, '.sac') ;

Header1 = {'XSL Export', cut_filename{1, S} ; 'Date & Time', Start_time ; 'Nb Cycles', NbCycle};
sheet = 1 ;
xlRange1 = 'A1' ;
xlswrite(filename3{1,1}, Header1, sheet, xlRange1)

Header2 = {'First mass', First_u ; 'Scan Width', Scan_Width ; 'Value/Mass', Nbmass ; 'u Start' , u_start ; 'u end' , u_end};
xlRange2 = 'A5' ;
xlswrite(filename3{1,1}, Header2, sheet, xlRange2)

Cycle_list = 1 : NbCycle ;

Header3 = [Cycle_list ; time_cycle] ;
xlRange3 = 'B11' ;
xlswrite(filename3{1,1}, Header3, sheet, xlRange3)

Header4 = [u , data_cycle] ;
xlRange4 = 'A13' ;
xlswrite(filename3{1,1}, Header4, sheet, xlRange4)

Header5 =  {'Ion current', Units_I ; 'Mass Unit' , Units_u};
xlRange5 = 'E5' ;
xlswrite(filename3{1,1}, Header5, sheet, xlRange5)




