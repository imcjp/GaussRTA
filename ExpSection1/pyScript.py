
import sys
from scipy.special import hyp2f1

if __name__ == "__main__":
    x = float(sys.argv[1])
    y = float(sys.argv[2])
    result = hyp2f1(1, x, 1 + x, -y)
    print(result)
