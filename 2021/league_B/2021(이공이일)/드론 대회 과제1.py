import change_money as change
import Count_money as count
a = input('한국 원화 단위의 돈을 입력하시오. ')
b = a.replace('원','').replace('KRW','')
print(b)

#change-환전
#Count_money-변환 
money_list = change.change(b)
count.Count_Money(money_list)
