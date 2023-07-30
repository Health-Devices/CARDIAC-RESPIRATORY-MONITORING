function mediaProperties = mediaPropertiesLibrary(wavelength,parameters)
%   Returns the known media properties (optical, thermal and/or fluorescence) at the specified wavelength.
%   
%   Many parameters, formulas and the spectralLIB library is from mcxyz and
%   other work by Steven Jacques and collaborators.
%
%   Pay attention to the section with the header that says "USER SPECIFIED:"
%   That's where you fill in the parameters relevant for your simulation.
%
%   For each medium, mediaProperties must contain mua, mus and g;
%       mua is the absorption coefficient [cm^-1] and must be positive (not zero)
%       mus is the scattering coefficient [cm^-1] and must be positive (not zero)
%       g is the anisotropy factor and must satisfy -1 <= g <= 1
%   the following parameters are optional:
%    mediaProperties may contain the refractive index for simulating non-matched interfaces such as reflection and refraction;
%       n is the refractive index and can be from 1 to Inf, where Inf means the medium is a perfect reflector
%   and parameters for simulating thermal diffusion;
%       VHC is volumetric heat capacity [J/(cm^3*K)] and must be positive
%       TC is thermal conductivity [W/(cm*K)] and must be non-negative
%   and parameters to calculate thermal damage;
%       E is the Arrhenius activation energy [J/mol]
%       A is the Arrhenius pre-exponential factor [1/s]
%   and the fluorescence power yield;
%       Y is fluorescence power yield (watts of emitted fluorescence light per watt of absorbed pump light) [-]
%
%   Requires
%       SpectralLIB.mat
%
%   See also defineGeometry, getMediaProperties

%%%%%
%   Copyright 2017, 2018 by Dominik Marti and Anders K. Hansen, DTU Fotonik
%   This function was inspired by makeTissueList.m of the mcxyz program hosted at omlc.org
%   
%   This file is part of MCmatlab.
%
%   MCmatlab is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   MCmatlab is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with MCmatlab.  If not, see <https://www.gnu.org/licenses/>.
%%%%%

%% Load spectral library
load spectralLIB.mat
%   muadeoxy      701x1              5608  double
%   muamel        701x1              5608  double
%   muaoxy        701x1              5608  double
%   muawater      701x1              5608  double
%   musp          701x1              5608  double
%   nmLIB         701x1              5608  double
MU(:,1) = interp1(nmLIB,muaoxy,wavelength);
MU(:,2) = interp1(nmLIB,muadeoxy,wavelength);
MU(:,3) = interp1(nmLIB,muawater,wavelength);
MU(:,4) = interp1(nmLIB,muamel,wavelength);

%% USER SPECIFIED: Define media and their properties

j=1;
mediaProperties(j).name  = 'air';
mediaProperties(j).mua   = 1e-8;
mediaProperties(j).mus   = 1e-8;
mediaProperties(j).g     = 1;
mediaProperties(j).n     = 1;
mediaProperties(j).VHC   = 1.2e-3;
mediaProperties(j).TC    = 0; % Real value is 2.6e-4, but we set it to zero to neglect the heat transport to air

j=2;
mediaProperties(j).name  = 'water';
mediaProperties(j).mua   = 0.00036;
mediaProperties(j).mus   = 10;
mediaProperties(j).g     = 1.0;
mediaProperties(j).n     = 1.3;
mediaProperties(j).VHC   = 4.19;
mediaProperties(j).TC    = 5.8e-3;

j=3;
mediaProperties(j).name  = 'standard tissue';
mediaProperties(j).mua   = 1;
mediaProperties(j).mus   = 100;
mediaProperties(j).g     = 0.9;
mediaProperties(j).n     = 1.3;
mediaProperties(j).VHC   = 3391*1.109e-3;
mediaProperties(j).TC    = 0.37e-2;

j=4;
mediaProperties(j).name  = 'epidermis';
B = 0;
S = 0.75;
W = 0.75;
Me = 0.03;
musp500 = 40;
fray    = 0.0;
bmie    = 1.0;
gg      = 0.90;
musp = musp500*(fray*(wavelength/500).^-4 + (1-fray)*(wavelength/500).^-bmie);
X = [B*S B*(1-S) W Me]';
mediaProperties(j).mua = MU*X;
mediaProperties(j).mus = musp/(1-gg);
mediaProperties(j).g   = gg;
mediaProperties(j).n   = 1.3;
mediaProperties(j).VHC = 3391*1.109e-3;
mediaProperties(j).TC  = 0.37e-2;

j=5;
mediaProperties(j).name = 'dermis';
B = 0.002;
S = 0.67;
W = 0.65;
Me = 0;
musp500 = 42.4;
fray    = 0.62;
bmie    = 1.0;
gg      = 0.90;
musp = musp500*(fray*(wavelength/500).^-4 + (1-fray)*(wavelength/500).^-bmie);
X = [B*S B*(1-S) W Me]';
mediaProperties(j).mua = MU*X;
mediaProperties(j).mus = musp/(1-gg);
mediaProperties(j).g   = gg;
mediaProperties(j).n   = 1.3;
mediaProperties(j).VHC = 3391*1.109e-3;
mediaProperties(j).TC  = 0.37e-2;

