import os
import pprint
import fileinput
import pandas as pd
from pathlib import Path
from collections import Counter

def get_ordering_info(a_path,GOAL):
    print("Processing...")
    result = []
    less_than_goals = []
    participants = 0
    for dirs in Path(a_path).iterdir():
        if dirs.is_dir():
            participants += 1
            general_log_path = str(dirs)+"/"+str(dirs)+"_general_logs.csv"
            current_log_df = pd.read_csv(general_log_path,usecols=["Gamemode"])
            ordering = " -> ".join(str(c) for c in current_log_df["Gamemode"].unique()[0:])
            if len(current_log_df["Gamemode"].unique()) != GOAL:
                less_than_goals.append(str(dirs))
            result.append(ordering)
    res = Counter(result)
    print("Done!\n")
    print("Participants:",participants,"\nResults:")
    pprint.pprint(res)
    print('-'*10,"\nParticipants with more or less than",GOAL,"unique sessions:\n",less_than_goals)

GOAL = 7
PATH = "."
get_ordering_info(PATH,GOAL)