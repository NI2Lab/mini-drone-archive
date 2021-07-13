function number =  showUSMoney(x)

result = fix(x / 100);
x = mod(x, 100);
fprintf("100달러 %d장\n", result);

result1 = fix(x / 50);
x = mod(x, 50);
fprintf("50달러 %d장\n", result1);

result2 = fix(x / 20);
x = mod(x, 20);
fprintf("20달러 %d장\n", result2);

result3 = fix(x / 10);
x = mod(x, 10);
fprintf("10달러 %d장\n", result3);

result4 = fix(x / 5);
x = mod(x, 5);
fprintf("5달러 %d장\n", result4);

result5 = fix(x / 1);
x = mod(x, 1);
fprintf("1달러 %d장\n", result5);

x = x * 100;

result6 = fix(x / 50);
x = mod(x, 50);
fprintf("50센트 %d장\n", result6);

result7 = fix(x / 25);
x = mod(x, 25);
fprintf("25센트 %d장\n", result7);

result8 = fix(x / 15);
x = mod(x, 15);
fprintf("15센트 %d장\n", result8);

result9 = fix(x / 10);
x = mod(x, 10);
fprintf("10센트 %d장\n", result9);

result10 = fix(x / 5);
x = mod(x, 5);
fprintf("5센트 %d장\n", result10);


result11 = x;
fprintf("1센트 %.0f장\n", result11);

number = result + result1 + result2 + result3 + result4 + result5 + result6 + result7 + result8 + result9 + result10 + result11;
fprintf("총 %.0f장\n", number);
end