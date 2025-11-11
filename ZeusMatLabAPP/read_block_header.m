function db_header = read_block_header(fid, pos)
% 读取当前位置数据块header

if nargin == 2, fseek(fid, pos, 'bof'); end

db_header.Type = fread(fid, 1, 'int16=>int16');
db_header.UpperTimestamp = fread(fid, 1, 'uint16=>uint16');
db_header.TimeStamp = fread(fid, 1, 'uint32=>uint32');
db_header.Channel = fread(fid,1,'int16=>int16');
db_header.Unit = fread(fid,1,'int16=>int16');
db_header.NumWF = fread(fid,1,'int16=>int16');
db_header.WFWords = fread(fid,1,'int16=>int16');

end