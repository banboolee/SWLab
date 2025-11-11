function val = str2onlynum(str)

token = regexp(str, '[\d\.eE\+\-]+', 'match', 'once');
if isempty(token)
    val = NaN;
else
    val = str2double(token);
end
end