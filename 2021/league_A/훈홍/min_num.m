function [num_cost] = min_num(unit_cost,cost)

nu = length(unit_cost);
num_cost = zeros(1,nu);

for i=1:nu
    num_cost(i) = floor(cost/unit_cost(i));
    cost = cost - num_cost(i)*unit_cost(i);
end

end


% nu = length(unit_usd);
% num_usd = zeros(nu,1);
% 
% for i=1:nu
%     num_usd(i) = floor(usd/unit_usd(i));
%     usd = usd - num_usd(i)*unit_usd(i);
% end
