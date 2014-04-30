function [mean,variance] = GetPosteriorMeanVariance(M,drop)

% Copyright (C) 2012, 2013 Dynare Team
%
% This file is part of Dynare.
%
% Dynare is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% Dynare is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with Dynare.  If not, see <http://www.gnu.org/licenses/>.
    
    MetropolisFolder = CheckPath('metropolis',M.dname);
    FileName = M.fname;
    BaseName = [MetropolisFolder filesep FileName];
    load_last_mh_history_file(MetropolisFolder, FileName);
    NbrDraws = sum(record.MhDraws(:,1));
    NbrFiles = sum(record.MhDraws(:,2));
    NbrBlocks = record.Nblck;
    mean = 0;
    variance = 0;
    z = [];
    
    nkept = 0;
    for i=1:NbrBlocks
        n = 0;
        for j=1:NbrFiles
            o = load([BaseName '_mh' int2str(j) '_blck' int2str(i)]);
            m = size(o.x2,1);
            if n + m < drop*NbrDraws
                n = n + m;
                continue
            elseif n < drop*NbrDraws
                k = ceil(drop*NbrDraws - n + 1);
                x2 = o.x2(k:end,:);
            else
                x2 = o.x2;
            end
            z =[z; x2];        
            p = size(x2,1);
            mean = (nkept*mean + sum(x2)')/(nkept+p);
            x = bsxfun(@minus,x2,mean');
            variance = (nkept*variance + x'*x)/(nkept+p);
            n = n + m;
            nkept = nkept + p;
        end
    end
