function good = issimilar(a, b)
error = abs(a-b);

if error < 50 %similar
    good = 1;
else
    good = 0;
end

end