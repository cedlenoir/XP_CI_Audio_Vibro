initializePsychtoolbox('tapping')

keyCode = 20;
while find(keyCode)~=44
    tmp = ('kokot');
    DrawFormattedText(win,tmp,'center','center',[1 1 1]);
    Screen('Flip',win); 
    WaitSecs(1)
    tmp = ('Press [1] or [2] to play the sound again. \n\n\n Press [SPACE] to end the practice block.');
    DrawFormattedText(win,tmp,'center','center',[1 1 1]);
    Screen('Flip',win); 
    [~, keyCode, ~] = KbStrokeWait();
end
closePsychtoolbox()






t = 0:1/44100:2;
s = zeros(size(t));
s(44100:44500) = 1;
sound(s,44100)




res = perms([1:4]);
tmp = zeros(size(res,1),size(res,1))
for i=1:size(res,1)
    for j=1:size(res,1)
        if i==j
            tmp(i,j) = 0;
        elseif isequal(res(i,:),res(j,:))
            tmp(i,j) = 1;
        end
    end
end
           
            
        