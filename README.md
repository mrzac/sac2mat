# sac2mat

## Why sac2mat?

Quadstar 32 bits soft is very very limited for analyze mass spectra from QMS measurements.
Export data from SAC files to CSV files of each cycle is posible, but you have to save it for every cycle.

sac2mat is largely based from [C code](http://www.bubek.org/physics/sac2dat.php?lang=en) developped by Dr. Moritz Bubek in 2012.
Thanks to him, no more time to export more than 100 cycles...

## What is sac2mat?

 sac2mat is a short Matlab program that allows to:

* import data from SAC files;
* plot 2D and/or 3D mass spectra;
* export spectra to XSL, DAT or MAT files.

This program has been coded for Quadstar 32 bits - version 7.03.
Tested on Microsoft Windows 7/8/10 and with Mathworks Matlab R2013+.

## How to use sac2mat?
### Prerequisites

* SAC files from Quadstar 32 bits - version 7.03. No guarantee that it works with others versions;
* Mathworks Matlab with no specific toolbox;
* (Optional) Microsoft Excel for reading exported XSL files.

### Program

1. Put your SAC file in the same directory that sac2mat.m;
2. Launch sac2mat.m;
3. Choose an option to export data.

### Samples

For testing the routine, we you find a example of SAC file:data_sample.sac.
We also provide exported data: data_sample.xls and data_sample.mat and data_sample.dat. 
