from termgraph import termgraph as tg
import json

f_in = open("./graph/data.json")
data = json.load(f_in)

timeline = data["timeline"]
cases = timeline["cases"]
deaths = timeline["deaths"]
recovered = timeline["recovered"]

f_out = open("./graph/data.txt","w+")
f_out.write("@ Cases,Deaths,Recovered\n")

for key in cases:
    a = str(key) + ',' + str(cases[key]) + ',' + str(deaths[key]) + ',' + str(recovered[key]) + '\n'
    f_out.write(a)

f_out.close()
