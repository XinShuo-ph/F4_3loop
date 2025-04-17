import sys

with open(sys.argv[1],"r") as input:
    lines = [line.split() for line in input]

data = "{\n"

for line in lines:
    for idx in range(len(line)):
        if idx == 0:
            line[0] = "var[" + line[0] + "] -> 0 "
        elif idx%2 == 0:
            line[idx] = "(" + line[idx] + ")"
        else:
            line[idx] = "+ var[" + line[idx] + "] * "
        data = data + line[idx]
    data = data + ",\n"

data = data+"}"

with open(sys.argv[1]+".m","w") as output:
    output.write(data)

