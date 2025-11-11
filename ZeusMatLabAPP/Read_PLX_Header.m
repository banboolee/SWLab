function [PL_FileHeader, PL_ChanHeader, PL_EventHeader, PL_SlowChannelHeader] = Read_PLX_Header(fid)
% 读取plx文件的文件头与通道头
%% --------- 文件头 (PL_FileHeader) ---------
PL_FileHeader.MagicNumber = fread(fid,1,'uint32');
PL_FileHeader.Version     = fread(fid,1,'int32');
PL_FileHeader.Comment     = fread(fid,128,'*char')';

PL_FileHeader.ADFrequency      = fread(fid,1,'int32');
PL_FileHeader.NumDSPChannels   = fread(fid,1,'int32');
PL_FileHeader.NumEventChannels = fread(fid,1,'int32');
PL_FileHeader.NumSlowChannels  = fread(fid,1,'int32');
PL_FileHeader.NumPointsWave    = fread(fid,1,'int32');
PL_FileHeader.NumPointsPreThr  = fread(fid,1,'int32');

PL_FileHeader.Year   = fread(fid,1,'int32');
PL_FileHeader.Month  = fread(fid,1,'int32');
PL_FileHeader.Day    = fread(fid,1,'int32');
PL_FileHeader.Hour   = fread(fid,1,'int32');
PL_FileHeader.Minute = fread(fid,1,'int32');
PL_FileHeader.Second = fread(fid,1,'int32');

PL_FileHeader.FastRead     = fread(fid,1,'int32');
PL_FileHeader.WaveformFreq = fread(fid,1,'int32');
PL_FileHeader.LastTimestamp= fread(fid,1,'double');

if PL_FileHeader.Version >= 103
    PL_FileHeader.Trodalness         = fread(fid,1,'int8');
    PL_FileHeader.DataTrodalness     = fread(fid,1,'int8');
    PL_FileHeader.BitsPerSpikeSample = fread(fid,1,'int8');
    PL_FileHeader.BitsPerSlowSample  = fread(fid,1,'int8');
    PL_FileHeader.SpikeMaxMagnitudeMV= fread(fid,1,'uint16');
    PL_FileHeader.SlowMaxMagnitudeMV = fread(fid,1,'uint16');
else
    fseek(fid,8,'cof');
end

if PL_FileHeader.Version >= 105
    PL_FileHeader.SpikePreAmpGain = fread(fid,1,'uint16');
else
    fseek(fid,2,'cof');    
end

if PL_FileHeader.Version >= 106
    PL_FileHeader.AcquiringSoftware  = fread(fid,18,'*char')';
    PL_FileHeader.ProcessingSoftware = fread(fid,18,'*char')';
else
    fseek(fid,36,'cof');
end

PL_FileHeader.Padding = fread(fid,10,'*char')';

PL_FileHeader.TSCounts = fread(fid,[5,130],'int32')'; % 130x5
PL_FileHeader.WFCounts = fread(fid,[5,130],'int32')'; % 130x5
PL_FileHeader.EVCounts = fread(fid,512,'int32');

%% --------- Spike Channel Headers (PL_ChanHeader) ---------
chanTemplate = struct( ...
    'Name','', 'SIGName','', 'Channel',[], 'WFRate',[], 'SIG',[], 'Ref',[], ...
    'Gain',[], 'Filter',[], 'Threshold',[], 'Method',[], 'NUnits',[], ...
    'Template',[], 'Fit',[], 'SortWidth',[], 'Boxes',[], 'SortBeg',[], ...
    'Comment','', 'SrcId',[], 'reserved',[], 'ChanId',[], 'Padding',[]);

PL_ChanHeader = repmat(chanTemplate, PL_FileHeader.NumDSPChannels, 1);

