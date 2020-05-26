function [header, data, tmp] = readHTK(inputFileName)
% READHTKHEADER - Read the header of a file in HTK format
% 
%   [header, data] = readHTK(inputFileName)
%   
% Description:
% Follow the guidelines in HTKBook and read the header of an
% HTK-formatted file. 
% Input Arguments:
% 
% Output Arguments:
% 
% Example: 
% 
% Project: HTK tools
% See also: 
%   
 
% Copyright: Nassos Katsamanis, CVSP Group, NTUA
% URL: http://cvsp.cs.ntua.gr/~nassos
% Created: 04/07/2005
fid = fopen(inputFileName);
if fid==-1 
  error(['Cannot open ', inputFileName]);
end

nSamples = fread(fid, 1, 'int32'); %365
sampPeriod = fread(fid, 1, 'int32'); %5000
sampSize = fread(fid, 1, 'int16'); %444
parmKind = fread(fid, 1, 'int16'); %MFCC
%qualifier = fread(fid, 1, 'int8');

header.nSamples = nSamples;
header.sPeriod = sampPeriod;
header.sampSize = sampSize;
header.parmKind = parmKind;
%header.qualifier = qualifier;



tmp = fread(fid, Inf, 'float32');
% inputFileName
% size(tmp)
% sampSize/4
% nSamples

data = reshape(tmp, sampSize/4, nSamples);

