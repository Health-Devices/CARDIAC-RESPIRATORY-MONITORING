
addpath([fileparts(matlab.desktop.editor.getActiveFilename) '/helperfuncs']); % The helperfuncs folder is added to the path for the duration of this MATLAB session
fprintf('\n');

%% Decription
% This example simulates a collimated top hat beam of radius 300 µm
% incident on skin, with some gel (water) on the top. This example is
% constructed identically to that on the mcxyz website, except that photons
% escape on all boundaries and the voxel grid is only 100x100x100:
% https://omlc.org/software/mc/mcxyz/
%
% The found absorption distribution is then passed into the heat simulator,
% assuming the light is on for 5 pulses of 1 ms on time and 4 ms off time
% each, with 4 W of peak power. Some demonstration values of the Arrhenius
% E and A parameters for blood coagulation are used to calculate the
% distribution of coagulated blood. Temperature sensors outputs and movie
% generation is also demonstrated.

%% Geometry definition
global ii;
ii=0;
load('plethy1.mat')
model = initializeMCmatlabModel();

model.G.nx                = 300; % Number of bins in the x direction
model.G.ny                = 500; % Number of bins in the y direction
model.G.nz                = 300; % Number of bins in the z direction
model.G.Lx                = 0.5; % [cm] x size of simulation cuboid
model.G.Ly                = 0.8; % [cm] y size of simulation cuboid
model.G.Lz                = 0.6; % [cm] z size of simulation cuboid

model.G.mediaPropertiesFunc = @mediaPropertiesFunc; % Media properties defined as a function at the end of this file
model.G.geomFunc          = @geometryDefinition_BloodVessel; % Function to use for defining the distribution of media in the cuboid. Defined at the end of this m file.

% Execution, do not modify the next line:
model = defineGeometry(model);

plotMCmatlabGeom(model);

%% Monte Carlo simulation
model = clearMCmatlabModel(model,'MC'); % Only necessary if you want to run this section repeatedly, re-using previous G data

model.MC.simulationTimeRequested  = 5; % [min] Time duration of the simulation

model.MC.calcNFR                  = true; % (Default: true) If true, the 3D fluence rate output matrix NFR will be calculated. Set to false if you have a light collector and you're only interested in the image output.
model.MC.calcNFRdet               = true; % (Default: false) 
model.MC.nExamplePaths            = 5;

model.MC.matchedInterfaces        = true; % Assumes all refractive indices are 1
model.MC.boundaryType             = 1; % 0: No escaping boundaries, 1: All cuboid boundaries are escaping, 2: Top cuboid boundary only is escaping
model.MC.wavelength               = 660; % [nm] Excitation wavelength, used for determination of optical properties for excitation light

model.MC.beam.beamType            = 4; % 0: Pencil beam, 1: Isotropically emitting point source, 2: Infinite plane wave, 3: Laguerre-Gaussian LG01 beam, 4: Radial-factorizable beam (e.g., a Gaussian beam), 5: X/Y factorizable beam (e.g., a rectangular LED emitter)
model.MC.beam.NF.radialDistr      = 1; % Radial near field distribution - 0: Top-hat, 1: Gaussian, Array: Custom. Doesn't need to be normalized.
model.MC.beam.NF.radialWidth      = 0.1;%.005; % [cm] Radial near field 1/e^2 radius if top-hat or Gaussian or half-width of the full distribution if custom
model.MC.beam.FF.radialDistr      = 1; % Radial far field distribution - 0: Top-hat, 1: Gaussian, 2: Cosine (Lambertian), Array: Custom. Doesn't need to be normalized.
model.MC.beam.FF.radialWidth      = pi/8; %5/180*pi; % it was 5/180*pi [rad] Radial far field 1/e^2 half-angle if top-hat or Gaussian or half-angle of the full distribution if custom. For a diffraction limited Gaussian beam, this should be set to model.MC.wavelength*1e-9/(pi*model.MC.beam.NF.radialWidth*1e-2))
model.MC.beam.xFocus              = 0; % [cm] x position of focus
model.MC.beam.yFocus              = -.15; % [cm] y position of focus
model.MC.beam.zFocus              = 0; % [cm] z position of focus
model.MC.beam.theta               = 0; %pi/3; % [rad] Polar angle of beam center axis
model.MC.beam.phi                 = pi/2; % [rad] Azimuthal angle of beam center axis

model.MC.useLightCollector        = true;
model.MC.LC.x                     = 0; % [cm] x position of either the center of the objective lens focal plane or the fiber tip
model.MC.LC.y                     = 0.15; % [cm] y position
model.MC.LC.z                     = 0; % [cm] z position

