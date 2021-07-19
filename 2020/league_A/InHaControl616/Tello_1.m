%% 1번
% input_str="a123";
% input_str=input_str+"!";
% input_str=reverse(input_str);
% disp(input_str)

%% 2번
% input_str="8 2";
% newstr=str2num(input_str);
% N=newstr(1);
% M=newstr(2);
% disp(num2str(N+M))
% disp(num2str(abs(N-M)))
% disp(num2str(N*M))
% disp(num2str(floor(N/M)))
% disp(num2str(mod(N,M)))

%% 3번
% input_str="1 2";
% k = str2num(input_str);
% a = k(1);
% b = k(2);
% 
% if(a>b)
%     disp(">");
% elseif(a<b)
%     disp("<");
% else
%     disp("==");
% end

%% 4번
% input_str="100";
% input_str=str2num(input_str);
% if input_str>=90
%     disp("A")
% elseif input_str>=80
%     disp("B")
% elseif input_str>=70
%     disp("C")
% elseif input_str>=60
%     disp("D")
% else
%     disp("F")
% end

%% 5번
% input_str = "2";
% N=str2num(input_str);
% for i=1:1:9
%     disp(num2str(N+" * "+i+" = "+N*i))
% end

%% 6번
% input_str="3";
% n=str2num(input_str);
% sum=0;
% for i=0:1:n
%     sum=sum+i;
% end
% disp(num2str(sum))

%% 7번 (??)
% input_str = "10 45\n1 10 4 9 2 3 8 5 7 6";
% newstr=splitlines(compose(input_str));
% str1=newstr(1);
% str2=newstr(2);
% a=str2num(str1);
% N=a(1);
% X=a(2);
% b=str2num(str2);
% j=1;
% M=0;
% for i=1:1:N
%     if b(i)<X
%         M(j)=b(i);
%         j=j+1;
%     end
% end
% K=num2str(M);
% K=strrep(K,"      ","     ");
% K=strrep(K,"     ","    ");
% K=strrep(K,"    ","   ");
% K=strrep(K,"   ","  ");
% K=strrep(K,"  "," ");
% disp(K)

%% 8번
% input_str = "5\n20 10 35 30 7";
% newstr=splitlines(compose(input_str));
% str1=newstr(1);
% str2=newstr(2);
% N=str2num(str1);
% max=-1000000;
% min=1000000;
% a=str2num(str2);
% for i=1:1:N
%     if a(i)>max
%         max=a(i);
%     end
%     if a(i)<min
%         min=a(i);
%     end
% end
% disp(num2str(min)+" "+num2str(max))

%% 9번
% input_str = "3\n29\n38\n12\n57\n74\n40\n85\n61";
% newstr=splitlines(compose(input_str));
% for i=1:1:9
%     n(i)=str2num(newstr(i));
% end
% max=0;
% for i=1:1:9
%     if n(i)>max
%         max=n(i);
%     end
% end
% disp(num2str(max))
% for i=1:1:9
%     if n(i)==max
%         disp(num2str(i))
%     end
% end

%% 10번
% input_str = "5";
% n=str2num(input_str);
% for i=n:-1:0
%     if rem(i,2)==1
%         disp(num2str(i))
%     end
% end