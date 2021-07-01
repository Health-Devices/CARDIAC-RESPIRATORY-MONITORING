function [CI, funcVal, MCfuncVals, MCsamples]= propUncertMC(func,dists,N,varargin)
% propUncertMC() propagates uncertanity through the function 'func' using Monte Carlo
% simulation. 'func' is a function of variables whose samples are drawn from 
% the distributions listed in 'dists'. propUncertMC() supports correlated 
% distributions, various bootstrapping methods, distribution fitting,
% truncated distributions, and custom sample inputs.

% INPUTS:
%   func            Function handle of the function to combine samples through
%                   (func must be vectorizable so use .*, ./ and .^ instead of *, /, and ^)
%   dists           Vertical cell array of cell arrays containing params for each distribution
%   N               Number of samples to generate from each distribution
%   'CI',value      (Optional) Value to use for pseudo CI threshold. Default is 0.68.
%   'hist',nBins    (Optional) Plot histogram of the function outputs. nBins value is optional
%   'varHist',nBins (Optional) Plot histograms of each sample. nBins value is optional.
%   'mean' or 'median' or 'max' or min'
%                   (Optional) Specify one of these to determine what value 
%                    to return for 'funcVal'. Default is the center of the CI inteval.
%
%   For each cell array inside 'dists' the syntax is:
%       {'DistributionType',param_1,...,paramN[,'truncate',lowerBound,upperBound]}
%   where the truncation arguments inside the square brackets are optional.
%   If 'DistributionType' is omitted then the default will be a normal
%   distribution.
%
%   A list of supported distributions and their parameters can be found here:
%       https://www.mathworks.com/help/stats/supported-distributions.html
%   'Custom', 'Bootstrap', 'BootstrapMean', 'Fit' and 'Corr' are  additional 
%   options for 'DistributionType'. To see more about them examine the 
%   related comments in the code below and look in 'uncert_prop_examples.m'.

% OUTPUTS: 
%   CI          Vector containing the lowerbound and upperbound of the pseudo CI interval.
%               (this is the shortest interval which contains X percent of the function outputs)
%   funcVal     Calculated function value. Defaults to center of CI. Can be mean,median,or max/min.
%   MCfuncVals  Vector of the function outputs.
%   MCsamples   Array containing the samples from each distribution.

% %EXAMPLE
% % Use the ideal gas law (P=rho*R*T) to find the uncertanity in the density 
% % of air given a measured pressure of 100 +/- 1 kPa and temperature of 
% % 300 +/- 3 Kelvin. No uncertanity in the gas law constant R (kJ/(kg*Kelvin)).
%
% P = 100; T = 300; uP = 1; uT = 3;      
% R = 0.287;
%       
% rho = @(press,temp)press./(R*temp);
% [CI,funcVal] = propUncertMC(rho,{{P,uP};{T,uT}},100000)
% uncert = (CI(2)-CI(1))/2
% 
% % For more detailed examples, including correlated distributions,
% % optional arguments, truncation, bootstrapping, and other sampling
% % methods, see the file 'uncert_prop_examples.m'.
% Joe Klebba, 3/2021

%% Parse varargin to handle optional arguments
%Init defaults
if (~exist('N', 'var'))
   N=100000; 
end
confInterval = 0.68; 
meanFlag=0; medianFlag=0; maxFlag=0; minFlag=0;
histFlag=0; histBins=40;
varHistFlag = 0; varHistBins=40;

for vaIdx = 1:length(varargin)
    currArg = varargin{vaIdx};
    notLastArg = vaIdx~=length(varargin);
    switch(currArg)
        case {'mean','Mean'}
            meanFlag=1;
        case {'median','Median'}
            medianFlag=1;
        case {'max','Max'}
            maxFlag=1;
        case {'min','Min'}
            minFlag=1;
        case {'hist','Hist'}
            histFlag=1;
            if notLastArg && ~ischar(varargin{vaIdx+1})
                histBins=varargin{vaIdx+1};
            end
        case {'varHist','VarHist','varhist','Varhist'}
            varHistFlag=1;
            if notLastArg && ~ischar(varargin{vaIdx+1})
                varHistBins=varargin{vaIdx+1};
            end
        case {'CI','Ci','ci'}
            if notLastArg && ~ischar(varargin{vaIdx+1})
                confInterval=varargin{vaIdx+1};
            else
                disp('simulateMC(): Value is missing from ''CI'' name-value pair.')
            end
        otherwise
            if ischar(currArg)
                disp("propUncertMC(): The string '"+currArg+"' in the function parameters was not recognized as a valid option.")
            end
    end
end

