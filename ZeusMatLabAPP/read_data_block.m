function db = read_data_block(fid, pos)
% 读取当前位置的一个数据块

if nargin==2, fseek(fid, pos, 'bof'); end
% ---- header ----
% The header for the data record used in the datafile (*.plx)
% This is followed by NumberOfWaveforms*NumberOfWordsInWaveform
% short integers that represent the waveform(s)
db.header = read_block_header(fid);
% ---- waveforms ----
nSamp = double(db.header.NumWF) * double(db.header.WFWords);
if nSamp > 0
    db.waveforms = fread(fid, nSamp, 'int16=>int16');
else
    db.waveforms = [];
end

end