model.MC.LC.theta                 = 0; % [rad] Polar angle of direction the light collector is facing
model.MC.LC.phi                   = -pi/2; % [rad] Azimuthal angle of direction the light collector is facing

model.MC.LC.f                     = 0;%.1; % [cm] Focal length of the objective lens (if light collector is a fiber, set this to Inf).
model.MC.LC.diam                  = .2; % [cm] Diameter of the light collector aperture. For an ideal thin lens, this is 2*f*tan(asin(NA)).
model.MC.LC.fieldSize             = 0.2;%.04; % [cm] Field Size of the imaging system (diameter of area in object plane that gets imaged). Only used for finite f.
model.MC.LC.NA                    = 0.22; % [-] Fiber NA. Only used for infinite f.
% model.FMC.LC.f                    = 0.1; % [cm] Focal length of the objective lens (if light collector is a fiber, set this to Inf).
% model.FMC.LC.diam                 = .1; % [cm] Diameter of the light collector aperture. For an ideal thin lens, this is 2*f*tan(asin(NA)).
% model.FMC.LC.fieldSize            = .04; % [cm] Field Size of the imaging system (diameter of area in object plane that gets imaged). Only used for finite f.
% model.FMC.LC.NA                   = 0.22; % [-] Fiber NA. Only used for infinite f.


model.MC.LC.res                   = 250;%50; % X and Y resolution of light collector in pixels, only used for finite f
model.MC.P  =4;
% Execution, do not modify the next line:



