# sac2mat

## Why sac2mat?

Quadstar 32 bits software is very very limited for analyze mass spectra from QMS measurements.
Export data from SAC files to CSV files of each cycle is possible, but you have to save it for every cycle.

This proposed code **sac2mat** is largely based from a [C code](http://www.bubek.org/physics/sac2dat.php?lang=en) developped by Dr. Moritz Bubek in 2012.
Thanks to him, no more time to export more than 100 cycles...

## What is sac2mat?

 **sac2mat** is a short Matlab program that allows to:

* import data from SAC files;
* plot of 2D and 3D mass spectra:
    * 2D plot : I = f(u) for all cycles
    * 3D plot : I = f(u) vs time cycle
    * 3D plot : I = f(u) vs cycle.
* export spectra to XSL, DAT or MAT files.

This program has been coded for Quadstar 32 bits - version 7.03.
This code has been tested on Microsoft Windows 7/8/10 and with Mathworks Matlab R2013+.

## How to use sac2mat?
### Prerequisites

* SAC files from Quadstar 32 bits - version 7.03. No guarantee that it works with others versions;
* Mathworks Matlab with no specific toolbox;
* (Optional) Microsoft Excel for reading exported XLS or XLSX files.

### Program

1. In **sac2mat** directory, put your SAC file;
2. Launch sac2mat.m;
3. Choose an option to export data;
4. Et voilà!

### Samples

For testing the routine, we can find a example of SAC file: data_sample.sac.

We also provide exported data: data_sample.xls, data_sample.mat and data_sample.dat.
