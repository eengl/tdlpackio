# pytdlpack

## Introduction

NOAA/NWS Meteorological Development Lab ([MDL](https://www.weather.gov/mdl/)) produces model output statistics (MOS) for a variety of NOAA/NCEP Numerical Weather Prediction (NWP) models.  MOS is produced via MDL's in-house MOS-2000 (MOS2K) Fortran-based software system.  MOS2K uses a GRIB-like binary data format called TDLPACK.  `pytdlpack` is a Python interface to reading and writing TDLPACK files.

A brief introduction to TDLPACK files and data format can be found [here](TDLPACK.md).

## Motivation

Provide a Python interface for reading and writing TDLPACK files.

## Installation

To install ([numpy](http://numpy.org) and fortran compiler (preferably 
[gfortran](https://gcc.gnu.org/wiki/GFortran)) required):

* ``python setup.py build``
   - If you change the fortran compiler, you may have to add the 
flags `config_fc --fcompiler=<compiler name>` when setup.py is run
(see docs for [numpy.distutils] (http://docs.scipy.org/doc/numpy-dev/f2py/distutils.html)).
* ``python setup.py install``

* to run test, execute ``python <SOME TEST SCRIPT HERE>``
