function res=trialOrder(n_trials_per_cond,c_cond,method, varargin)




if any(strcmpi(method,'shake_all'))
        res = repmat(1:c_cond,1,n_trials_per_cond);
        res = res(randperm(length(res)));
        while any(diff(res)==0)
            res = res(randperm(length(res)));
        end
        
elseif any(strcmpi(method,'shake_parts'))
    res = zeros(1,n_trials_per_cond*c_cond);
    res(1:c_cond) = randperm(c_cond);
    for i=1:n_trials_per_cond-1
        tmp = randperm(c_cond);
        while tmp(1)==res(i*c_cond)
            tmp = randperm(c_cond);
        end
        res(i*c_cond+1:(i+1)*c_cond) = tmp;
    end
    
elseif any(strcmpi(method,'choose_trials'))
    n_trials = varargin{find(strcmpi(varargin, 'N_trials'))+1};
    if n_trials/2<=n_trials_per_cond; error('you need more trials to have no successing deviants...'); end
    sw=0;
    while sw==0
        res = sort(randsample(n_trials, n_trials_per_cond)); 
        if ~any(diff(res)==1)
            sw=1;
        end
    end
    
end
