function number =  showEUMoney(x)

result = fix(x / 500);
x = mod(x, 500);
fprintf("500유로 %d장\n", result);

result1 = fix(x / 200);
x = mod(x, 200);
fprintf("200유로 %d장\n", result1);

result2 = fix(x / 100);
x = mod(x, 100);
fprintf("100유로 %d장\n", result2);

result3 = fix(x / 50);
x = mod(x, 50);
fprintf("50유로 %d장\n", result3);

result4 = fix(x / 20);
x = mod(x, 20);
fprintf("20유로 %d장\n", result4);

result5 = fix(x / 10);
x = mod(x, 10);
fprintf("10유로 %d장\n", result5);

result6 = fix(x / 5);
x = mod(x, 5);
fprintf("5유로 %d장\n", result6);

result7 = fix(x / 1);
x = mod(x, 1);
fprintf("1유로 %d장\n", result7);

x = x * 100;

result8 = fix(x / 50);
x = mod(x, 50);
fprintf("50 유로센트 %d장\n", result8);

result9 = fix(x / 20);
x = mod(x, 20);
fprintf("20 유로센트 %d장\n", result9);

result10 = fix(x / 10);
x = mod(x, 10);
fprintf("10 유로센트 %d장\n", result10);

result11 = fix(x / 5);
x = mod(x, 5);
fprintf("5 유로센트 %d장\n", result11);

result12 = fix(x / 2);
x = mod(x, 2);
fprintf("2 유로센트 %d장\n", result12);

result13 = x;

fprintf("1 유로센트 %.0f장\n", result13);

number = result + result1 + result2 + result3 + result4 + result5 + result6 + result7 + result8 + result9 + result10 + result11 + result12 + result13;
fprintf("총 %.0f장\n", number);
end