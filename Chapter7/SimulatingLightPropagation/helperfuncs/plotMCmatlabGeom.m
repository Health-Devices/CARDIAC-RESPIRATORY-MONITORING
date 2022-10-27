function plotMCmatlabGeom(model)
%   Displays
%       Geometry cuboid
%       Media optical, thermal and fluorescence properties
%
%   Requires
%       plotVolumetric.m
%       plotMediaProperties.m
%
%	See also defineGeometry

%%%%%
%   Copyright 2017, 2018 by Dominik Marti and Anders K. Hansen, DTU Fotonik
%   This function was inspired by lookmcxyz.m of the mcxyz MC program hosted at omlc.org
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

%% Make geometry plot
mediaProperties = model.G.mediaPropertiesFunc(NaN,model.G.mediaPropParams); % We don't know what wavelength the user wants yet, so we just input NaN
h_f = plotVolumetric(1,model.G.x,model.G.y,model.G.z,model.G.M_raw,'MCmatlab_GeometryIllustration',mediaProperties);
h_f.Name = 'Geometry illustration';
title('Geometry illustration');

drawnow;
end
