import numpy as np

NUMBER_LABELS = 5

#### LABELS ####
class Label:
    AKSHAY = 0
    ANGELA = 1
    ISAAC = 2
    MARK = 3
    NABILAH = 4
    ALL_PERSONS = 5

#### DATASET ####
class DataType:
    TRAIN = 0
    TEST = 1
    ALL_TYPE = 2

#### ANGLES ####
class Angle:
    DEG_0 = 0
    DEG_30 = 1
    DEG_45 = 2
    ALL_DEGREES = 3

#### ORIENTATIONS ####
class Orientation:
    LEFT = 0
    RIGHT = 1
    ALL_ORIENTATIONS = 2

#### COLOR ####
class Color:
    RGB = 0
    GRAYSCALE = 1


def label_to_name(label):
    if label == AKSHAY:
        return 'AKSHAY'
    if label == ANGELA:
        return 'ANGELA'
    if label == ISAAC:
        return 'ISAAC'
    if label == MARK:
        return 'MARK'
    if label == NABILAH:
        return 'NABILAH'

def get_accuracy(predictions, labels):
    """
    Function to compute accuracy of predictions: ratio of correct predictions to total predictions

    Args:
        predictions: np array of predictions 
        labels: correct labels for test images

    Returns:
        accuracy of the prediction data set
    """
    return np.sum(predictions == labels) / len(labels)

def get_confusion_matrix(predictions, labels):
    """
    Function to compute confusion matrix

    Args:
        predictions: np array of predictions 
        labels: correct labels for test images

    Returns:
        confusion matrix of the prediction data set
    """
    matrix = np.zeros((NUMBER_LABELS, NUMBER_LABELS))
    for i in range(0, NUMBER_LABELS):
        label_indices = np.where(labels == i)[0]
        prediction_of_person = predictions[label_indices]
        for j in range(0, NUMBER_LABELS):
            matrix[i, j] = np.sum(prediction_of_person == j) / len(label_indices)
    
    return matrix
