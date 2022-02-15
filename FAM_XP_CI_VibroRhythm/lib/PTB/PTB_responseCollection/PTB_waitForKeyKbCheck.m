function idx=waitForKeyKbCheck(allowed_keys)

% ~KbWait checks with lazy loop (5ms interrupts for CPU)
idx=0;
KbReleaseWait; 
while ~ismember(idx,allowed_keys)
        [secs, key_code] = KbWait(-1);
        idx = find(key_code); 
end    
KbReleaseWait; 