%% Generate & Store Samples From the Specified Distributions
distIdx=0;
sampIdx=0;
while(distIdx < size(dists,1))
    distIdx=distIdx+1;
    sampIdx=sampIdx+1;
    distType = dists{distIdx}{1};
    switch(distType)
        case {'Bootstrap','bootstrap'}
            %Bootstrap a sample of size N from user provided data.
            %Syntax is:  {'Bootstrap',datavec}
            data=dists{distIdx}{2};
            [rown,coln]=size(data);
            if coln~=1
                data=transpose(data);
            end
            sampledVars{sampIdx} =  randsample(data,N,true);
        case {'BootstrapMean','bootstrapMean','Bootstrapmean','bootstrapmean'}
            %Boostrap an approximate distribution of the sample mean of
            %user provided data.
            %Syntax is:  {'BootstrapMean',datavec}
            data=dists{distIdx}{2};
            [rown,coln]=size(data);
            if coln~=1
                data=transpose(data);
            end
            means=zeros(N,1);
            for i=1:N
                means(i)=mean(randsample(data,length(data),true));
            end
            sampledVars{sampIdx} = means;
        
        case {'Corr','corr'}
            %Use an iteratively optimized gaussian copula to generate 
            %correlated samples from the specified distributions.
            %Syntax is:  {'Corr',distParamLists,PearsonCorrelationMatrix,tolerance}
            
            %The tolerance parameter is optional. The default tolerance value 
            %specifies a maximum error of 1% in the correlation matrix of 
            %the generated samples.
            corrDistParams=dists{distIdx}{2};
            numDists = length(corrDistParams);
            for i=1:numDists
                corrDists(i)=getDistribution(corrDistParams{i});
            end
            
            corrMatGoal = dists{distIdx}{3};
            if length(dists{distIdx})>3
                tol = dists{distIdx}{4};
            else
                tol = 0.01;
            end
            
            %Iteratively optimize the copula's correlation matrix until the 
            % correlation matrix of the resulting samples is within tolerance.
            maxErrorAbs=1;
            corrMat=corrMatGoal;
            means = zeros(1,numDists);
            alpha = 0.1;    %iterative update ratio, adjusting alpha may improve convergence
            seed = clock; seed=seed(5)*seed(6)^2*rem(seed(5),seed(6));
            maxIters=10000; count=0;
            while maxErrorAbs>tol
                rng(seed)  %using the same rng seed each iteration can aid convergence
                copula = mvnrnd(means,corrMat,N);
                copula = normcdf(copula);
                samps = zeros(N,numDists);
                for i=1:numDists
                    samps(:,i) = icdf(corrDists(i),copula(:,i));
                end
                corrErrorMat = (corrMatGoal-corr(samps))./corrMatGoal;
                maxErrorAbs=max(max(abs(corrErrorMat)));
                [rownum,colnum]=find(abs(corrErrorMat)==maxErrorAbs);
                maxError = corrErrorMat(rownum(1),colnum(1));
                corrMat(rownum(1),colnum(1))=(1+(maxError*alpha))*(corrMat(rownum(1),colnum(1)));
                corrMat(colnum(1),rownum(1))=(1+(maxError*alpha))*(corrMat(colnum(1),rownum(1)));
                %TODO: Implement a check to ensure corrMat can't be
                %repeatedly updated in the wrong direction. 
                count=count+1;
                if count>maxIters
                   disp("propUncertMC(): The correlated samples were not obtained within tolerance in "+maxIters+" iterations.")
                   return
                end
            end
            for i=1:numDists
                sampledVars{sampIdx+i-1} = samps(:,i);
            end
            sampIdx = sampIdx + numDists - 1;  
            
        case {'Custom','custom'}
            %Let the user provide the data sample
            %Syntax is: {'Custom',datavec}
            data = dists{distIdx}{2};
            [rown,coln]=size(data);
            if coln~=1
                data=transpose(data);
            end
            [rown,coln]=size(data);
            if rown~=N
                disp("propUncertMC(): The length of the custom sample must equal the PropUncertMC parameter 'N'.")
                return
            end
            sampledVars{sampIdx} = data;
        case {'Fit','fit'}
            %Fits the specified type of distribution to user provided data
            %and generates a sample of length N from the fitted distribution.
            %Syntax is: {'Fit','DistributionType',data}
            fittedDist= fitdist(dists{distIdx}{3},dists{distIdx}{2});
            sampledVars{sampIdx} = getSamples(fittedDist,N);
        case {'Uniform','uniform'}
            %Enables uniform samples to be generated without the need for 
            %the Statistics and Machine Learning Toolbox.
            %Syntax is: {'Uniform',upperbound,lowerbound}
            sampledVars{sampIdx} = dists{distIdx}{2} + (dists{distIdx}{3}-dists{distIdx}{2})*rand(N,1);
        otherwise
            %Sample a distribution specified by the distribution params
            %Syntax is: {'DistributionName',param_1, ... ,param_n}
            
            %You can also specify a truncated distribution like so:
            % {'DistributionType',param_1, ... ,param_n,'trunc',lowerCutOff,upperCutOff}
            
            if ~ischar(distType)
                %If no distribution type is specified then assume normal
                dists{distIdx}=horzcat('Normal',dists{distIdx});
                distType = 'Normal';
            end
            if strcmp(distType,'Normal') || strcmp(distType,'normal')
                %Enables normal samples to be generated without the need
                %for the Statistics and ML toolbox.
                truncIdx=getTruncIdx(dists{distIdx});
                if truncIdx<1
                    sampledVars{sampIdx} = dists{distIdx}{2} + dists{distIdx}{3}*randn(N,1);
                else
                    sampledVars{sampIdx} = getTruncatedNormals(dists{distIdx}{2},dists{distIdx}{3},dists{distIdx}{truncIdx+1},dists{distIdx}{truncIdx+2},N);
                end
            else
                
            %Handles the sampling for distributions besides normal and
            %uniform.
            sampledVars{sampIdx} = getSamples(getDistribution(dists{distIdx}),N);
            end
    end
