# module imports
import os
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
import argparse

from openpyxl import load_workbook

# constants used in the script
file_path = './Questionnaire/Data/QuestionnaireData.xlsx'
NUM_QUESTIONS_TOTAL = 43
NUM_QUESTIONS_PRESENCE = 19
NUM_QUESTIONS_TLX = 6
NUM_QUESTIONS_EMBODIMENT = 18
NUM_QUESTIONS_EMBODIMENT_OWNERSHIP = 3
NUM_QUESTIONS_EMBODIMENT_AGENCY = 4
NUM_QUESTIONS_EMBODIMENT_TACTILE = 4
NUM_QUESTIONS_EMBODIMENT_LOCATION = 3
NUM_QUESTIONS_EMBODIMENT_APPEARANCE = 4

def main(participant_id, experiment_block):
    # read the excel file for the questionnaire data
    file = load_workbook(file_path)
    
    #print(f'The number of sheets in this file is {len(file.sheetnames)}')
    
    if participant_id > len(file.sheetnames):
        print('Invalid participant ID!')
        return -1
    # identify the sheets from which data needs to be collected  
    all_data = pd.read_excel(file_path, sheet_name=None)
    # if a particular participant is selected, only choose that sheet 
    # while maintaining dict structure
    if participant_id != -1:
        for sheet_name, df in all_data.items():
            if str(participant_id) in sheet_name:
                all_data = {sheet_name: all_data[sheet_name]}
    
    #print(f'Specified ID: {participant_id}\nData:\n{all_data}')

    # create dictionaries to store questions and their score lists for each questionnaire
    presence_responses = [{}, {}, {}]
    for j in range(experiment_block):
        for i in range(1, NUM_QUESTIONS_PRESENCE + 1):
            presence_responses[j][f'Q{i}'] = []
    
    tlx_responses = [{}, {}, {}]
    for j in range(experiment_block):
        for i in range(1, NUM_QUESTIONS_TLX + 1):
            tlx_responses[j][f'Q{i}'] = []
    
    embodiment_responses = [{}, {}, {}]
    for j in range(experiment_block):
        for i in range(1, NUM_QUESTIONS_EMBODIMENT + 1):
            embodiment_responses[j][f'Q{i}'] = []

    
    # now, regardless of how many participants we are plotting for,
    # iterate over the all_data object to accumulate scores
    count = 0
    # 1: WithHaptics participants
    for sheet_name, df in all_data.items():
        # check if the sheet is for a WithHaptics participant
        if 'WithHaptics' not in sheet_name:
            continue
        count += 1
        # iterate over experiment blocks to accumulate data
        for block_id in range(experiment_block):
            for question_id in range(1, NUM_QUESTIONS_PRESENCE + 1):
                presence_responses[block_id][f'Q{question_id}'].append(df[1 + block_id][1 + question_id])
            for question_id in range(1, NUM_QUESTIONS_TLX + 1):
                tlx_responses[block_id][f'Q{question_id}'].append(df[5 + block_id][1 + question_id])
            for question_id in range(1, NUM_QUESTIONS_EMBODIMENT + 1):
                
                
            
    
    print(f'Plotting data for {count} participant(s) under WithHaptics.')
    


if __name__ == "__main__":
    # Create an argument parser
    parser = argparse.ArgumentParser(description="Data analysis script for the Mirror Therapy questionnaires. The questionnaires \
                                     considered for the purposes of the experiment include Presence, NASA TLX and Avatar Embodiment.")

    # Add arguments to the parser
    parser.add_argument("participant_id", help="Integer indicating the ID of the participant for which plots are to be generated.\
                                            If all participants are considered, enter '-1'.")
    parser.add_argument("experiment_block", help="Integer indicating the experiment phase up till which plots are to be generated (1, 2, 3).")

    # Parse the command-line arguments
    args = parser.parse_args()

    # Call the main function with the provided arguments
    main(int(args.participant_id), int(args.experiment_block))