import sys
import usd
import euro
import yen
import yuan

print("금액(원)을 입력하세요 : ", end="")
won = float(sys.stdin.readline().rstrip())

usd.exchange(won)
euro.exchange(won)
yen.exchange(won)
yuan.exchange(won)
