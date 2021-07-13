from bs4 import BeautifulSoup
import urllib.request as req

# 실시간으로 환율 정보를 받아오는 함수


def realtime_financial_data():
    result_dict = dict()

    url = "https://finance.naver.com/marketindex/"  # 네이버 금융에서 환율정보를 실시간으로 가져온다

    res = req.urlopen(url)
    soup = BeautifulSoup(res, "html.parser", from_encoding='euc-kr')

    name_nation = soup.select('h3.h_lst > span.blind')
    name_price = soup.select('span.value')

    i = 0
    for c_list in soup:
        try:
            if i == 0:
                num_USD = float(name_price[i].text.replace(',', ''))
                result_dict[2] = num_USD
            elif i == 1:
                # 사이트에 100엔 기준이라 되어 있어 후처리(수정)
                num_JPY = float(name_price[i].text.replace(',', ''))/100
                result_dict[1] = num_JPY
            elif i == 2:
                num_EUR = float(name_price[i].text.replace(',', ''))
                result_dict[3] = num_EUR
            elif i == 3:
                num_CNY = float(name_price[i].text.replace(',', ''))
                result_dict[4] = num_CNY
            i = i + 1
        except IndexError:
            pass

    return result_dict  # 환율정보를 dic의 형태로 반환한다

# convert_num에 따라 입력받은 원화를 해당 국가의 화폐로 환전한다


def converted_money_f(convert_num, korean_money, financial_dict):
    money = korean_money
    if convert_num == 1:
        JPY = int(float(money)/financial_dict[1])+1
        print(JPY, "엔")
        return JPY

    elif convert_num == 2:
        USD = int((float(money)/financial_dict[2])*100)+1
        print(USD/100, "달러")
        return USD

    elif convert_num == 3:
        EUR = int((float(money)/financial_dict[3])*100)+1
        print(EUR/100, "유로")
        return EUR

    else:
        CNY = int((float(money)/financial_dict[4])*10)+1
        print(CNY/10, "위안")
        return CNY

# 최소 화폐 개수를 구하는 함수


def min_counts(convert_num, converted_money):
    if convert_num == 1:
        JPY = converted_money
        while(JPY > 0):
            a, JPY = divmod(JPY, 10000)
            b, JPY = divmod(JPY, 5000)
            c, JPY = divmod(JPY, 2000)
            d, JPY = divmod(JPY, 1000)
            e, JPY = divmod(JPY, 500)
            f, JPY = divmod(JPY, 100)
            g, JPY = divmod(JPY, 50)
            h, JPY = divmod(JPY, 10)
            i, JPY = divmod(JPY, 5)
            # divmod함수를 이용해 몫과 나머지를 얻어서 각 지폐(동전)가 필요한 수를 몫으로, 나머지는 다음 지페 단위로 넘기는 과정을 통해 필요한 최소 지폐(동전)의 개수를 구할 수 있도록 했다.
            j, JPY = divmod(JPY, 1)
        print("10000엔:", a, "장(개)")
        print("5000엔:", b, "장(개)")
        print("2000엔:", c, "장(개)")
        print("1000엔:", d, "장(개)")
        print("500엔:", e, "장(개)")
        print("100엔:", f, "장(개)")
        print("50엔:", g, "장(개)")
        print("10엔:", h, "장(개)")
        print("5엔:", i, "장(개)")
        print("1엔:", j, "장(개)")  # 필요한 지폐(동전) 수 출력
        print("Total: ", a+b+c+d+e+f+g+h+i+j, "장(개)")  # 개수 합계 출력
        print("--------------------------------------------")

    elif convert_num == 2:
        USD = converted_money
        # 달러(USD) 최소 화폐
        while(USD > 0):
            a, USD = divmod(USD, 10000)
            b, USD = divmod(USD, 5000)
            c, USD = divmod(USD, 2000)
            d, USD = divmod(USD, 1000)
            e, USD = divmod(USD, 500)
            f, USD = divmod(USD, 200)
            g, USD = divmod(USD, 100)
            h, USD = divmod(USD, 50)
            i, USD = divmod(USD, 25)
            j, USD = divmod(USD, 10)
            k, USD = divmod(USD, 5)
            l, USD = divmod(USD, 1)
            # divmod함수를 이용해 몫과 나머지를 얻어서 각 지폐(동전)가 필요한 수를 몫으로, 나머지는 다음 지페 단위로 넘기는 과정을 통해 필요한 최소 지폐(동전)의 개수를 구할 수 있도록 했다.

        # 센트가 들어와 있지 않음 1(0.01), 5(0.05), 10(0.10), 25(0.25), 50(0.50)
        print("100달러:", a, "장(개)")
        print("50달러:", b, "장(개)")
        print("20달러:", c, "장(개)")
        print("10달러:", d, "장(개)")
        print("5달러:", e, "장(개)")
        print("2달러:", f, "장(개)")
        print("1달러:", g, "장(개)")
        print("50센트:", h, "장(개)")
        print("25센트:", i, "장(개)")
        print("10센트:", j, "장(개)")
        print("5센트:", k, "장(개)")
        print("1센트:", l, "장(개)")  # 필요한 지폐(동전) 수 출력
        print("Total: ", a+b+c+d+e+f+g+h+i+j+k+l, "장(개)")  # 개수 합계 출력
        print("--------------------------------------------")

    elif convert_num == 3:
        EUR = converted_money
        while(EUR > 0):
            a, EUR = divmod(EUR, 50000)
            b, EUR = divmod(EUR, 20000)
            c, EUR = divmod(EUR, 10000)
            d, EUR = divmod(EUR, 5000)
            e, EUR = divmod(EUR, 2000)
            f, EUR = divmod(EUR, 1000)
            g, EUR = divmod(EUR, 500)
            h, EUR = divmod(EUR, 200)
            i, EUR = divmod(EUR, 100)
            j, EUR = divmod(EUR, 50)
            k, EUR = divmod(EUR, 20)
            l, EUR = divmod(EUR, 10)
            m, EUR = divmod(EUR, 5)
            n, EUR = divmod(EUR, 2)
            o, EUR = divmod(EUR, 1)
            # divmod함수를 이용해 몫과 나머지를 얻어서 각 지폐(동전)가 필요한 수를 몫으로, 나머지는 다음 지페 단위로 넘기는 과정을 통해 필요한 최소 지폐(동전)의 개수를 구할 수 있도록 했다.

        # 센트가 들어와 있지 않음 1(0.01), 2(0.02), 5(0.05), 10(0.10), 20(0.25), 50(0.50)
        print("500유로:", a, "장(개)")
        print("200유로:", b, "장(개)")
        print("100유로:", c, "장(개)")
        print("50유로:", d, "장(개)")
        print("20유로:", e, "장(개)")
        print("10유로:", f, "장(개)")
        print("5유로:", g, "장(개)")
        print("2유로:", h, "장(개)")
        print("1유로:", i, "장(개)")  # 필요한 지폐(동전) 수 출력
        print("50센트:", j, "장(개)")
        print("20센트:", k, "장(개)")
        print("10센트:", l, "장(개)")
        print("5센트:", m, "장(개)")
        print("2센트:", n, "장(개)")
        print("1센트:", o, "장(개)")
        print("Total: ", a+b+c+d+e+f+g+h+i+j+k+l+m+n+o, "장(개)")  # 개수 합계 출력
        print("--------------------------------------------")

    elif convert_num == 4:
        CNY = converted_money
        # 위안(CNY) 최소 화폐
        while(CNY > 0):
            a, CNY = divmod(CNY, 1000)
            b, CNY = divmod(CNY, 500)
            c, CNY = divmod(CNY, 200)
            d, CNY = divmod(CNY, 100)
            e, CNY = divmod(CNY, 50)
            f, CNY = divmod(CNY, 10)
            g, CNY = divmod(CNY, 5)
            h, CNY = divmod(CNY, 1)

            # divmod함수를 이용해 몫과 나머지를 얻어서 각 지폐(동전)가 필요한 수를 몫으로, 나머지는 다음 지페 단위로 넘기는 과정을 통해 필요한 최소 지폐(동전)의 개수를 구할 수 있도록 했다.

        # 1자오(0.1) 5자오(0.5)
        print("100위안:", a, "장(개)")
        print("50위안:", b, "장(개)")
        print("20위안:", c, "장(개)")
        print("10위안:", d, "장(개)")
        print("5위안:", e, "장(개)")
        print("1위안:", f, "장(개)")
        print("5자오:", g, "장(개)")
        print("1자오:", h, "장(개)")  # 필요한 지폐(동전) 수 출력
        print("Total: ", a+b+c+d+e+f+g+h, "장(개)")  # 개수 합계 출력