end


%% Evaluate Function & Get Descriptors
MCsamples=cell2mat(sampledVars);
MCfuncVals=func(sampledVars{:});

%Find smallest interval containing 'confInterval' of the values
sorted = sort(MCfuncVals);
range = ceil(confInterval*length(sorted));
smallestInterval = inf;
bottom=-inf; top=inf;
for idxLow = 1:length(sorted)
   idxHigh = idxLow+range;
   if idxHigh > length(sorted)
       break
   end
   low = sorted(idxLow);
   high = sorted(idxHigh);
   if (high-low)<smallestInterval
       bottom = low; top = high;
       smallestInterval = high-low;
   end
end
CI = [bottom top];
if (1-confInterval)*length(sorted) < 1000
   recomm = floor(1000/(1-confInterval));
   disp("propUncertMC(): Recommended to use at least "+recomm+" samples for a CI interval this large")
end

% Set funcVal as specified by the optional arguments
if meanFlag
    funcVal = mean(MCfuncVals);
elseif medianFlag
    funcVal = median(MCfuncVals);
elseif maxFlag
    funcVal = max(MCfuncVals);
elseif minFlag
    funcVal=min(MCfuncVals);
else
    funcVal = mean(CI);
end

%% Plot histograms as specified by the optional arguments
if varHistFlag
    colN=ceil(sqrt(sampIdx));
    rowN = ceil(sampIdx/colN);
    figure
    for pIdx = 1:sampIdx
        subplot(rowN,colN,pIdx);
        hist(cell2mat(sampledVars(:,pIdx)),varHistBins);
        title("Var "+pIdx)
    end
    sgtitle('Histogram Of MC Samples For Each Variable')
end

if histFlag
    figure
    hist(MCfuncVals,histBins)
    title('Histogram Of MC Function Values')
end


%% Helper Functions
    function distrib = getDistribution(input)        
        if ~ischar(input{1})
            %assume normal if not specified
            input=horzcat('Normal',input);
        end
        
        %truncate distribution if neccesary
        truncInd=getTruncIdx(input);        
        if truncInd<1
            distrib = makedist(input{:});
        else
            distrib = makedist(input{1:truncInd-1});
            distrib = truncate(distrib, input{truncInd+1},input{truncInd+2});
        end
    end
        
    
    function tIdx = getTruncIdx(list)
        tIdx=0;
        truncWords = {'t' 'T' 'Trunc' 'Truncate' 'trunc' 'truncate'};
        for idx = 1:length(list)
            if any(strcmp(list{idx},truncWords))
                tIdx = idx;
            end
        end
    end


    function samples = getSamples(distrib,num)
        samples = random(distrib,num,1);
    end


    function tNorm = getTruncatedNormals(Mu,Sigma,lowerBound,upperBound,n)
            tNorm =  Mu + Sigma*randn(n,1);
            tooHigh=numel(tNorm(tNorm>upperBound)); 
            tooLow=numel(tNorm(tNorm<lowerBound));
            while(tooHigh>0 || tooLow>0)
                if(tooHigh>0)
                    tNorm(tNorm>upperBound) = Mu + Sigma*randn(numel(tNorm(tNorm>upperBound)),1);
                end
                if(tooLow>0)
                    tNorm(tNorm<lowerBound) = Mu + Sigma*randn(numel(tNorm(tNorm<lowerBound)),1);
                end
                tooHigh=numel(tNorm(tNorm>upperBound));
                tooLow=numel(tNorm(tNorm<lowerBound));
            end
    end
end
    
        
        