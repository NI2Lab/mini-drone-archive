function good = whereisCircle(img)
%가깝거나(고려x), 너무 편향되어 있는 경우 원 검출 x
bimg = separateBlue(img);
area_before = sum(bimg, 'all');

good = 0;
r = bimg(:,length(img));
l = bimg(:,1);
u = bimg(1, :);
d = bimg(length(r),:);

blue = [sum(r) sum(l) sum(u) sum(d)]; %r l u d
% noblue = blue <50; %조정 필요
hasblue = blue >50;
where = find(hasblue == 1);

for i = 1:4
    if ~isempty(find(where==i))
        good = movetofindCircle(i, area_before);
        
        if good
            break;
        end
    end
end

end