# dic에서 원하는 국가의 환율명을 반환하는 함수


def convert_num_to_code(convert_num):
    # dic 형태로 4가지 환율을 정리해 둔다.
    code_dict = {1: "JPY", 2: "USD", 3: "EUR", 4: "CNY"}
    return code_dict[convert_num]  # convert_num에 따라 dic에서 원하는 환율명을 반환한다.

# 어떤 국가의 화폐로 환전할 것인지, 환율정보는 미리 입력된 값을 사용할 것인지 실시간 환율정보를 받아와 사용할 것인지 결정할 수 있도록 하는 함수


def main():
    korean_money = int(input(
        "input money based on the korean currency unit(Won) you want to convert: "))  # 환전할 원화를 입력한다
    print(f"Your input was {korean_money}")  # 입력한 원화를 확인한다

    print("""
        ----------------------------------
        1. JPY
        2. USD
        3. EUR
        4. CNY
        ----------------------------------
        """)  # 4개의 선택지
    convert_num = eval(
        input("input number of country you want to convert: "))  # 입력을 통해 환전할 화페종류를 결정한다
    if convert_num in [1, 2, 3, 4]:  # 입력한 숫자가 1, 2, 3, 4 중에 있다면 어떤 국가의 화폐로 환전할 것인지 결정할 수 있다
        country_code = convert_num_to_code(convert_num)
    else:
        print("wrong input")
        return  # 굳이 return을 둘 필요가 있나요?

    default_financial_dict = {1: 10.2308, 2: 1115.0,
                              3: 1333.32, 4: 170.58}  # 입력해 둔 환율정보
    print(f"""
        -------------------------------------------------------------------------
        1. real time basis
        2. {country_code}: {default_financial_dict[convert_num]}
        -------------------------------------------------------------------------
        """)  # 2개의 선택지
    realtime_or_not = eval(input(
        "input number you want to choose: "))  # 어떤 방식으로 환율정보를 불러올 것인지 입력 방식을 통해 결정한다

    if realtime_or_not == 1:  # 1를 input하면 실시간 환율 정보를 가져온다
        realtime_financial_dict = realtime_financial_data()
        converted_money = converted_money_f(
            convert_num, korean_money, realtime_financial_dict)
        min_counts(convert_num, converted_money)
    elif realtime_or_not == 2:  # 2를 input하면 입력해 둔 환율정보를 가져온다
        converted_money = converted_money_f(
            convert_num, korean_money, default_financial_dict)
        min_counts(convert_num, converted_money)
    else:
        print("wrong input")  # 1과 2 외에 다른 것이 input되면 "wrong input"을 출력한다
        return  # 굳이 필요한 부분인지 의문


if __name__ == "__main__":
    main()  # 가장 처음 main 함수 시행
