function block_start = find_block_start(fid, pos, direction, range)
% 查找datablock区域内指定位置附近的第一个block的起始位置

if nargin < 4, range = 256; end % 未记录raw或者spike数据可以更改为80
if nargin < 3, direction = 1; end
if nargin < 2, pos = ftell(fid); end

if direction == -1, pos = (pos - 16); end
for p = pos : direction : pos + direction * range
    hdr = read_block_header(fid, p);
    if is_valid_block_header(hdr)
        block_start = p;
        return
    end
end

error('Cannot Find Valid Data Block Start Position');

end