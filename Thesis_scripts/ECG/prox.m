% Tests whether two numbers are close to each other
% Usage: result = prox (num,den,proximity)
%  proximity is maximum permissible percentage deviation between num and den.
%  result is logical 0 or 1 (false or true).

function result = prox (num,den,proximity)
    if abs(num-den)<=abs((proximity/100)*den),
        result = logical(1);
    else
        result = logical(0);
    end
    