j=6;
mediaProperties(j).name  = 'blood';
B       = 1.00;
S       = 0.75;
W       = 0.95;
Me       = 0;
musp500 = 10;
fray    = 0.0;
bmie    = 1.0;
gg      = 0.90;
musp = musp500*(fray*(wavelength/500).^-4 + (1-fray)*(wavelength/500).^-bmie);
X = [B*S B*(1-S) W Me]';
mediaProperties(j).mua = MU*X;
mediaProperties(j).mus = musp/(1-gg);
mediaProperties(j).g   = gg;
mediaProperties(j).n   = 1.3;
mediaProperties(j).VHC = 3617*1.050e-3;
mediaProperties(j).TC  = 0.52e-2;
mediaProperties(j).E   = 422.5e3; % J/mol    PLACEHOLDER DATA ONLY
mediaProperties(j).A   = 7.6e66; % 1/s        PLACEHOLDER DATA ONLY

j=7;
mediaProperties(j).name  = 'vessel';
mediaProperties(j).mua   = 0.8;
mediaProperties(j).mus   = 230;
mediaProperties(j).g     = 0.9;
mediaProperties(j).n     = 1.3;
mediaProperties(j).VHC   = 4200*1.06e-3;
mediaProperties(j).TC    = 6.1e-3;

j=8;
mediaProperties(j).name = 'enamel';
mediaProperties(j).mua   = 0.1;
mediaProperties(j).mus   = 30;
mediaProperties(j).g     = 0.96;
mediaProperties(j).VHC   = 750*2.97e-3;
mediaProperties(j).TC    = 9e-3;

j=9;
mediaProperties(j).name  = 'dentin';
mediaProperties(j).mua   = 4; %in cm ^ -1, doi:10.1364/AO.34.001278
mediaProperties(j).mus   = 270; %range between 260-280
mediaProperties(j).g     = 0.93;
mediaProperties(j).VHC   = 1260*2.14e-3; % Volumetric Heat Capacity [J/(cm^3*K)]
mediaProperties(j).TC    = 6e-3; % Thermal Conductivity [W/(cm*K)]

j=10;
mediaProperties(j).name = 'hair';
B = 0;
S = 0.75;
W = 0.75;
Me = 0.03;
gg = 0.9;
musp = 9.6e10./wavelength.^3; % from Bashkatov 2002, for a dark hair
X = 2*[B*S B*(1-S) W Me]';
mediaProperties(j).mua = MU*X; %Here the hair is set to absorb twice as much as the epidermis
mediaProperties(j).mus = musp/(1-gg);
mediaProperties(j).g   = gg;
mediaProperties(j).VHC = 1530*1.3e-3; % Thermal data has been approximated using the data for horn, as horn and hair are both composed of keratin
mediaProperties(j).TC  = 6.3e-3;

j=11;
mediaProperties(j).name  = 'skull';
% ONLY PLACEHOLDER DATA!
B = 0.0005;
S = 0.75;
W = 0.35;
Me = 0;
musp500 = 30;
fray    = 0.0;
bmie    = 1.0;
gg      = 0.90;
musp = musp500*(fray*(wavelength/500).^-4 + (1-fray)*(wavelength/500).^-bmie);
X = [B*S B*(1-S) W Me]';
mediaProperties(j).mua = MU*X;
mediaProperties(j).mus = musp/(1-gg);
mediaProperties(j).g   = gg;
mediaProperties(j).VHC = 3391*1.109e-3;
mediaProperties(j).TC  = 0.37e-2;

j=12;
mediaProperties(j).name = 'gray matter';
% ONLY PLACEHOLDER DATA!
B = 0.01;
S = 0.75;
W = 0.75;
Me = 0;
musp500 = 20;
fray    = 0.2;
bmie    = 1.0;
gg      = 0.90;
musp = musp500*(fray*(wavelength/500).^-4 + (1-fray)*(wavelength/500).^-bmie);
X = [B*S B*(1-S) W Me]';
mediaProperties(j).mua = MU*X;
mediaProperties(j).mus = musp/(1-gg);
mediaProperties(j).g   = gg;
mediaProperties(j).n   = 1.3;
mediaProperties(j).VHC = 3391*1.109e-3;
mediaProperties(j).TC  = 0.37e-2;

j=13;
mediaProperties(j).name  = 'white matter';
% ONLY PLACEHOLDER DATA!
B = 0.01;
S = 0.75;
W = 0.75;
Me = 0;
musp500 = 20;
fray    = 0.2;
bmie    = 1.0;
gg      = 0.90;
musp = musp500*(fray*(wavelength/500).^-4 + (1-fray)*(wavelength/500).^-bmie);
X = [B*S B*(1-S) W Me]';
mediaProperties(j).mua = MU*X;
mediaProperties(j).mus = musp/(1-gg);
mediaProperties(j).g   = gg;
mediaProperties(j).n   = 1.3;
mediaProperties(j).VHC = 3391*1.109e-3;
mediaProperties(j).TC  = 0.37e-2;
