function clear_all_but(varargin)
%% <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><> %%
% <><><><><><>         Clear All But Some Variables         <><><><><><> %
% <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><> %
%                                                 Version:    16.09.2009 %
%                                                     (c) Roland Pfister %
%                                             roland_pfister@t-online.de %
% 1. Synopsis                                                            %
%                                                                        %
% The workspace is cleared as if the 'clear all' command was used but it %
% is possible to keep some of your most beloved variables. Simply enter  %
% these variables as input arguments.                                    %
%                                                                        %
% 2. Example                                                             %
%                                                                        %
% The command "clear_all_but('var_a','var_b')" clears all variables but  %
% var_a and var_b.                                                       %
%                                                                        %
% <><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><> %



%% Get a list of workspace variables.
workspace_variables = evalin('caller','who');



%% Go through the list...
for workspace_index_1 = 1:size(workspace_variables,1)
    workspace_index_3 = 0;
    % ... and check whether the current variable  
    % name is among the input arguments.
    for workspace_index_2 = 1:nargin
        if strcmp(workspace_variables{workspace_index_1,1},...
           varargin{1,workspace_index_2}) == 1
            workspace_index_3 = 1;
        end;
    end;
    % If it's not: clear.
    if workspace_index_3 == 0
        workspace_index_4 = ['clear(' char(39) ...
            workspace_variables{workspace_index_1,1} char(39) ')'];
        evalin('base',workspace_index_4);
    end;
end;



%% Cleaning up the function workspace.
clear workspace_variables;
clear workspace_index_1;
clear workspace_index_2;
clear workspace_index_3;
clear workspace_index_4;



end
