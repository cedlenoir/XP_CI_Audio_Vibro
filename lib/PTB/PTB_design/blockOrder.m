function resOrder = blockOrder(participantID,nConditions,varargin)

if any(strcmpi(varargin,'rand'))
    resOrder = randperm(nConditions);
    disp(sprintf('\n...using random block order...\n'));
    
    
elseif any(strcmpi(varargin,'full'))
    if nConditions>4
        error('you fool, too many conditions for full counterbalancing!')
    end
    allOrders = perms([1:nConditions]);
    tmp = mod(participantID,size(allOrders,1));
    if tmp==0
        tmp = size(allOrders,1);
    end    
    resOrder = allOrders(tmp,:);
    
    
    
elseif any(strcmpi(varargin,'latin'))
    allOrders = balLatSquare(nConditions);
    tmp = mod(participantID, size(allOrders,1));
    if tmp==0
        tmp = size(allOrders,1);
    end    
    resOrder = allOrders(tmp,:);
    
 
    
    
elseif any(strcmpi(varargin,'rand_restricted'))
    resOrder = [ 1:nConditions ];
    while (any(resOrder(1:3)==1) & any(resOrder(1:3)==2) & any(resOrder(1:3)==3)) | (any(resOrder(1:3)==4) & any(resOrder(1:3)==5) & any(resOrder(1:3)==6))
        resOrder = randperm(nConditions);
    end
    
    disp(sprintf('\n...using random block order with resriction...\n'));

    
end
