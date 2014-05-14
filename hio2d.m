% 2-D HIO written by Po-Nan Li @ Academia Sinica 2012
function R = hio2d(varargin)
    
    Fabs = varargin{1};
    S    = varargin{2};
    n    = varargin{3};

    if length(varargin) > 3
        unknown = varargin{4};
    else
        unknown = false(size(Fabs));
    end
    % OSS module
    if length(varargin) > 4
        alpha = varargin{5};
        oss = true;
        x = -round((length(Fabs)-1)/2):round((length(Fabs)-1)/2);
        [X, Y] = meshgrid(x, x);
        W = exp(-0.5 .* (X./alpha).^2) .* exp(-0.5 .* (Y./alpha).^2);
        W = ifftshift(W);
    else
        oss = false;
    end
    % solve unknown pixels in data
    
    
    beta1 = 0.9;
    
    % generate random initial phases
    if sum(imag(Fabs(:))) == 0
        ph_init = rand(size(Fabs));
        ph_init = angle(fft2(ph_init));
        F = Fabs .* exp(1j.*ph_init);
    else
        F = Fabs;
    end
    
    F0 = abs(F); 
    previous = ifft2(F, 'symmetric');
    
    % ================ iterations ==================================
    for t = 1:n
        if mod(t-1, 100) == 0 && n >= 500
            disp(['step ' int2str(t)]);
        end
        rs = ifft2(F, 'symmetric'); % real space version
        cond1 = ~S | (rs<0);
        rs(cond1) = previous(cond1) - beta1 .* rs(cond1);
        previous = rs;
        if oss
            rs_oss = ifft2(fft2(rs) .* W, 'symmetric');
            rs(~S) = rs_oss(~S);
        end
        F2 = fft2(rs); % .* exp(-1j.*(U+V));
        F = F0 .* exp(1j.*angle(F2));
        F(unknown) = F2(unknown);
    end
        % ================ iterations ends here  ==================================
    R = ifft2(F, 'symmetric');
end