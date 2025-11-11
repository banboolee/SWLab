function p_value = sdgseakpara(responseparts, para)

idx = find(contains(responseparts, para), 1);
if isempty(idx)
    p_value = NaN;
else
    if strcmp(para, 'WVTP')
        p_value = strtrim(responseparts{idx+1});
    else
        p_value = str2onlynum(strtrim(responseparts{idx+1}));
    end
end
end