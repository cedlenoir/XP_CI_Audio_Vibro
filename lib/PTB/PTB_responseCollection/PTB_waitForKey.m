function idx=waitForKey(allowed_keys)

KbQueueFlush();
idx=0;
while ~ismember(idx,allowed_keys)
    [~,pressed] = KbPressWait();
    pressed(pressed==0) = nan;
    [~,idx] = min(pressed);
end    
KbReleaseWait