for i=1:PL_FileHeader.NumDSPChannels
    ch.Name    = deblank(fread(fid,32,'*char')');
    ch.SIGName = deblank(fread(fid,32,'*char')');
    % ch.SIGName = deblank(char(fread(fid,32,'*char')'));
    ch.Channel = fread(fid,1,'int32');
    ch.WFRate  = fread(fid,1,'int32');
    ch.SIG     = fread(fid,1,'int32');
    ch.Ref     = fread(fid,1,'int32');
    ch.Gain    = fread(fid,1,'int32');
    ch.Filter  = fread(fid,1,'int32');
    ch.Threshold = fread(fid,1,'int32');
    ch.Method    = fread(fid,1,'int32');
    ch.NUnits    = fread(fid,1,'int32');

    % ---- Template[5][64] ----
    tmp = fread(fid, 5*64, 'int16');
    if numel(tmp) ~= 5*64, error('EOF while reading Template'); end
    ch.Template = reshape(tmp,64,5)'; % 5x64

    ch.Fit       = fread(fid,5,'int32');
    ch.SortWidth = fread(fid,1,'int32');

    % ---- Boxes[5][2][4] ----
    tmp = fread(fid,5*2*4,'int16');
    if numel(tmp) ~= 40, error('EOF while reading Boxes'); end
    ch.Boxes = permute(reshape(tmp,4,2,5),[3,2,1]); % 5x2x4

    ch.SortBeg   = fread(fid,1,'int32');
    ch.Comment   = deblank(fread(fid,128,'*char')');
    ch.SrcId     = fread(fid,1,'uint8');
    ch.reserved  = fread(fid,1,'uint8');
    ch.ChanId    = fread(fid,1,'uint16');
    ch.Padding   = fread(fid,10,'int32');

    PL_ChanHeader(i) = ch;
end

%% --------- Event Channel Headers (PL_EventHeader) ---------
eventTemplate = struct('Name','', 'Channel',[], 'Comment','', 'SrcId',[], 'reserved',[], 'ChanId',[], 'Padding',[]);
PL_EventHeader = repmat(eventTemplate, PL_FileHeader.NumEventChannels, 1);

for i=1:PL_FileHeader.NumEventChannels
    ev.Name    = deblank(fread(fid,32,'*char')');
    ev.Channel = fread(fid,1,'int32');
    ev.Comment = deblank(fread(fid,128,'*char')');
    ev.SrcId   = fread(fid,1,'uint8');
    ev.reserved= fread(fid,1,'uint8');
    ev.ChanId  = fread(fid,1,'uint16');
    ev.Padding = fread(fid,32,'int32');

    PL_EventHeader(i) = ev;
end

%% --------- Slow Channel Headers (PL_SlowChannelHeader) ---------
slowTemplate = struct('Name','', 'Channel',[], 'ADFreq',[], 'Gain',[], 'Enabled',[], ...
                      'PreAmpGain',[], 'SpikeChannel',[], 'Comment','', ...
                      'SrcId',[], 'reserved',[], 'ChanId',[], 'Padding',[]);
PL_SlowChannelHeader = repmat(slowTemplate, PL_FileHeader.NumSlowChannels, 1);

for i=1:PL_FileHeader.NumSlowChannels
    sl.Name   = deblank(fread(fid,32,'*char')');
    sl.Channel= fread(fid,1,'int32');
    sl.ADFreq = fread(fid,1,'int32');
    sl.Gain   = fread(fid,1,'int32');
    sl.Enabled= fread(fid,1,'int32');
    sl.PreAmpGain = fread(fid,1,'int32');
    sl.SpikeChannel = fread(fid,1,'int32');
    sl.Comment = deblank(fread(fid,128,'*char')');
    sl.SrcId   = fread(fid,1,'uint8');
    sl.reserved= fread(fid,1,'uint8');
    sl.ChanId  = fread(fid,1,'uint16');
    sl.Padding = fread(fid,27,'int32');

    PL_SlowChannelHeader(i) = sl;
end

%% 数据起始位置
PL_FileHeader.DataStart = ftell(fid);
% fclose(fid);
end
