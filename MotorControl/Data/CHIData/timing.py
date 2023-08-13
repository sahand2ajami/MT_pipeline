import pandas as pd
import argparse

filename = './MotorControl/Data/CHIData/06Arman - with haptics - random targets/TestLeftDropPosCube.csv'




def compute_average_interval(timing_list):
    if len(timing_list) == 0:
        return None
    if len(timing_list) == 1:
        return 0
    time_accumulator = 0
    interval_count = 0
    for i in range(1, len(timing_list)):
        if (timing_list[i] - timing_list[i - 1] > 6):
            continue
        time_accumulator += timing_list[i] - timing_list[i - 1]
        interval_count += 1
    return time_accumulator / interval_count


def main():
    file = pd.read_csv(filename)
    # below is the variable that stores all time values
    #print(file['Time'].to_list())
    print(f'Average time: {compute_average_interval(file["Time"].to_list())}')

if __name__ == "__main__":
    main()