import matplotlib.pyplot as plt

def readFile(fileName, l) :
    with open(fileName, 'r') as inFile :
        for line in inFile :
            line = line.strip().split()
            if line[0] != "#" :
                l.append(int(line[-1]))


# fileNames = ["AF-aws.16", "AS-ali.16", "AS-aws.16", "OC-ali.16", "OC-aws.16", "SA-aws.16"]
fileNames = ["AF-aws.12", "AS-ali.12", "AS-aws.12", "OC-ali.12", "OC-aws.12", "SA-aws.12"]
for filename in fileNames :
    data = []
    readFile(filename, data)
    avg = sum(data)/len(data)

    fig, ax = plt.subplots(figsize =(10, 7))
    ax.hist(data, bins = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100])
    plt.title(filename + " with avg coverage: " + "{:.2f}".format(avg))
    plt.xlabel("coverage")
    plt.ylabel("count")
    plt.savefig(filename+".png", dpi=200)
    plt.close()