%% Heat simulation
% model = clearMCmatlabModel(model,'HS'); % Only necessary if you want to run this section repeatedly, re-using previous G, MC and/or FMC data
% 
% model.MC.P                   = 4; % [W] Incident pulse peak power (in case of infinite plane waves, only the power incident upon the cuboid's top surface)
% 
% model.HS.useAllCPUs          = true; % If false, MCmatlab will leave one processor unused. Useful for doing other work on the PC while simulations are running.
% model.HS.makeMovie           = true; % Requires silentMode = false.
% model.HS.largeTimeSteps      = false; % (Default: false) If true, calculations will be faster, but some voxel temperatures may be slightly less precise. Test for yourself whether this precision is acceptable for your application.
% 
% model.HS.heatBoundaryType    = 0; % 0: Insulating boundaries, 1: Constant-temperature boundaries (heat-sinked)
% model.HS.durationOn          = 0.001; % [s] Pulse on-duration
% model.HS.durationOff         = 0.004; % [s] Pulse off-duration
% model.HS.durationEnd         = 0.02; % [s] Non-illuminated relaxation time to add to the end of the simulation to let temperature diffuse after the pulse train
% model.HS.Tinitial            = 37; % [deg C] Initial temperature
% 
% model.HS.nPulses             = 5; % Number of consecutive pulses, each with an illumination phase and a diffusion phase. If simulating only illumination or only diffusion, use nPulses = 1.
% 
% model.HS.plotTempLimits      = [37 100]; % [deg C] Expected range of temperatures, used only for setting the color scale in the plot
% model.HS.nUpdates            = 100; % Number of times data is extracted for plots during each pulse. A minimum of 1 update is performed in each phase (2 for each pulse consisting of an illumination phase and a diffusion phase)
% model.HS.slicePositions      = [.5 0.6 1]; % Relative slice positions [x y z] for the 3D plots on a scale from 0 to 1
% model.HS.tempSensorPositions = [0 0 0.038
%                                 0 0 0.04
%                                 0 0 0.042
%                                 0 0 0.044]; % Each row is a temperature sensor's absolute [x y z] coordinates. Leave the matrix empty ([]) to disable temperature sensors.
% 
% % Execution, do not modify the next line:
% model = simulateHeatDistribution(model);
% 
% plotMCmatlabHeat(model);

%% Post-processing

%% Geometry function(s)
% A geometry function takes as input X,Y,Z matrices as returned by the
% "ndgrid" MATLAB function as well as any parameters the user may have
% provided in the definition of Ginput. It returns the media matrix M,
% containing numerical values indicating the media type (as defined in
% mediaPropertiesFunc) at each voxel location.
function M = geometryDefinition_BloodVessel(X,Y,Z,parameters)
% Blood vessel example:
global zsurf;
%zsurf = 0.01;  % changed from 0.001;
epd_thick = 0.02;
derm_thick1 = 0.02;
derm_thick2 = 0.02;
derm_thick3 = 0.08;
derm_thick4 = 0.06;
vesselradius  = 0.0100;
vesseldepth = 0.040;
M = ones(size(X)); % fill background with water (gel)
M(Z <= zsurf & Y < 0.05 & Y > -0.05 & X < 0.05 & X > -0.05) = 8; % absorber 
M(Z > zsurf) = 2; % epidermis
M(Z > zsurf + epd_thick) = 3; % dermis
M(Z > zsurf + epd_thick+derm_thick1) = 4; % dermis1
M(Z > zsurf + epd_thick+derm_thick1+derm_thick2) = 5; % dermis1
M(Z > zsurf + epd_thick+derm_thick1+derm_thick2+derm_thick3) = 6; % dermis1
M(Z > zsurf + epd_thick+derm_thick1+derm_thick2+derm_thick3+derm_thick4) = 7; % dermis1
%M(X.^2 + (Z - (zsurf + vesseldepth)).^2 < vesselradius^2) = 4; % blood
end

%% Media Properties function
% The media properties function defines all the optical and thermal
% properties of the media involved by constructing and returning a
% "mediaProperties" struct with various fields. As its input, the function
% takes the wavelength as well as any other parameters you might specify
% above in the model file, for example parameters that you might loop over
% in a for loop. Dependence on excitation fluence rate FR, temperature T or
% fractional heat damage FD can be specified as in examples 12-15.
function mediaProperties = mediaPropertiesFunc(wavelength,parameters)
load spectralLIB.mat
load plethy1.mat
 persistent ii;
 if isempty(ii)
     ii = 0; %0.45
 end
 ii = ii+1;
MU(:,1) = interp1(nmLIB,muaoxy,wavelength);
MU(:,2) = interp1(nmLIB,muadeoxy,wavelength);
MU(:,3) = interp1(nmLIB,muawater,wavelength);
MU(:,4) = interp1(nmLIB,muamel,wavelength);

j=1;
mediaProperties(j).name  = 'air';
mediaProperties(j).mua   = 1e-8;
mediaProperties(j).mus   = 1e-8;
mediaProperties(j).g     = 1;
mediaProperties(j).n     = 1;
mediaProperties(j).VHC   = 1.2e-3;
mediaProperties(j).TC    = 0; % Real value is 2.6e-4, but we set it to zero to neglect the heat transport to air

j=2;
mediaProperties(j).name  = 'Epidermis';
B = 0;
S = 0.95;
W = 0.4;%0.75;
Me = 0.003;%0.03;
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

j=3;
mediaProperties(j).name = 'Dermis (non perfused)';
B = 0;%0.04;%*1.15;%*(1+b1(ii)*0.15);%0.03;%0.002;
S = 0.95;
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

j=4;
mediaProperties(j).name = 'Papillary plexus';
B = 0.0556;%*1.15;%*(1+b1(ii)*0.15);%0.03;%0.002;
S = 0.95;
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

j=5;
mediaProperties(j).name = 'Dermis (perfused)';
B = 0.0417;  %*1.15;%*(1+b1(ii)*0.15);%0.03;%0.002;
S = 0.95;
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
mediaProperties(j).name = 'Cutaneous plexus';
B = 0.2037+b1(ii)*(0.2454-0.2037);% dia 0.2037 %sys 0.2454 %*1.15;%*(1+b1(ii)*0.15);%0.03;%0.002;
S = 0.95;
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

j=7;
mediaProperties(j).name = 'Hypodermis';
B = 0.0417;% dia 0.2037 %sys 0.2454 %*1.15;%*(1+b1(ii)*0.15);%0.03;%0.002;
S = 0.95;
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

j=8;
mediaProperties(j).name  = 'barrier';
mediaProperties(j).mua = 2;
mediaProperties(j).mus = 100;
mediaProperties(j).g   = 0.9;
mediaProperties(j).n     = 1.3;
mediaProperties(j).VHC   = 1.2e-3;
mediaProperties(j).TC    = 0;
% mediaProperties(j).name  = 'blood';
% B       = 1.00;
% S       = 0.75;
% W       = 0.95;
% Me      = 0;
% musp500 = 10;
% fray    = 0.0;
% bmie    = 1.0;
% gg      = 0.90;
% musp = musp500*(fray*(wavelength/500).^-4 + (1-fray)*(wavelength/500).^-bmie);
% X = [B*S B*(1-S) W Me]';
% mediaProperties(j).mua = MU*X;
% mediaProperties(j).mus = musp/(1-gg);
% mediaProperties(j).g   = gg;
% mediaProperties(j).n   = 1.3;
% mediaProperties(j).VHC = 3617*1.050e-3;
% mediaProperties(j).TC  = 0.52e-2;
% mediaProperties(j).E   = 422.5e3; % J/mol    PLACEHOLDER DATA ONLY
% mediaProperties(j).A   = 7.6e66; % 1/s        PLACEHOLDER DATA ONLY
end