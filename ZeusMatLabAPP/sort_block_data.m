function [data, nextpos] = sort_block_data(fid, chan, bpos, epos, type)
% 整理指定通道，给定位置范围与选定类型的数据为nsamples*chan矩阵

data = [];
nextpos = 0;

if nargin < 5, type = 5; end
if nargin < 4, fseek(fid, 0, 'eof'); epos = ftell(fid); end

valid = is_valid_block_header(read_block_header(fid, bpos));
if isempty(valid)
    return
elseif ~valid
    bpos = find_block_start(fid, bpos, 1);
end
epos = find_block_start(fid, epos, -1);
chan_num = length(chan);

temp = [];
fseek(fid, bpos, 'bof');
while ftell(fid) < epos
    
    db = read_data_block(fid);
%     if size(db.waveforms, 1) > max
%         max = size(db.waveforms, 1);
%         disp(max);
%     end    
    
    [tf, idx] = ismember(db.header.Channel, chan);
    
    if db.header.Type == type && tf
        if ~isempty(temp)
            temp = [temp, db.waveforms];
        end
        if idx == 1
            temp = db.waveforms;
        end
        if idx == chan_num
            data = [data; temp];
            temp = [];
            nextpos = ftell(fid);
        end
    end
end

end